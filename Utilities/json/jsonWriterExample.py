from jsonWriter import JSONWriter
import os

superDict = {'sounddata':'sounddata'}
dirDict = {'dir':1, 'dir1':2}
dict = {'id':12823, 'num':1, 'tags':['something','here','yes']}

json = JSONWriter("sounddata", '/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/LandscapeStudy/sounddata.json')
#json.createNew(superDict)
#json.appendDict('newshit', dict)
#json.appendDict('newshit1', dict)
json.printTags()
json.doesIdExist(666)
