# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		maketest.py
#		Purpose :	Create program tests.
#		Date :		18th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re,random
from tokeniser import *
from tokens import *
from makepgm import *

# *******************************************************************************************
#
#								Program Test
#
# *******************************************************************************************

class ProgramTest(object):
	def __init__(self,scalar = 1):
		random.seed()
		self.inputs = []
		self.program = ProgramBuilder()
		self.lines = []
		self.scalar = scalar 
		self.punct = "+-*/<>=()"
		self.tokens = RawTokenClass()
		base = random.randint(1,300)
		step = random.randint(1,15)
		for i in range(0,self.scalar * 10):
			self.lines.append(base + i * step)	
		self.identifiers = []
		for i in range(0,self.scalar * 10):
			self.identifiers.append(self.createIdentifier())

	#
	def add(self,lineNumber,body):
		txt = (str(lineNumber)+" "+body).strip()
		self.inputs.append(txt)
		self.program.addLine(lineNumber,body.strip())
		#print(txt)
	#
	def getLineNumber(self):
		return self.lines[random.randint(0,len(self.lines)-1)]
	#
	def createLines(self):
		for i in range(self.scalar*10):
			if random.randint(0,6) == 0:
				self.add(self.getLineNumber(),"")
			else:
				self.add(self.getLineNumber(),self.createLine())		
	#
	def createLine(self):
		s = ""
		for i in range(0,random.randint(1,30)):
			e = self.createElement()
			if (s != "" and self.isalnum(e[0]) and self.isalnum(s[-1])) or random.randint(0,2) == 0:
				s = s + " "
			s = s + e
		return s
	#
	def isalnum(self,c):
		c = c.upper()
		return (c >= "0" and c <= "9") or (c >= "A" and c <= "Z")
	#
	def createElement(self):
		n = random.randint(0,7)
		n = 4
		if n == 0:
			return str(self.getLineNumber())
		elif n == 1:
			return str(round(random.randint(-1000,1000)/100,2))
		elif n == 2:
			return self.punct[random.randint(0,len(self.punct)-1)]
		elif n == 3:
			return '"'+("".join([chr(random.randint(64,90)) for x in range(0,random.randint(0,8))]))+'"'
		elif n == 4:
			n = 0
			while self.tokens.getToken(n) is None:
				n = random.randint(0x80,0xFF)
			t = self.tokens.getToken(n)
			return self.createElement() if t.startswith("[") or t == "'" or t == "REM" or t == "'" or t == "." else t
		elif n == 5:
			return self.identifiers[random.randint(0,len(self.identifiers))-1]
		else:
			return self.createElement()
	#
	def createIdentifier(self):
		s = ""
		for i in range(0,random.randint(1,6)):
			if i % 2 == 0:
				s += chr(random.randint(65,90))
			else:
				s += chr(random.randint(48,57))
		if random.randint(0,3) == 0:
			if random.randint(0,1) == 0:
				return s+"$"
			else:
				return s+"("
		return s
	#
	def export(self):
		h = open("build/vpython.bin","wb")
		code = pt.program.compose()
		h.write(bytes(code))
		h.close()
		print("Size ",len(code))
		assert len(code) < 0x4000
		h = open("src/program/testing/testrun.incx","w")
		for i in range(0,len(pt.inputs)):
			h.write("\tldx #Line{0} & $FF\n".format(i))
			h.write("\tldy #Line{0} >> 8\n".format(i))
			h.write("\tjsr TOKOneLine\n\n")
		h.close()

		h = open("src/program/testing/testdat.incx","w")
		for i in range(0,len(pt.inputs)):
			h.write("Line{0}:\n".format(i))
			h.write("\t.text '{0}',0\n".format(pt.inputs[i]))
		h.close()

if __name__ == '__main__':
	pt = ProgramTest(1)
	pt.createLines()
	pt.export()
