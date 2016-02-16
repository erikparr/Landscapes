from Queue import Queue
import logging
import os
from threading import Thread
import audiotools
from audiotools.wav import InvalidWave
from pydub import AudioSegment
import wave
#Flac 2 Wav converter script
#using audiotools
path = ""

class Flac2wav:

    logger = ''

    def __init__(self, initPath):
        global path
        global logger
        path = initPath
        # create logger
        logger = logging.getLogger(__name__)
        logger.setLevel(logging.DEBUG)
        
        # create a file handler
        handler = logging.FileHandler('converter.log')
        handler.setLevel(logging.INFO)
        
        # create a logging format
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        
        # add the handlers to the logger
        logger.addHandler(handler)

    def setDownloadDir(self, targetPath):
        global path
        path = targetPath
    
    def cleanupOldFiles(self):
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".aiff") or file.endswith(".aif") or file.endswith(".ogg") or file.endswith(".mp3") or file.endswith(".aac"):
                    os.remove(path+"/"+file)




    def stereoToMono(self):
        global path
        print "converting to mono"
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".wav"):
                    fp = wave.open(path+"/"+file)
                    if fp.getnchannels() > 1:
                        sound = AudioSegment.from_wav(path+'/'+file)
                        sound = sound.set_channels(1)
                        sound.export(path+'/'+file, format="wav")

    def convertRemainingToWavAndCleanup(self):
        global path
        unixCmd = "for f in *.aiff; do ffmpeg -r 44100 -i \"$f\" \"${f%.aiff}.wav\"; done"
        os.chdir(path)
        os.system(unixCmd)
        unixCmd = "for f in *.aif; do ffmpeg -r 44100 -i \"$f\" \"${f%.aif}.wav\"; done"
        os.chdir(path)
        os.system(unixCmd)
        unixCmd = "for f in *.mp3; do ffmpeg -r 44100 -i \"$f\" \"${f%.mp3}.wav\"; done"
        os.chdir(path)
        os.system(unixCmd)
        unixCmd = "for f in *.ogg; do ffmpeg -r 44100 -i \"$f\" \"${f%.ogg}.wav\"; done"
        os.chdir(path)
        os.system(unixCmd)
        unixCmd = "for f in *.aiff; do ffmpeg -r 44100 -i \"$f\" \"${f%.aac}.wav\"; done"
        os.chdir(path)
        os.system(unixCmd)
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".aiff") or file.endswith(".aif") or file.endswith(".ogg") or file.endswith(".mp3") or file.endswith(".aac"):
                    os.remove(path+"/"+file)

    def trimAudiofiles(self, duration):
        print "-----------------trimming Audio files.. ------------------ "
        duration = duration * 1000 #in milliseconds
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".wav"):
                    print path+"/"+file
                    track = AudioSegment.from_wav(path+"/"+file)
                    track = track[:duration]
                    track.export(file, format="wav")

    def convertAll(self, duration):
        global path
        print path
        duration = duration * 1000 #in milliseconds
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".DS_Store") is False:
                    file = os.path.join(root, file)
                    print file
                    if(file.endswith(".ogg")):
                       sound = AudioSegment.from_ogg(file)
                    else:
                        print "before"
                        if(file.endswith(".aiff")):
                        sound = AudioSegment.from_file(file)
                        print "after"
                    sound = sound.set_channels(2)
                    sound = sound.set_frame_rate(48000)
                    print len(sound)
                    print duration
                    print sound.channels
                    print "-"
                    if len(sound)>duration:
                        sound = sound[:duration]
                    if(file.endswith(".aiff")):
                        file = file[:-4]
                    else:
                        file = file[:-3]
                    file = file+"wav"
                    file_handle = sound.export(file,
                                           format="wav",
                                           bitrate="256k")


    def convert(self):
        global logger
        global path
        file_queue = Queue()
        num_converter_threads = 5
        # collect files to be converted
        for root, dirs, files in os.walk(path):
            
            for file in files:
                if file.endswith(".flac"):
                    file_flac = os.path.join(root, file)
                    file_wav = file_flac.replace(".flac", ".wav")
                    
                    if (os.path.exists(file_wav)):
                        logger.debug(''.join(["File ",file_wav, " already exists."]))
                    else:
                        file_queue.put(file_flac)
        
        logger.info("Start converting:  %s files", str(file_queue.qsize()))
        
        # Set up some threads to convert files
        for i in range(num_converter_threads):
            worker = Thread(target=self.process, args=(file_queue,))
            worker.setDaemon(True)
            worker.start()

        file_queue.join()
        print "good yes wonderful good"
    
    def process(self, q):
#    """This is the worker thread function.
#        It processes files in the queue one after
#        another.  These daemon threads go into an
#        infinite loop, and only exit when
#        the main thread ends.
#        """
        while True:
            global logger
            compression_quality = '0' #min compression
            file_flac = q.get()
            file_wav = file_flac.replace(".flac", ".wav")
            try:
                audiotools.open(file_flac).convert(file_wav,audiotools.WaveAudio, compression_quality)
                logger.info(''.join(["Converted ", file_flac, " to: ", file_wav]))
                if os.path.isfile(file_flac):
                    os.remove(file_flac)
                else:
                    print file_flac

                q.task_done()
            except InvalidWave:
                logger.error(''.join(["Failed to open file ", file_flac, " to: ", file_wav," failed."]), exc_info=True)
            except Exception, e:
                logger.error('ExFailed to open file', exc_info=True)


