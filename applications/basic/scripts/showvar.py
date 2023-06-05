# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showvar.py
#		Purpose :	Show Variable lists
#		Date :		31st May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re
from showreg import *

def read(a):
	return memory[a]
	
def dRead(a):
	return memory[a] + (memory[a+1] << 8) 

def qRead(a):
	return memory[a] + (memory[a+1] << 8) + (memory[a+2] << 16) + (memory[a+3] << 24)

def toString(n):
	if (n & 0x80000000) != 0:
		return toStringString(n)
	return toStringNumber(n)

def toStringNumber(n):
	f = IFloat24()
	f.mantissa = n & 0xFFFFFF
	f.exponent = (n >> 24) & 0x3F
	f.exponent = f.exponent if f.exponent < 0x20 else f.exponent-64
	f.isSigned = (n & 0x40000000) != 0
	if f.exponent == 0:
		return "{0} ${0:x}".format(-f.mantissa if f.isSigned else f.mantissa)
	else:
		return "{0}".format(round(f.get(),3))

def toStringString(n):
	sa = n & 0xFFFF
	if sa == 0:
		return '"" (Null)'
	max = dRead(sa)
	s = ""
	for i in range(0,memory[sa+2]):
		s += chr(memory[sa+3+i])
	return "\"{0}\" @${1:04x}[{2}]".format(s,sa,max)

def convert(c):
	if c < 26:
		return c + 65
	if c < 36:
		return c - 26 + 48
	return ord("_") if c == 36 else ord(".")

labels = Labels()
memory = [x for x in open("memory.dump","rb").read(-1)]

for i in range(0,26):
	fast = labels.get("FastVariables")+i*4
	val = qRead(fast)
	if val != 0:
		print("{0} [${1:04x}] = {2}".format(chr(i+97),fast,toString(val)))
print()

htSize = labels.get("VARHashEntriesPerType")
postfix = [ "","$","()","$()"]

def dumpArray(m,lv):
	ts = "\t" * (lv + 3)
	sz = dRead(m)
	if (sz & 0x8000) != 0:
		for i in range(0,sz & 0x7FFF):
			p = m + 2 + i * 2
			s = "[{0:2}] @ ${1:04x} ".format(i,p)
			print(ts+s)
			dumpArray(dRead(p),lv+1)
	else:
		for i in range(0,sz):
			p = m + 2 + i * 4
			s = "[{0:2}] @ ${1:04x} = {2}".format(i,p,toString(qRead(p)))
			print(ts+s)

for g in range(0,4):		
	for t in range(0,htSize):
		head = (g * htSize + t) * 2 +labels.get("VARHashTables")
		hv = dRead(head)
		if hv != 0:
			name = "Number" if (g & 1) == 0 else "String"
			name = name if (g & 2) == 0 else name+" Array"
			print("{0:<11} Table:{1:2} : ${2:04x}".format(name,t,head))
			while hv != 0:
				name = ""
				na = dRead(hv+3)
				while memory[na] < 0x7C:
					name += chr(convert(memory[na] & 0x3F))
					na += 1
				isProc = read(hv+8) == 0xFF
				v = toString(qRead(hv+5)) if g < 2 else ("(procedure @${0:04x}.${1:02X})".format(dRead(hv+5),read(hv+7)) if isProc else "(array)")
				s = "{3:<12} @${0:04x} [#${2:02x}] = {1}".format(hv,v,memory[hv+2],name.lower()+postfix[g])
				print("\t"+s)
				if not isProc and g >= 2:
					dumpArray(dRead(hv+5),0)
				hv = dRead(hv)
			print()