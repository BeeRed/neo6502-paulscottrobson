# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		ifloat.py
#		Purpose :	IFloat processing class
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re

# *******************************************************************************************
#
#										IFloat24 class
#
# *******************************************************************************************

class IFloat24(object):
	def __init__(self,default = 0):
		self.set(default)
	#
	#		Return as numeric value
	#
	def get(self):
		if self.exponent == 0:
			v = self.mantissa
		else:
			v = self.mantissa * pow(2,self.exponent)
		return -v if self.isSigned else v
	#
	#		Return as bytes
	#
	def getBytes(self):
		exponent = (self.exponent & 0x3f) + (0x40 if self.isSigned else 0x00)
		return [self.mantissa & 0xFF,(self.mantissa >> 8) & 0xFF,(self.mantissa >> 16) & 0xFF,exponent]
	#
	#		Return as assembler
	#
	def getAssembler(self):
		return "\t.byte\t{0} ; {1}".format(",".join(["${0:02x}".format(n) for n in self.getBytes()]),self.toString())
	#
	#		Return as string
	#
	def toString(self):
		v = round(self.get(),5)
		return str(v)
	#
	#		Get all information
	#
	def info(self):
		return "{0} ({1}${2:06x}.2^{3})".format(self.toString(),"-" if self.isSigned else "+",self.mantissa,self.exponent)
	#
	#		Set float
	#
	def set(self,v):	
		self.isSigned = (v < 0)
		v = abs(v)
		if v == int(v) and v <= 0x7FFFFF:
			self.mantissa = int(v)
			self.exponent = 0 
		else:
			self.exponent = int(math.floor(math.log(v,2)) - 22)
			self.exponent = max(self.exponent,-16)
			self.mantissa = int(round(v / pow(2,self.exponent)))
			assert self.mantissa > 0 and self.mantissa < 0x800000
			assert self.exponent >= -32 and self.exponent < 31
	#
	#		Normalise float
	#
	def normalise(self,force = False):
		while (self.mantissa != 0 or force) and self.mantissa < 0x400000 and self.exponent > -32:
			self.exponent -= 1 
			self.mantissa = self.mantissa << 1
		return self 
	#
	#		Shift to given exponent
	#
	def shiftTo(self,e):
		assert e >= self.exponent
		while e != self.exponent:
			self.mantissa = self.mantissa >> 1
			self.exponent += 1

if __name__ == '__main__':
	if False:
		print(IFloat24(42.0).getBytes())

		for n in [0,42,-42000,0x7FFFFF0,123456789,22/7]:
			v = IFloat24(n)
			print(n,v.get(),v.getBytes(),v.getAssembler(),v.toString())
			v = v.normalise()
			print(n,v.get(),v.getBytes(),v.getAssembler(),v.toString())

	mem = [x for x in open("memory.dump","rb").read(-1)]

	rCount = 4
	for n in range(0,rCount+1):
		p = 0x08+n*4
		f = IFloat24()
		f.isSigned = (mem[p+3] & 0x40) != 0
		f.exponent = mem[p+3] & 0x3F
		f.exponent = f.exponent if f.exponent < 0x20 else f.exponent-64
		f.mantissa = mem[p] + (mem[p+1] << 8) + (mem[p+2] << 16) 
		bt = ",".join(["{0:02x}".format(mem[p+i]) for i in range(0,4)])
#		print("{0:x} {1:x} {2}".format(p,f.mantissa,f.exponent))
		print("Reg {0} [${2:02x}] : {1:<16} {3}".format(n if n < rCount else "T",round(f.get(),7),p,bt))

