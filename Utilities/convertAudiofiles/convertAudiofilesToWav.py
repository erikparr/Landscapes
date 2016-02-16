from flac2wav import Flac2wav
import os
path = "/Users/erikparr/Documents/_Projects/Landscapes/snd/vocal-c4/"

f2w = Flac2wav(path)
os.chdir(path)
dir_list = next(os.walk('.'))[1]
for dir in dir_list:
    path = path+dir
#            os.chdir(subdir)
#            for root, dirs, files in os.walk(subdir):
#                for file in files:
#                    print file
    f2w.setDownloadDir(path)
    f2w.convert()
    #f2w.convertRemainingToWavAndCleanup()
    f2w.convertAll(60)
    f2w.cleanupOldFiles()
    #f2w.trimAudiofiles(10)
#    f2w.stereoToMono()

