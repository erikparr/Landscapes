import os
import urllib2
import pycurl
import time
import subprocess
import sys
import json
#below are for python-wavefile libs
from wavefile import WaveWriter, Format
import numpy as np

sys.path.insert(0, '/Users/erikparr/Documents/_2017/Landscapes/Utilities/freesound')
import freesound
sys.path.insert(0, '/Users/erikparr/Documents/_2017/Landscapes/Utilities/json')
from jsonWriter import JSONWriter
sys.path.insert(0, '/Users/erikparr/Documents/_2017/Landscapes/Utilities/multisampleToSample')
from MultisamplesToSamples import MultisampleToSample


#-------------------------------------
#python-wavefile for wav conversion and metadata writing --  NOT IMPLEMENTED -- -
#def convertToWav(filename):
#    with WaveWriter(filename, channels=2, format=Format.WAV|Format.AIFF) as w :
#        w.metadata.title = "Some Noise"
#            w.metadata.artist = "The Artists"
#            data = np.zeros((2,512), np.float32)
#            for x in xrange(100) :
#                data[0,:] = (x*np.arange(512, dtype=np.float32)%512/512)
#                    data[1,512-x:] =  1
#                    data[1,:512-x] = -1
#                    w.write(data)
#----

def refreshToken():
    global  accessToken
    filepath = '/Users/erikparr/Documents/_2017/Landscapes/sketches/python/SpeciesOfSpaces/token.json'
    jsonFile = open(filepath, "r+")
    data = json.load(jsonFile)
    refreshToken = data["refresh_token"]
    unixcmd = "curl -X POST -d 'client_id="+clientId+"&client_secret="+apiKey+"&grant_type=refresh_token&refresh_token="+refreshToken+"'"+" https://www.freesound.org/apiv2/oauth2/access_token/ >'"+filepath+"'"
    os.system(unixcmd)
    time.sleep(0.5)
    jsonFile = open(filepath, "r+")
    data = json.load(jsonFile)
    accessToken =  data["access_token"]
    print "accessToken: "+accessToken


# ------------------------------------
def loadSoundMetadata():
    global soundfileIndex
    global groupIndex
    global targetDir
    global currentId
    data = {}
    data[soundgroup] = [{}] #data should contain useful info about the current sound group
#    data[soundgroup][0] = {'numFiles':'', 'fileTypes':''}
    if metadata.fileExists() == False or NEWSESSION or metadata.isNewFile():
        metadata.createNew(data)
    else:
        soundfileIndex = metadata.getSoundFileIndex()
#        groupIndex = metadata.getGroupIndex()
        targetDir = metadata.getLastDir()
        currentId = getLastID()

# ------------------------------------
def soundExists(currentId):
    metadata.doesIdExist(currentId)
# ------------------------------------
def manageData():
    global descriptors
    global soundfileIndex
    global groupIndex
    global maxSoundFiles
    global targetDir
    global startId
    global currentId
    metadata.appendDict(groupIndex, descriptors)
    if soundfileIndex>maxSoundFiles:
        soundfileIndex=0
        targetDir+=1
        currentId = startId #reset to first sound
    soundfileIndex+=1
    groupIndex+=1

# ------------------------------------
def getNewSound(freesoundID, fileIndex):
    global descriptors
    global targetDir
    sound = None
    while sound is None:
        try:
            sound = c.get_sound(freesoundID) #start with a given sound id
            descriptors.clear()
            descriptors = {'id':currentId, 'dir':targetDir, 'tags': sound.tags, 'filename': str(fileIndex)+"."+str(sound.type)}
        except urllib2.URLError:
            print "can't connect .. trying again..."
            time.sleep(1)
    return sound

def driftSound():
    global currentId
    global soundfileIndex
    global accessToken
    global sndpath
    global targetDir
    similarSoundList = None
    newSound = getNewSound(currentId, soundfileIndex)
        
    if metadata.doesIdExist(currentId) == False:
        while similarSoundList is None:
            try:
                similarSoundList = newSound.get_similar()
                print "similar sound retrieved"
            except urllib2.URLError:
                print "can't get similar .. trying again..."
                time.sleep(1)
        
        for i in range(0, len(similarSoundList.results)):
            similarSound = similarSoundList[i]
            if metadata.doesIdExist(similarSound.id):
                print "already exists.."
                if i == len(similarSoundList.results)-1:
                    print "---- all similar sounds already downloaded! ----"
                    #TODO: make function that retrieves new sound id
            else:
                print "new similar sound found"
                currentId = similarSound.id
                newSound = getNewSound(currentId, soundfileIndex) # if new similar sound is found,
                break

    targetPath = str(sndpath)+str(targetDir)+"/"
    if not os.path.exists(targetPath):
        os.makedirs(targetPath)
    print "downloading..."
    unixcmd = "curl -o '"+targetPath+str(soundfileIndex)+'.'+str(newSound.type)+"' -H 'Authorization: Bearer "+ str(accessToken)+"' 'https://www.freesound.org/apiv2/sounds/'"+str(currentId)+"/download/"
    print targetPath+str(soundfileIndex)+'.'+str(newSound.type)
    os.system(unixcmd)
    manageData()
# ------------------------------------
#init
soundgroup = "field-recording"
NEWSESSION = True
c = freesound.FreesoundClient()
apiKey = "a93ac1a1b2bfc3118513999530391a5bb874edf7" #apikey/token/Client secret
clientId = "0eda595d0c08565c7a7c"
#refreshToken = ""
accessToken = ""
c.set_token(apiKey,"token")
startId = 5560 #starting "seed" Freesound sound ID
currentId = startId #current sound ID in the process
soundfileIndex = 0 #index of soundfile in the directory
groupIndex = 0 #index of soundfile in the group
targetDir = 0 #current directory being downloaded to
maxDirs = 5 # maximum number of directories
maxSoundFiles = 25 #number of soundfiles (see: soundfileIndex) in a given folder
sndpath = '/Users/erikparr/Documents/_Projects_2016/Landscapes/snd/'+soundgroup+'/'
currentPath = '/Users/erikparr/Documents/_2017/Landscapes/sketches/python/SpeciesOfSpaces/'
metadata = JSONWriter(soundgroup, currentPath+'metadata.json')
descriptors = {}
# ------------------------------------
# retrieve sounds until x directories are filled
loadSoundMetadata()
#refreshToken()
MultisampleToSample(currentId).convert()
#while targetDir<=maxDirs:
#    driftSound();
#    time.sleep(1)


