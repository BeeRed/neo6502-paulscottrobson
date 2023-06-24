# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		flash.py
#		Purpose :	Flash memory interface
#		Date :		24th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random

# *******************************************************************************************
#
#										Flash class
#
# *******************************************************************************************

class FlashMemory(object):
	def __init__(self,memorySize = 1048576 >> 3,sectorSize = 4096):
		self.sectorSize = sectorSize
		self.sectorCount = memorySize // sectorSize
		self.flashMemory = [ random.randint(0,255) for i in range(0,self.sectorCount * self.sectorSize)]
		self.inCommand = False
	#
	#		Erase a sector. This is the sector erase command (SE) $20
	#		We cannot use the full erase because it may contain firmware.
	#		This is slow (50ms typical) so minimise its use.
	#
	def eraseSector(self,sectorID):
		assert sectorID >= 0 and sectorID < self.sectorCount,"Erase sector : bad sector"
		assert not self.inCommand,"Command in progress"
		addr = self.getSectorAddress(sectorID)
		for i in range(0,self.sectorSize):
			self.flashMemory[addr+i] = 0xFF
	#
	#		Start reading a sector. Equivalent to sending command $03 (READ) to Flash.
	#		(see page 28)
	#
	def openRead(self,sectorID):
		assert sectorID >= 0 and sectorID < self.sectorCount,"Read sector : bad sector"
		assert not self.inCommand,"Command in progress"
		self.address = self.getSectorAddress(sectorID)		
		self.inCommand = 'R'
	#
	#		Read next byte from a sector. In command $03 (READ) mode, requires 8 clocks.
	#
	def read(self):
		assert self.inCommand == 'R',"Not in read command"
		assert self.address < len(self.flashMemory),"Read sector : past end of memory"
		data = self.flashMemory[self.address]
		self.inputAddress += 1
		return data 
	#
	#		Start writing to a sector. Mostly uses $02 (page program) which has to operate in
	#		256 byte chunks, so we will issue new PP commands when the LSB is $00 and end
	#		them when the LSB was $FF previously.
	#
	def openWrite(self,sector):
		assert sectorID >= 0 and sectorID < self.sectorCount,"Write sector : bad sector"
		assert not self.inCommand,"Command in progress"
		self.address = self.getSectorAddress(sectorID)
		self.inCommand = 'W'
	#
	#		Write next byte to a sector. Note mask AND.
	#
	def write(self,data):
		assert self.inCommand == 'W',"Write sector : not opened"
		assert self.address < len(self.flashMemory),"Write sector : past end of memory"
		self.flashMemory[self.address] = self.flashMemory[self.address] & data 
	#
	#		Get address of a sector. May be "fixed" so can start from address other than zero
	#
	def getSectorAddress(self,sector):
		return sector * self.sectorSize
	#
	#		End command
	#
	def endCommand(self):
		assert self.inCommand is not None,"Not in command"
		if self.inCommand == 'W':
			asssert (self.address & 0xFF) == 0,"Closing write not on page boundary."
		self.inCommand = None
	#
	#		*Debugging only* read
	#
	def readDebug(self,sector,offset):
		return self.flashMemory[self.getSectorAddress(sector)+offset]

if __name__ == '__main__':
	fm = FlashMemory()
	#fm.eraseSector(31)
	#print(fm.flashMemory)		