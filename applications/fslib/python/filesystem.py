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

			sDesc = "-----" 
			if sType == ord('F') or sType == ord('N'):
				sDesc = self.getSectorInformation(sector)
			if sType == ord('I'):
				sDesc = "Info    Format:{0} Sectors:{1} Size:{2}".format(self.storage.readDebug(sector,1),	\
					self.storage.readDebug(sector,2)+self.storage.readDebug(sector,3)*256, 					\
					1 << self.storage.readDebug(sector,4))

			print("Sector {0:3} E:{2:<4} {1}".format(sector,sDesc,self.storage.getEraseCount(sector)))
	#
	def getSectorInformation(self,sector):
		size = self.storage.readDebug(sector,2) + self.storage.readDebug(sector,3) * 256
		total = self.storage.readDebug(sector,4) + self.storage.readDebug(sector,5) * 256
		name = "".join([chr(self.storage.readDebug(sector,17+n)) for n in range(0,self.storage.readDebug(sector,16))])
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
		self.storage.openWrite(0) 												# Info sector
		self.storage.write(ord('I')) 											# I
		self.storage.write(1)													# Format 1
		self.storage.write(self.storage.getSectorCount() & 0xFF) 				# Sector count
		self.storage.write(self.storage.getSectorCount() >> 8)
		size = self.storage.getSectorSize() 									# 2^n sector size.
		power = 0
		while size != 1:
			size = size >> 1
			power += 1
		self.storage.write(power)
		self.storage.endCommand()

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#											Erase file from file system
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def erase(self,file):
		for sector in range(1,self.storage.getSectorCount()): 					# scan through sectors
			s = self.readHeader(sector) 										# read each header
			if s == file.getName(): 											# if match
				self.storage.eraseSector(sector) 								# erase that sector.

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#											Read file from file system
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def read(self,file,memory,loadAddress):
		file = file.lower().strip() 											# lower case.
		sector = self.readSearch(0,file,'F') 									# search for F record.
		if sector is None:														# not found.
			return False
		#
		complete = False 
		while not complete: 													# not read everything.
			self.readHeader(sector)  											# read sector

			if chr(self.header[1]) == 'N': 										# if found 'N' then this will be the last.
				complete = True  												# we process.

			dataSize = self.header[2] + self.header[3] * 256 					# the amount of data to read.

			self.storage.openRead(sector) 										# now read the sector
			for i in range(0,32): 												# skip the header.
				self.storage.read()

			for i in range(0,dataSize): 										# read the data in.
				memory[loadAddress] = self.storage.read()
				loadAddress += 1
			self.storage.endCommand() 											# finish reading.

			if not complete: 													# still going ?
				sector = self.readSearch(sector,file,'N')

		return True

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#								Search forward for file and sector type, returns sector or None
	#												(always pre-increments)
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def readSearch(self,sector,file,sectorType):		

		checkCount = self.storage.getSectorCount() 								# how many to check, maximum.

		while True: 															# search for it.

			sector += 1 														# move forward once.
			if sector == self.storage.getSectorCount():
				sector = 1

			if checkCount == 0:													# done a complete sweep.
				return None
			checkCount -= 1 													

			if self.readHeader(sector) == file: 								# found the write file
				if chr(self.header[0]) == sectorType:
					return sector

		return sector
	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#											Write file to file system
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def write(self,file):
		firstFlag = True														# is the first record ?
		complete = False  														# done the lot ?
		currSector = random.randint(0,self.storage.getSectorCount()-1) 			# current potential target sector.

		name = file.getName().lower() 											# file name

		data = file.getData() 													# data to be written.
		dataPos = 0 															# position in data.
		dataRemaining = file.getLength()
		totalSize = dataRemaining

		while not complete: 													# while not complete

			searchStart = currSector 											# find a free sector for the next data.
			while self.isInUse(currSector): 									# if in use
				currSector = (currSector + 1) % self.storage.getSectorCount() 	# goto next
				if currSector == searchStart: 									# not enough sectors
					self.erase(file) 											# erase the file.
					return False 
			
			self.storage.openWrite(currSector) 									# open sector to write.
			self.storage.write(ord('F' if firstFlag else 'N')) 					# write first or next.
			firstFlag = False 													# clear first flag

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

			self.storage.write(len(name)) 										# output name length
			for c in name:														# output name
				self.storage.write(ord(c))

			for a in range(16+1+len(name),32):									# filler to 32
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
		if self.header[0] == ord('I'):
			return ""
		if not self.hasData:
			return None		
		name = "".join([chr(self.header[17+n]) for n in range(0,self.header[16])])
		return name 

	# ------------------------------------------------------------------------------------------------------------------------------
	#
	#												Is a sector in use ?
	#
	# ------------------------------------------------------------------------------------------------------------------------------

	def isInUse(self,sector):
		return self.readHeader(sector) is not None


	def save(self,fileName):
		h = open(fileName,"wb")
		h.write(bytes(self.storage.getData()))
		h.close()
		
if __name__ == '__main__':
	fs = FileSystem()
	fs.format()
	f1 = FakeFile(1)
	fs.write(f1)
	f2 = FakeFile(2)
	fs.write(f2)
	fs.dump()

	memory = [ 0 ] * 0x10000
	ok = fs.read(f1.getName(),memory,0x1000)
	print(ok)
	print(f1.check(memory,0x1000))

	ok = fs.read(f2.getName(),memory,0x1000)
	print(ok)
	print(f2.check(memory,0x1000))