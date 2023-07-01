# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		listpgm.py
#		Purpose :	Program Lister
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re
from tokens import *

# *******************************************************************************************
#
#								Program Lister
#
# *******************************************************************************************

class ProgramLister(object):
	def __init__(self,fileName):
		self.rawtokens = RawTokenClass()
		self.code = [x for x in open(fileName,"rb").read(-1)]
		if len(self.code) >= 0x8000:
			self.code = self.code[0x8000:]
		self.count = 0
		p = 0
		while self.code[p] != 0:
			self.count += 1
			p += self.code[p]
	#
	def getCount(self):
		return self.count
	#
	def getLine(self,n):
		assert n < self.getCount()
		p = 0
		for i in range(0,n):
			p += self.code[p]
		self.s = "{0:<5} ".format(self.code[p+1]+self.code[p+2]*256)
		p += 3
		eoltoken = self.rawtokens.find("[[END]]")
		while self.code[p] != eoltoken:
			p = self.decodeOne(p)
		return self.s
	#
	def decodeOne(self,p):
		t = self.code[p]
		if t < 0x40 or t == self.rawtokens.find("$"):
			if t >= 0x80:
				p += 1
			c = 0 
			while self.code[p] < 0x40:
				c = (c << 6) | self.code[p]
				p = p + 1
			self.add(str(c) if t < 0x40 else "${0:x}".format(c))
			return p
		elif t < 0x80:
			return self.extractIdentifier(p)
		elif t == self.rawtokens.find("[[STRING]]"):
			length = self.code[p+1]
			p = p + 2
			s = '"'
			while length > 0:
				s += chr(self.code[p])
				p += 1
				length -= 1
			self.add(s+'"')
			return p
		elif t == self.rawtokens.find("[[SHIFT]]"):
			self.add(self.rawtokens.getToken((self.code[p] << 8) | self.code[p+1]))
			return p+2
		elif t == self.rawtokens.find("[[DECIMAL]]"):
			s = "".join([chr(self.code[p+2+i]) for i in range(0,self.code[p+1])])
			self.add("."+s)
			return p + 2 + self.code[p+1]
		elif t >= 0x80:
			self.add(self.rawtokens.getToken(t).upper())
		else:
			self.add("[{0:02x}]".format(t))
		return p + 1
	#
	def i2s(self,n):
		s = str(n) if self.nextBase == 10 else "{0:x}".format(n)
		self.nextBase = 10
		return s
	#
	def extractIdentifier(self,p):
		s = ""
		while self.code[p] < 0x7C:
			c = self.code[p]
			s += "abcdefghijklmnopqrstuvwxyz0123456789._"[c-0x40]
			p += 1
		if self.code[p] == 0x7D or self.code[p] == 0x7F:
			s += "$"
		if self.code[p] >= 0x7E:
			s += "("
		self.add(s)
		return p+1
	#
	def add(self,t):
		if self.s != "":
			if self.isalnum(self.s[-1]) and self.isalnum(t[0]):
				self.s += " "
		self.s += t
	#
	def isalnum(self,c):
		c = c.upper()
		return (c >= '0' and c <= '9') or (c >= 'A' and c <= 'Z')

class Application(object):
	def __init__(self):
		for f in sys.argv[1:]:
			pl = ProgramLister(f)
			for i in range(0,pl.getCount()):
				print(pl.getLine(i))

if __name__ == '__main__':
	Application()