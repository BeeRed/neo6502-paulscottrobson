# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		makepgm.py
#		Purpose :	Program Builder
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re
from tokeniser import *
from tokens import *

# *******************************************************************************************
#
#								Program Builder
#
# *******************************************************************************************

class ProgramBuilder(object):
	def __init__(self):
		self.codeLines = {} 													# tokenise lines by line number.
		self.tokeniser = TokeniserWorker()
	#
	#		Add line and body
	#
	def addLine(self,lineNumber,body):
		line = [lineNumber & 0xFF,lineNumber >> 8]
		line += self.tokeniser.tokeniseLine(body)
		line.insert(0,len(line)+1)
		if body.strip() == "":
			if lineNumber in self.codeLines:
				del self.codeLines[lineNumber] 
		else:
			self.codeLines[lineNumber] = line
	#
	#		Build program from ident area & tokenised code
	#
	def compose(self):
		program = []
		lineNumbers = [x for x in self.codeLines.keys()]
		lineNumbers.sort()
		for n in lineNumbers:
			program += self.codeLines[n]
		program.append(0)
		return program 

# *******************************************************************************************
#
#									Autorun application
#
# *******************************************************************************************

class Application(object):
	def __init__(self):
		outputFile = "a.out"
		pb = ProgramBuilder()
		lineNumber = 1000
		for f in sys.argv[1:]:
			if f.startswith("-o"):
				outputFile = f[2:]
			else:
				for s in open(f).readlines():
					if not s.startswith("#") and s.strip() != "":
						if s.startswith("."):
							m = re.match("^\\.(\\d+)(.*)$",s)
							assert m is not None,"Can't process "+s
							lineNumber = int(m.group(1))
							s = m.group(2)
						pb.addLine(lineNumber,s)
						lineNumber += 10
		h = open(outputFile,"wb")
		h.write(bytes(pb.compose()))					
		h.close()

if __name__ == '__main__':
	Application()	
