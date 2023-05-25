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
		self.idToTokens = {}
		for k in self.tokens.keys():
			self.idToTokens[self.tokens[k]["tokenid"]] = k

	def getUnaryOperators(self):
		return """
			[[STRING]] [[DECIMAL]]
			$ 		(		RAND(	RND(	HEX$(	DEC(	FRAC(	INT(	TIME	EVENT(	INKEY$(
			ASC(	CHR$(	SQR( 	LEN(  	ABS(  	SGN( 	VAL( 	STR$( 	MID$(	LEFT$( 	RIGHT$(
			"""

	def getBinaryOperators(self):
		return """
			+3 	-3 	*4 	/4	>>4 <<4	MOD4	DIV4	AND1 	OR1	XOR1	>2 	>=2	<2	<=2	<>2	 =2
	"""

	def getStructureTokens(self):
		return """
			REPEAT+	UNTIL-	WHILE+ 	WEND-	IF+		ENDIF-	DO+ 	LOOP -
			PROC+ 	ENDPROC-
			FOR+ 	NEXT-
	"""

	def getKeywordTokens(self):
		return  """
			[[END]] [[SHIFT]] 	ELSE	THEN	TO 		STEP	LET 	PRINT	INPUT	CALL 	SYS 	
			REM 	EXIT		, 		; 		: 		' 		)		DIM 	CLEAR	NEW 	RUN 	
			STOP 	END 	ASSERT 	LIST 	SAVE	LOAD	
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
			self.constants[self.textProcess(t)] = self.tokens[t]["tokenid"]
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
		k = k.replace("'","SQUOTE").replace("","").replace("","").replace("","").replace("","")
		#k = k.replace("","").replace("","").replace("","").replace("","").replace("","")
		return k		

	def outputConstants(self,f):
		h = open(f,"w")
		k = [x for x in self.constants.keys()]
		k.sort(key = lambda x:self.constants[x])
		for t in k:
			h.write("PR_{0} = ${1:02x}\n".format(t,self.constants[t]))	
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