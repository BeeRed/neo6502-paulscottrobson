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
		self.inputAddress = None
		self.outputAddress = None
	#
	#		Erase a sector. This is the sector erase command (SE) $20
	#		We cannot use the full erase because it may contain firmware.
	#		This is slow (50ms typical) so minimise its use.
	#
	def eraseSector(self,sectorID):
		assert sectorID >= 0 and sectorID < self.sectorCount,"Erase sector : bad sector"
		assert self.inputAddress is None,"Read sector not completed"
		assert self.outputAddress is None,"Write sector not completed"
		addr = self.getSectorAddress(sectorID)
		for i in range(0,self.sectorSize):
			self.flashMemory[addr+i] = 0xFF
	#
	#		Start reading a sector. Equivalent to sending command $03 (READ) to Flash.
	#		(see page 28)
	#
	def openRead(self,sectorID):
		assert sectorID >= 0 and sectorID < self.sectorCount,"Read sector : bad sector"
		assert self.outputAddress is None,"Write sector not completed"
		self.inputAddress = self.getSectorAddress(sectorID)		
	#
	#		End reading a sector. Equivalent to driving CS# high.
	#
	def closeRead(self):
		assert self.inputAddress is not None,"Close Read sector : not opened"
		self.inputAddress = None
	#
	#		Read next byte from a sector. In command $03 (READ) mode, requires 8 clocks.
	#
	def read(self):
		assert self.inputAddress is not None,"Read sector : not opened"
		assert self.inputAddress < len(self.flashMemory),"Read sector : past end of memory"
		data = self.flashMemory[self.inputAddress]
		self.inputAddress += 1
		return data 
	#
	#		Start writing to a sector. Mostly uses $02 (page program) which has to operate in
	#		256 byte chunks, so we will issue new PP commands when the LSB is $00 and end
	#		them when the LSB was $FF previously.
	#
	def openWrite(self,sector):
		assert sectorID >= 0 and sectorID < self.sectorCount,"Write sector : bad sector"
		assert self.inputAddress is None,"Read sector not completed"
		self.outputAddress = self.getSectorAddress(sectorID)
	#
	#		Writes are closed by driving CS# high ending the current PP.
	#
	def closeWrite(self):
		assert self.outputAddress is not None,"Close Write sector : not opened"
		self.outputAddress = None
	#
	#		Write next byte to a sector. Note mask AND.
	#
	def write(self,data):
		assert self.outputAddress is not None,"Write sector : not opened"
		assert self.outputAddress < len(self.flashMemory),"Write sector : past end of memory"
		self.flashMemory[self.outputAddress] = self.flashMemory[self.outputAddress] & data 
	#
	#		Get address of a sector. May be "fixed" so can start from address other than zero
	#
	def getSectorAddress(self,sector):
		return sector * self.sectorSize

if __name__ == '__main__':
	fm = FlashMemory()
	fm.eraseSector(31)
	print(fm.flashMemory)