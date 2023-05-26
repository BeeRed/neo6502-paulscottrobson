# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showreg.py
#		Purpose :	Show R0-R2
#		Date :		26th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re

# *******************************************************************************************
#
#						IFloat24 class (cut down from maths lib)
#
# *******************************************************************************************

class IFloat24(object):
	#
	#		Return as numeric value
	#
	def get(self):
		if self.exponent == 0:
			v = self.mantissa
		else:
			v = self.mantissa * pow(2,self.exponent)
		return -v if self.isSigned else v

if __name__ == '__main__':

	mem = [x for x in open("memory.dump","rb").read(-1)]

	rCount = 3
	for n in range(0,rCount+1):
		p = 0x0C+n*4
		f = IFloat24()
		f.isSigned = (mem[p+3] & 0x40) != 0
		f.exponent = mem[p+3] & 0x3F
		f.exponent = f.exponent if f.exponent < 0x20 else f.exponent-64
		f.mantissa = mem[p] + (mem[p+1] << 8) + (mem[p+2] << 16) 
		bt = ",".join(["{0:02x}".format(mem[p+i]) for i in range(0,4)])
#		print("{0:x} {1:x} {2}".format(p,f.mantissa,f.exponent))
		print("Reg {0} [${2:02x}] : {1:<16} {3}".format(n if n < rCount else "T",round(f.get(),7),p,bt))

