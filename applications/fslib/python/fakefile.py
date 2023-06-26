# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		fakefile.py
#		Purpose :	Pretend file for testing.
#		Date :		24th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random

# *******************************************************************************************
#
#										Fake file object
#
# *******************************************************************************************

class FakeFile(object):
	def __init__(self,id):
		self.name = "{0}.{1:03}".format("".join([chr(random.randint(0,25)+97) for x in range(0,random.randint(4,8))]),id)
		self.create()
	#
	def create(self):
		self.data = [random.randint(0,255) for x in range(0,65536)]
		s = random.randint(0,45535)
		e = random.randint(25535,65535) if random.randint(0,15) != 3 else s
		self.fromAddr = min(s,e)
		self.toAddr = max(s,e)
	#
	def getName(self):
		return self.name
	#
	def getData(self):
		return self.data[self.fromAddr:self.toAddr]
	#
	def getLength(self):
		return self.toAddr - self.fromAddr
	#
	def check(self,memorySpace,offset):
		errors = 0
		for i in range(self.fromAddr,self.toAddr):
			if memorySpace[offset] != self.data[i]:
				errors += 1
			offset += 1
		return errors

if __name__ == '__main__':
	for i in range(0,20):
		ff = FakeFile(i)
		d = ff.getData()
		print(ff.name,ff.fromAddr,ff.toAddr,ff.fromAddr == ff.toAddr,len(d))
		if len(d) != 0:
			print(ff.check(d,0))