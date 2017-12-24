
# coding: utf-8

# This tool tries to segment bursts of sound from otherwise quiet recordings in `data/project/raw`. It starts by thresholding the amplitude of the audio over time, and then removes very short sounds, and combines two sounds with a short silence into one.

# In[1]:

data_root = '/Users/erikparr/Documents/_2017/Landscapes/sketches/python/SpeciesOfSpaces/data/'
output_path = '/Users/erikparr/Documents/_2017/Landscapes/snd/' #this will be external HD later
plot = False
save = True
threshold_amp = 0.2
min_duration = 1.0
max_duration = 10.0
max_samples = 24 # set to "None" to save all the samples
sr = 48000
n_fft = 2048
hop_length = n_fft/4
limit = None


# In[2]:

#get_ipython().magic(u'matplotlib inline')
from scipy.stats.mstats import mode
from matplotlib import pyplot as plt
from matplotlib import patches
from scipy.signal import argrelmin, argrelmax
from scipy.ndimage.filters import gaussian_filter1d as gaussian
from scipy.stats.mstats import mode
import sys
sys.path.insert(0, '/Users/erikparr/Documents/_2017/Landscapes/Utilities')
from multisampleUtils import list_all_files, ffmpeg_load_audio, ffmpeg_save_audio
from IPython.display import display, Audio
from random import shuffle
import cPickle as pickle
import os
from os.path import join
import librosa
import numpy as np


files = list(list_all_files(join(data_root, 'raw'), ['.mp3', '.wav']))


class MultisampleToSample:
    
    def __init__(self, soundid):
        global freesoundID
        freesoundID = soundid

    # In[4]:

    def split_chunks(self, x):
        chunks = []
        previous = None
        for sample in x:
            if sample != previous:
                chunks.append([])
            chunks[-1].append(sample)
            previous = sample
        return chunks

    def join_chunks(self, chunks):
        return [item for sublist in chunks for item in sublist]

    def replace_small_chunks(self, chunks, search, substitute, min_length):
        modified = []
        for chunk in chunks:
            cur = chunk[0]
            if cur == search and len(chunk) < min_length:
                cur = substitute
            modified.append([cur for x in chunk])
        return self.split_chunks(self.join_chunks(modified))

    # do a grid search to determine the min and max chunk sizes
    # that minimize standard deviation of chunk lengths
    def get_optimal_chunks(self, chunks, min_length=3, max_length=500, n=10):
        best_std = None
        best_chunks = []
        for quiet_thresh in np.linspace(min_length, max_length, n):
            for sound_thresh in np.linspace(min_length, max_length, n):
                cur = self.replace_small_chunks(chunks, False, True, quiet_thresh)
                cur = self.replace_small_chunks(cur, True, False, sound_thresh)
                chunk_lengths = [len(chunk) for chunk in cur]
                cur_std = np.std(chunk_lengths)
                if (best_std is None or cur_std < best_std) and len(cur) > 1:
    #                 print cur_std, 'better than', best_std, 'using', quiet_thresh, sound_thresh
                    best_chunks = cur
                    best_std = cur_std
        return best_chunks


    # In[5]:
    def convert(self):
        min_duration_frames = librosa.core.time_to_frames([min_duration], sr=sr, hop_length=hop_length)[0]
        max_duration_frames = librosa.core.time_to_frames([max_duration], sr=sr, hop_length=hop_length)[0]
        plot_downsample = 100
        figsize = (30,3)
        i = 0
        print "hi there " + data_root
        for fn in files[:limit]:
            basename = os.path.basename(fn).split('.')[0]
            y, _ = ffmpeg_load_audio(fn, sr=sr)
            y = y[0,:] # take one channel, avoid mid/side and out-of-phase errors
            y /= y.max()
            
            print basename, int(len(y)/sr), 'seconds'
            
            if plot:
                # plot the raw waveform
                plt.figure(figsize=figsize)
                plt.plot(y[::plot_downsample])
                plt.xlim([0, len(y)/plot_downsample])
                plt.gca().xaxis.set_visible(False)
                plt.gca().yaxis.set_visible(False)
                plt.show()
        
            # compute the rmse and threshold at a fixed value
            S = librosa.stft(y, n_fft=n_fft, hop_length=hop_length)
            e = librosa.feature.rmse(S=S)[0]
            e -= e.min()
            e /= e.max()
            et = np.where(e < threshold_amp, False, True)
            
            # split the thresholded audio into chunks and combine them optimally
            chunks = self.split_chunks(et)
            chunks = self.get_optimal_chunks(chunks, min_duration_frames, max_duration_frames, 10)
            et = self.join_chunks(chunks)
            
            if plot:
                # plot the rmse and thresholded rmse
                plt.figure(figsize=figsize)
                plt.plot(e)
                plt.plot(et)

            # convert chunks into "slices": beginning and end position pairs
            slices = []
            cur_slice = 0
            for chunk in chunks:
                next_slice = cur_slice + len(chunk)
                if chunk[0] and len(chunk) < max_duration_frames:
                    slices.append([cur_slice, next_slice])
                cur_slice = next_slice
            
            for left, right in slices[:max_samples]:
                if plot:
                    # highlight saved chunks
                    plt.gca().add_patch(patches.Rectangle((left, 0), (right - left), 1,
                                                         hatch='//', alpha=0.2, fill='black'))

                sample = np.copy(y[left*hop_length:right*hop_length])
                sample /= np.abs(sample).max()
                ffmpeg_save_audio(join(output_path, 'radioArchipelago/{}_{}.wav'.format(freesoundID, i)), sample, sr=sr)
                i += 1
                print i, " :should be doing it..."

            if plot:
                # finish up the plot we've been building
                plt.xlim([0, len(e)])
                plt.gca().xaxis.set_visible(False)
                plt.gca().yaxis.set_visible(False)
                plt.show()

                # plot the log amplitude spectrogram
                plt.figure(figsize=figsize)
                logamp = librosa.logamplitude(S**2, ref_power=np.max)
                librosa.display.specshow(logamp, sr=sr, cmap='viridis')
                plt.tight_layout()
                plt.show()

