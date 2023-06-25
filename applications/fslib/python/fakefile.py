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
		random.seed(id)
		self.data = [None] * 65536
		s = random.randint(0,65535)
		e = random.randint(0,65535) if random.randint(0,15) != 3 else s
		self.fromAddr = min(s,e)
		self.toAddr = max(s,e)
		self.name = "{0}.{1:03}".format("".join([chr(random.randint(0,25)+97) for x in range(0,random.randint(4,8))]),id)
		for a in range(self.fromAddr,self.toAddr):
			self.data[a] = random.randint(0,255)

if __name__ == '__main__':
	for i in range(0,20):
		ff = FakeFile(i)
		print(ff.name,ff.fromAddr,ff.toAddr,ff.fromAddr == ff.toAddr)