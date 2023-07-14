# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tokens.py
#		Purpose :	Raw token collections
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re,random

# *******************************************************************************************
#
#								Base token classes
#
# *******************************************************************************************

class RawTokenClass(object):
	def __init__(self,baseAddress = 0x80):
		self.tokens = {}
		self.lowToken = baseAddress
		self.highToken = 0xFF
		self.idToTokens = None
		self.precedence = {}
		self.structure = {}
		self.constants = {}

		self.append(self.getStructureTokens(),False,"STRUCTURE")
		self.append(self.getKeywordTokens(),False,"STANDARD")
		self.append(self.getBinaryOperators(),True,"BINARY")
		self.append(self.getUnaryOperators(),True,"UNARY")

		self.nextAltToken = 0x80
		self.shift = self.find("[[SHIFT]]")
		for t in self.process(self.getAltKeywordTokens()):
			self.tokens[t] = { "tokenid":self.nextAltToken+(self.shift << 8) }
			self.nextAltToken += 1

		self.idToTokens = {}
		for k in self.tokens.keys():
			self.constants[self.textProcess(k)] = self.tokens[k]["tokenid"]
			self.idToTokens[self.tokens[k]["tokenid"]] = k

		self.header = ";\n;\tThis file is automatically generated.\n;\n"

	def getUnaryOperators(self):
		return """
			[[STRING]] [[DECIMAL]]
			& 		(		RAND(	RND(	HEX$(	DEC(	FRAC(	INT(	TIME	EVENT(	INKEY$(
			ASC(	CHR$(	SQR( 	LEN(  	ABS(  	SGN( 	VAL( 	STR$( 	MID$(	LEFT$( 	RIGHT$(
			PEEK( 	DEEK(
			"""

	def getBinaryOperators(self):
		return """
			+3 	-3 	*4 	/4	>>4 <<4	MOD4	DIV4	AND1 	OR1	XOR1	>2 	>=2	<2	<=2	<>2	 =2
	"""

	def getStructureTokens(self):
		return """
			REPEAT+	UNTIL-	WHILE+ 	WEND-	IF+		ENDIF-	DO+ 	LOOP- 	THEN-
			PROC+ 	ENDPROC-
			FOR+ 	NEXT-
	"""

	def getKeywordTokens(self):
		return  """
			[[END]] [[SHIFT]] 	ELSE	TO 		STEP	LET 	PRINT	INPUT	CALL 	SYS 	
			REM 	EXIT		, 		; 		: 		' 		)		POKE 	DOKE	READ 	DATA 	
			[		]			# 		. 		][
		"""

	def getAltKeywordTokens(self):
		return """
			CLEAR 	NEW 		RUN 	STOP 	END 	ASSERT 	LIST 	SAVE 	LOAD	GOSUB 	GOTO
			RETURN 	RESTORE		DIM		DIR 	ERASE 	RENUMBER OPT 	
		"""

	def append(self,tokenData,topDown,descr):
		if topDown:
			self.constants[descr+"_LAST"] = self.highToken
		else:
			self.constants[descr+"_FIRST"] = self.lowToken

		for t in self.process(tokenData):
			if (t.endswith("+") or t.endswith("-")) and len(t) > 1:
				self.structure[t[:-1]] = -1 if t.endswith("-") else 1
				t = t[:-1]
			if t[-1] >= "0" and t[-1] <= "9":
				self.precedence[t[:-1]] = int(t[-1])
				t = t[:-1]
			self.tokens[t] = { "tokenid": self.highToken if topDown else self.lowToken }
			if topDown:
				self.highToken -= 1
			else:
				self.lowToken += 1

		if topDown:
			self.constants[descr+"_FIRST"] = self.highToken+1
		else:
			self.constants[descr+"_LAST"] = self.lowToken-1

	def process(self,s):
		s = s.replace("\n"," ").replace("\t"," ").split()
		s = [x for x in s if x != ""]
		return s

	def find(self,k):
		return self.tokens[k]["tokenid"] if k in self.tokens else None 

	def getToken(self,id):
		return self.idToTokens[id] if id in self.idToTokens else None

	def textProcess(self,k):
		k = k.replace("+","PLUS").replace("-","MINUS").replace("*","ASTERISK").replace("/","SLASH").replace("=","EQUAL")
		k = k.replace(">","GREATER").replace("<","LESS").replace("$","DOLLAR").replace("(","LPAREN").replace(")","RPAREN")
		k = k.replace("[","LSQ").replace("]","RSQ").replace(",","COMMA").replace(":","COLON").replace(";","SEMICOLON")
		k = k.replace("'","SQUOTE").replace("#","HASH").replace("&","AMPERSAND").replace(".","PERIOD").replace("","")
		#k = k.replace("","").replace("","").replace("","").replace("","").replace("","")
		return k		

	def outputConstants(self,f):
		h = open(f,"w")
		h.write(self.header)
		k = [x for x in self.constants.keys()]
		k.sort(key = lambda x:self.constants[x])
		for t in k:
			h.write("PR_{0} = ${1:02x}\n".format(t,self.constants[t]))	
		h.close()

	def outputPrecedence(self,f):
		h = open(f,"w")
		h.write(self.header)
		h.write("BinaryPrecedence:\n")
		for i in range(self.constants["BINARY_FIRST"],self.constants["BINARY_LAST"]+1):
			h.write("\t.byte\t{0:2}\t; ${1:02x} {2}\n".format(self.precedence[self.idToTokens[i]],i,self.idToTokens[i]))
		h.close()

	def outputStructure(self,f):
		h = open(f,"w")
		h.write(self.header)
		h.write("StructureOffsets:\n")
		for i in range(self.constants["STRUCTURE_FIRST"],self.constants["STRUCTURE_LAST"]+1):
			h.write("\t.byte\t{0:<3}\t; ${1:02x} {2}\n".format(self.structure[self.idToTokens[i]] & 0xFF,i,self.idToTokens[i]))
		h.close()

	def outputVectors(self,fn):
		handlers = {}
		for root,dirs,files in os.walk("src"):
			for f in [x for x in files if x.endswith(".asm")]:
				for s in open(root+os.sep+f).readlines():
					if s.find(";;") >= 0:
						m = re.match("^(.*?)\\:\\s*\\;\\;\\s*\\[(.*?)\\]\\s*$",s)
						assert m is not None,"Bad line "+s
						handlers[m.group(2).upper()] = m.group(1)
		h = open(fn,"w")
		h.write(self.header)
		h.write("VectorTable:\n")	
		for i in range(0x80,0x100):
			t = self.idToTokens[i] if i in self.idToTokens else ""
			x = handlers[t] if t in handlers else "NotImplemented"
			h.write("\t.word\t{0:24} ; ${1:02x} {2}\n".format(x,i,t))

		h.write("AlternateVectorTable:\n")	
		for i in range((self.shift << 8)+0x80,(self.shift << 8)+self.nextAltToken):
			t = self.idToTokens[i] if i in self.idToTokens else ""
			x = handlers[t] if t in handlers else "NotImplemented"
			h.write("\t.word\t{0:24} ; ${1:02x} {2}\n".format(x,i,t))

		h.close()

	def outputText(self,f):
		h = open(f,"w")
		h.write(self.header)
		h.write("StandardTokens:\n")
		for i in range(0x80,0x100):
			if i in self.idToTokens:
				t = self.idToTokens[i]
				t2 = "" if t.startswith("[[") else t
				b = [ord(x) for x in t2]
				b.insert(0,len(b))
				b = ",".join(["${0:02x}".format(n) for n in b])
				h.write("\t.byte\t{0:40}\t; ${1:02x} {2}\n".format(b,i,t.lower()))
			else:
				h.write("\t.byte\t0\t\t\t\t\t\t\t\t\t\t\t; ${0:02x}\n".format(i))
		h.write("\t.byte\t$FF\n")

		h.write("AlternateTokens:\n")
		for i in range((self.shift << 8)+0x80,(self.shift << 8)+self.nextAltToken):
			if i in self.idToTokens:
				t = self.idToTokens[i]
				t2 = "" if t.startswith("[[") else t
				b = [ord(x) for x in t2]
				b.insert(0,len(b))
				b = ",".join(["${0:02x}".format(n) for n in b])
				h.write("\t.byte\t{0:40}\t; ${1:02x} {2}\n".format(b,i,t.lower()))
			else:
				h.write("\t.byte\t0\t\t\t\t\t\t\t\t\t\t\t; ${0:02x}\n".format(i))
		h.write("\t.byte\t$FF\n")
		h.close()

if __name__ == '__main__':
	rt = RawTokenClass()
	if False:
		k = [x for x in rt.idToTokens.keys()]
		k.sort()
		for i in k:
			print(i,rt.idToTokens[i])
		print(rt.structure)
		print(rt.precedence)
		print(rt.constants)
	
	rt.outputConstants("src/generated/token_const.inc")
	rt.outputStructure("src/generated/structure_table.asm")
	rt.outputVectors("src/generated/vector_table.asm")
	rt.outputPrecedence("src/generated/precedence_table.asm")
	rt.outputText("src/generated/token_text.asm")
