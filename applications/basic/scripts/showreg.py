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
#										Access labels 
#
# *******************************************************************************************

class Labels(object):
	def __init__(self):
		self.labels = {}
		for s in open("build/code.lbl").readlines():
			m = re.match("^(.*?)\\s*\\=\\s*(\\$?)(.*?)\\s*$",s)
			assert m is not None,"Bad line in labels "+s
			self.labels[m.group(1).strip().lower()] = int(m.group(3),16 if m.group(2) == "$" else 10)

	def get(self,l):
		l = l.strip().lower()
		return self.labels[l] if l in self.labels else None 

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
	lbl = Labels()
	n = 0
	while lbl.get("IFR"+str(n)) is not None:
		p = lbl.get("IFR"+str(n))
		f = IFloat24()
		f.isSigned = (mem[p+3] & 0x40) != 0
		f.exponent = mem[p+3] & 0x3F
		f.exponent = f.exponent if f.exponent < 0x20 else f.exponent-64
		f.mantissa = mem[p] + (mem[p+1] << 8) + (mem[p+2] << 16) 
		bt = ",".join(["{0:02x}".format(mem[p+i]) for i in range(0,4)])
#		print("{0:x} {1:x} {2}".format(p,f.mantissa,f.exponent))
		print("Reg {0} [${2:02x}] : {1:<16} {3}".format(n,round(f.get(),7),p,bt))
		n += 1
