
import json
import os.path
#superDict = {'sounddata':'sounddata'}
#dirDict = {'dir':1, 'dir1':2}
#dict = {'id':12823, 'num':1, 'tags':['something','here','yes']}
#path = '/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/LandscapeStudy/sounddata.json'
path = ''
rootName = ''
class JSONWriter:

    def __init__(self, documentRootName, filepath):
        global path
        global rootName # the root name of the docuement
        path = filepath
        rootName = documentRootName
    
    def createNew(self, dictionary):
        global path
        global rootName
    #    tags = dictionary['tags']
    #    for i in tags:
    #        print i
        json_string =  json.dumps(dictionary, indent=2, sort_keys=True)
        jsonFile = open(path, 'w+')
        jsonFile.write(json_string)

    def appendDict(self, targetKey, newDict):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        data[targetKey] = (newDict)
#        print "appending to json file: " +
        jsonFile = open(path, "r+")
        jsonFile.truncate()
        jsonFile.write(json.dumps(data, indent=2, sort_keys=True))

    def doesIdExist(self, soundId):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        for elements in data:
            if data[elements] != str(rootName): #dont search the root element (maybe there is a better way to do this)
                id = data[elements]["id"]
                if id == soundId:
#                    print "found it: "+str(id)
                    return True
        print "New sound id: "+ str(soundId)
        return False


    def printTags(self):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        for elements in data:
            print elements
            if data[elements] != str(rootName): #dont search the root element (maybe there is a better way to do this)
                tags = data[elements]["tags"]
                for i in tags:
                    print i

    def getSoundFileIndex(self):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        #        print "number of soundfiles: "+str(len(data))
        return len(data)-1 # subtract one extra because counting bottom key ("sounddata")

#return last directory count
    def getLastDir(self):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        return int(data.values()[len(data)-2]["dir"]) # subtract one extra because counting bottom key ("sounddata")

        #        print "number of soundfiles: "+str(len(data))
        return len(data)

    def getLastID(self):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        return data.values()[len(data)-2]["id"] # subtract one extra because counting bottom key ("sounddata")
        
        #        print "number of soundfiles: "+str(len(data))
        return len(data)
    
    def fileExists(self):
        global path
        if os.path.isfile(path):
            return True
        else:
            return False

    def isNewFile(self):
        global path
        jsonFile = open(path, "r+")
        data = json.load(jsonFile)
        print "data dict size: "+str(len(data))
        if len(data)<2: #
            return True
        else:
            return False
