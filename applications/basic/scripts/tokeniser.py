# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tokeniser.py
#		Purpose :	Tokeniser worker.
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re,random
from tokens import *

# *******************************************************************************************
#
#								Tokeniser Worker Class
#
# *******************************************************************************************

class TokeniserWorker(object):
	def __init__(self):
		self.tokenSet = RawTokenClass()
	#
	#		Tokenise a whole line
	#
	def tokeniseLine(self,s):
		self.tokens = []
		s = s.strip()
		while s != "":
			s = self.tokeniseOne(s).strip()
		self.appendToken("[[END]]")
		return self.tokens
	#
	#		Tokenise one element
	#
	def tokeniseOne(self,s):
		m = re.match("^(\\d+)(.*)$",s)											# decimal constant.
		if m is not None:
			self.appendConstant(int(m.group(1)))
			s = m.group(2)
			if s.startswith('.') and s[1] >= '0' and s[1] <= '9':				# decimal ?
				m = re.match("^\\.(\\d+)(.*)$",s)
				self.appendToken("[[DECIMAL]]")
				self.tokens.append(len(m.group(1)))
				self.tokens += [ord(x) for x in m.group(1)]
				return m.group(2)
			return s
		#
		if s.startswith("&"):													# hex constant
			m = re.match("^\\&([0-9A-Fa-f]*)(.*)",s)							
			assert m is not None
			self.appendToken("&")
			self.appendConstant(0 if m.group(1) == "" else int(m.group(1),16))
			return m.group(2)
		#
		if s.startswith('"'):													# quoted string.
			p = (s[1:]+'"').find('"')
			self.appendToken("[[STRING]]")
			txt = [ord(x) for x in s[1:p+1]]
			self.tokens += [len(txt)] + txt
			return s[p+2:]
		#
		c = s[0].upper()
		if c <= "A" or c >= "Z":												
			if len(s) > 1:
				id = self.tokenSet.find(s[:2])
				if id is not None:
					self.tokens.append(id)
					return s[2:]
			id = self.tokenSet.find(c)
			if id is not None:
				self.tokens.append(id)
				return s[1:]
		#
		m = re.match("^([A-Za-z][A-Z\\_a-z0-9]*)(\\$?)(\\(?)(.*)$",s)		# identifier or text token can end in $ or (, not both
		if m is not None:
			ident = m.group(1).upper()+m.group(2)+m.group(3)
			id = self.tokenSet.find(ident) 										# token check
			if id is not None:
				self.appendToken(ident)
			else: 																# add as new identifier.
				trailerToken = 0x7C if m.group(2) != "$" else 0x7D  			# type identifier 7C-7F
				trailerToken += (2 if m.group(3) == "(" else 0)
				self.appendIdentifier(m.group(1))
				self.tokens.append(trailerToken)
			return m.group(4)

		assert False,"Syntax error "+s
	#
	#		Append identifier, mapped on to 40-65 (A-Z 0-9 ._)
	#
	def appendIdentifier(self,ident):
		for c in ident.upper():
			if c >= "A" and c <= "Z":
				self.tokens.append(ord(c)-ord('A')+0x40)
			if c >= "0" and c <= "9":
				self.tokens.append(int(c)+0x5A)
			if c == "_":
				self.tokens.append(0x64)
	#
	#		Append token for keyword
	#
	def appendToken(self,t):
		id = self.tokenSet.find(t)
		if id >= 0x100:
			self.tokens.append(id >> 8)
		self.tokens.append(id & 0xFF)
	#
	#		Append tokens for constant
	#
	def appendConstant(self,n):
		if n >= 0x40:
			self.appendConstant(n >> 6)
		self.tokens.append(n & 0x3F)

if __name__ == '__main__':
	tw = TokeniserWorker()
	s = '42 &10A "hello" .104 < <= + << &'
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	s = 'asc( list chr$( inkey$('
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	s = ' az09_ d$ egg( fred$('
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	s = '12 522 &7ffc "Hello"5  <= < <> n1 n1$ na1( let if n1$( n1$ :"Bye'
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	s = '.522'
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))	
	s = 'print len("Hello")'
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	s = 'run print save'
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	s = '.cat .137 .hello a.b'
	print(s,"::",",".join(["${0:02x}".format(n) for n in tw.tokeniseLine(s)]))
	