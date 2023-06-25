# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		filesystem.py
#		Purpose :	File System
#		Date :		25th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,os,re,sys
from fakefile import *
from flash import *

# *******************************************************************************************
#
#										FileSystem class
#
# *******************************************************************************************

class FileSystem(object):
	def __init__(self,storage = FlashMemory()):
		self.storage = storage
	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#												Display the storage
	#
	# ------------------------------------------------------------------------------------------------------------------------------
	def dump(self):
		for sector in range(0,self.storage.getSectorCount()):
			sType = self.storage.readDebug(sector,0)

			sDesc = "-----" if sType != ord('F') and sType != ord('N') else self.getSectorInformation(sector)
			print("Sector {0:3} : {1}".format(sector,sDesc))
	#
	def getSectorInformation(self,sector):
		size = self.storage.readDebug(sector,2) + self.storage.readDebug(sector,3) * 256
		total = self.storage.readDebug(sector,4) + self.storage.readDebug(sector,5) * 256
		name = ""
		p = 16
		while self.storage.readDebug(sector,p) != 0:
			name += chr(self.storage.readDebug(sector,p))
			p += 1
		return "{0:5} {2:3} {1:16} Data: {3:5} Total: {4:5}".format("First" if chr(self.storage.readDebug(sector,0)) == 'F' else "Next",
				'"'+name+'"',"Yes" if chr(self.storage.readDebug(sector,1)) == 'Y' else "No",size,total)

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#												Format the storage
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def format(self):
		for sector in range(0,self.storage.getSectorCount()):
			self.storage.eraseSector(sector)

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#											Erase file from file system
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def erase(self,file):
		for sector in range(0,self.storage.getSectorCount()): 					# scan through sectors
			s = self.readHeader(sector) 										# read each header
			if s == file.getName(): 											# if match
				self.storage.eraseSector(sector) 								# erase that sector.

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#											Read file from file system
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def read(self,file):
		pass	

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#											Write file to file system
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def write(self,file):
		firstFlag = True														# is the first record ?
		complete = False  														# done the lot ?
		currSector = random.randint(0,self.storage.getSectorCount()) 			# current potential target sector.

		name = file.getName().lower() 											# file name

		data = file.getData() 													# data to be written.
		dataPos = 0 															# position in data.
		dataRemaining = file.getLength()
		totalSize = dataRemaining

		while not complete: 													# while not complete

			searchStart = currSector 											# find a free sector for the next data.
			while self.isInUse(currSector): 									# if in use
				currSector = (currSector + 1) % self.storage,getSectorCount() 	# goto next
				if currSector == searchStart: 									# not enough sectors
					self.erase(file.getName()) 									# erase the file.
					return False 
			
			self.storage.openWrite(currSector) 									# open sector to write.
			self.storage.write(ord('F' if firstFlag else 'N')) 					# write first or next.

			if dataRemaining > self.storage.getSectorSize()-32: 				# need another page.
				self.storage.write(ord('Y')) 									# Y (there are more)
				dataToWrite = self.storage.getSectorSize()-32  					# bytes to go.
			else:
				self.storage.write(ord('N')) 									# N (no more)
				dataToWrite = dataRemaining 									# output the whole lot.
				complete = True 												# completed.

			self.storage.write(dataToWrite & 0xFF)								# size in block
			self.storage.write(dataToWrite >> 8)

			self.storage.write(totalSize & 0xFF)								# total size in file.
			self.storage.write(totalSize >> 8)

			for a in range(6,16):												# filler to filename.
				self.storage.write(0)

			for c in name:														# output name
				self.storage.write(ord(c))

			for a in range(16+len(name),32):									# filler to 32
				self.storage.write(0)

			for i in range(0,dataToWrite):										# write data out
				self.storage.write(data[dataPos])
				dataPos += 1
				dataRemaining -= 1

			self.storage.endCommand() 											# end write.
			currSector = (currSector + 1) % self.storage.getSectorCount() 		# next sector

		return True

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#												  Read the header
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def readHeader(self,sector):
		self.storage.openRead(sector)
		self.header = []
		for i in range(0,32):
			self.header.append(self.storage.read())
		self.storage.endCommand()
		self.hasData = self.header[0] == ord('F') or self.header[0] == ord('N')	# has data flag.
		if not self.hasData:
			return None
		p = 16
		name = ""
		while self.header[p] != 0:
			name += chr(self.header[p])
			p += 1
		return name 

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#												Is a sector in use ?
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def isInUse(self,sector):
		return self.readHeader(sector) is not None


if __name__ == '__main__':
	fs = FileSystem()
	fs.format()
	f1 = FakeFile(1)
	fs.write(f1)
	f2 = FakeFile(2)
	fs.write(f2)
	fs.dump()
	