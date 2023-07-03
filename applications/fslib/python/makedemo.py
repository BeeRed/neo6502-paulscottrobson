# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		makedemo.py
#		Purpose :	Make test file system
#		Date :		27th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,os,re,sys
from fakefile import *
from flash import *
from filesystem import *

class RealFile(object):
	def __init__(self,name):
		self.name = name 
		self.data = [x for x in open("files"+os.sep+name,"rb").read(-1)]
		print(self.name,len(self.data))
	def getName(self):
		return self.name 
	def getData(self):
		return self.data
	def getLength(self):
		return len(self.data)

fs = FileSystem()  																	# new file system formatted
fs.format()
random.seed(43)

for root,dirs,files in os.walk("files"):
	for f in [x for x in files if x.endswith(".bas")]:
		fileName = root + os.sep + f
		print(fileName,f)
		file = RealFile(f)
		fs.write(file)
fs.dump()		
fs.save("flash.image")