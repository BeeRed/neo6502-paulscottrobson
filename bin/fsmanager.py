# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		fsmanager.py
#		Purpose :	File System manager
#		Date :		8th July 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,random

# *******************************************************************************************
#
#							File System Image class
#
# *******************************************************************************************

class FlashFileSystem(object):
	#
	#		Initialise file system
	#
	def __init__(self,memorySize = 1048576 >> 3):
		self.sectorCount = memorySize // 4096
		self.fileName = "flash.image"
		self.changed = False
		self.format()
		if os.path.isfile(self.fileName):
			h = open(self.fileName,"rb")
			self.fs = [x for x in h.read(-1)]
			h.close()
			print("Loaded.")
		else:
			self.format()
	#
	#		Flush file system to disk if required
	#
	def flush(self):
		if self.changed:
			h = open(self.fileName,"wb")
			h.write(bytes(self.fs))
			h.close()
			self.changed = False
	#
	#		Format the file system.
	#
	def format(self):
		self.fs = [0xFF] * (4096 * self.sectorCount)
		self.fs[0] = ord('I')
		self.fs[1] = ord('1')
		self.fs[2] = self.sectorCount
		self.fs[3] = 0
		self.changed = True
	#
	#		Number of sectors
	#
	def getSectorCount(self):
		return self.fs[2] + self.fs[3] * 256
	#
	#		Read sector header.
	#
	def readHeader(self,sector):
		a = sector * 4096
		self.hType = chr(self.fs[a+0]) 									# type I F N anything else blank
		self.hCont = chr(self.fs[a+1]) 									# Continuation of file ?
		self.hSectorData = self.fs[a+2]+self.fs[a+3] * 256  			# bytes of data in this sector
		self.hFileSize = 0
		if sector != 0:
			self.hFileSize = self.fs[a+5]+self.fs[a+5] * 256  			# bytes of data in whole file
			self.hFileName = "".join([chr(self.fs[a+17+n]) for n in range(0,self.fs[a+16])])
		else:
			self.hFileName = "[root]"
		if self.hType != "I" and self.hType != "F" and self.hType != "N":
			self.hType = "-"
			self.hCont = "-"
			self.hFileName = ""
			self.hFileSize = 0
			self.hSectorData = 0
	#
	#		Display the file system structure.
	#
	def showStructure(self):
		for s in range(0,self.getSectorCount()):
			self.readHeader(s)
			print("[{0:2}] Type:{1} Cont:{2} Data:{3:5} Size:{4:5} File:{5}".format(s,self.hType,self.hCont,self.hSectorData,self.hFileSize,self.hFileName))
	#
	#		Insert a file
	#
	def insert(self,fileName):
		lfileName = fileName.split(os.sep)[-1].lower()
		print(lfileName)
		self.erase(lfileName)
		self.changed = True 
		h = open(fileName,"rb")
		fileData = [x for x in h.read(-1)]
		h.close()
		size = len(fileData)
		isFirst = True  												# First check
		complete = False 												# Complete check.
		sector =  random.randint(0,self.getSectorCount())				# start position.
		while not complete:
			sector = self.findFree(sector)								# find next free sector.
			if sector is None: 											# full, erase file and fail.
				self.erase(fileName)
				return False
			a = sector * 4096 											# set up the header.
			dataOut = min(4096-256,len(fileData))						# how much going out this time.
			complete = (len(fileData) - dataOut) == 0  					# complete if none left.
			self.fs[a+0] = ord('F' if isFirst else 'N')					# first / next
			self.fs[a+1] = ord('Y' if not complete else 'N')			# is there more after this ?		
			self.fs[a+2] = dataOut & 0xFF 								# data written this time
			self.fs[a+3] = dataOut >> 8
			self.fs[a+4] = size & 0xFF 									# total size
			self.fs[a+5] = size >> 8
			self.fs[a+16] = len(lfileName) 								# filename
			for i in range(0,len(lfileName)):
				self.fs[a+17+i] = ord(lfileName.lower()[i])

			for i in range(0,dataOut): 									# write the data out.
				self.fs[i+a+256] = fileData[i]

			fileData = fileData[dataOut:]								# remove data.
			isFirst = False 											# not first.
		return True
	#
	#		Find a free sector
	#
	def findFree(self,sector):
		count = self.getSectorCount()
		while count > 0:
			count -= 1
			sector = (sector + 1) % self.getSectorCount()
			self.readHeader(sector)
			if self.hType == "-":
				return sector 
		return None
	#
	#		Erase a file
	#
	def erase(self,fileName):
		for s in range(1,self.getSectorCount()):
			self.readHeader(s)
			if self.hType == 'F' or self.hType == 'N':
				if self.hFileName == fileName.lower():
					self.eraseSector(s)
	#
	#		Erase a sector
	#
	def eraseSector(self,sector):
		for i in range(0,4096):
			self.fs[sector * 4096 + i] = 0xFF

if __name__ == '__main__':

	fs = FlashFileSystem()
	for c in sys.argv[1:]:
		if c == "show":
			fs.showStructure()
		elif c == "format":
			fs.format()
		else:
			fs.insert(c)

	fs.flush()

	