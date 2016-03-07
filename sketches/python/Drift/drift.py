import os
import urllib2
import pycurl
import time
import subprocess
import sys
import json
sys.path.insert(0, '/Users/erikparr/Documents/_Projects/Landscapes/Utilities/freesound')
import freesound
sys.path.insert(0, '/Users/erikparr/Documents/_Projects/Landscapes/Utilities/json')
from jsonWriter import JSONWriter

#init
soundgroup = "Tibetan Bell"
NEWSESSION = True
c = freesound.FreesoundClient()
apiKey = "a93ac1a1b2bfc3118513999530391a5bb874edf7" #apikey/token/Client secret
clientId = "0eda595d0c08565c7a7c"
refreshToken = ""
accessToken = ""
c.set_token(apiKey,"token")
startId = 15361 #starting "seed" Freesound sound ID
currentId = startId #current sound ID in the process
soundfileIndex = 0 #index of soundfile in the directory
groupIndex = 0 #index of soundfile in the group
targetDir = 0 #current directory being downloaded to
maxDirs = 5 # maximum number of directories
maxSoundFiles = 25 #number of soundfiles (see: soundfileIndex) in a given folder
sndpath = '/Users/erikparr/Documents/_Projects/Landscapes/snd/test/'
currentPath = '/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/Drift/'
metadata = JSONWriter(soundgroup, currentPath+'metadata.json')
descriptors = {}

#----

def refreshToken():
    global  refreshToken
    global  accessToken
    jsonpath = '/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/Drift/token.json'
    jsonFile = open(jsonpath, "r+")
    data = json.load(jsonFile)
    refreshToken = data["refresh_token"]
    unixcmd = "curl -X POST -d 'client_id="+clientId+"&client_secret="+apiKey+"&grant_type=refresh_token&refresh_token="+refreshToken+"'"+" https://www.freesound.org/apiv2/oauth2/access_token/ >'"+jsonpath+"'"
    os.system(unixcmd)
    time.sleep(0.5)
    jsonFile = open(jsonpath, "r+")
    data = json.load(jsonFile)
    accessToken =  data["access_token"]
    print "accessToken: "+accessToken

# ------------------------------------
def loadSoundMetadata():
    global soundfileIndex
    global groupIndex
    global targetDir
    global currentId
    rootData = {}
    rootData[soundgroup] = [{}] #rootData should contain useful info about the current sound group
    rootData[soundgroup][0] = {'numFiles':'', 'fileTypes':''}
    if metadata.fileExists() == False or NEWSESSION or metadata.isNewFile():
        metadata.createNew(rootData)
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
def getNewSound(id, fileIndex):
    global descriptors
    global targetDir
    sound = None
    while sound is None:
        try:
            sound = c.get_sound(id) #start with a given sound id
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
        
    if metadata.doesIdExist(currentId):
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

# retrieve sounds until x directories are filled
loadSoundMetadata()
refreshToken()
while targetDir<=maxDirs:
    driftSound();
    time.sleep(1)
