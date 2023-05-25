# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testmake.py
#		Purpose :	Create the test file.
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re,random

def getNumber():
	if random.randint(0,1) == 0:
		return random.randint(-100000,100000)/100
	return random.randint(-10000,10000)

def compare(n1,n2):
	if n1 != n2:
		return -1 if n1 < n2 else 1
	return 0

def generate(n1,n0,r,opcode,errPC,useAsIs = True):
	if n1 == int(n1) and n0 == int(n0) and not useAsIs:
		errPC = 0
	error = abs(r *errPC / 100)

	print("lci\tr1,"+str(n1))
	print("lci\tr0,"+str(n0))
	print("{0}\tr1".format(opcode))
	print("lci\tr1,"+str(r))
	print("sub\tr1")
	print("lci\tr1,{0:.9f}".format(error))
	print("chk\n")

def generateUnary(n,r,opcode,errPC):
	error = abs(r *errPC / 100)
	print("lci\tr0,"+str(n))
	print("{0}".format(opcode))
	print("lci\tr1,"+str(r))
	print("sub\tr1")
	print("lci\tr1,"+str(error))
	print("chk\n")

for i in range(0,60):
	v1 = getNumber()
	v2 = getNumber()

	if True:
		#
		#		Simple tests
		#
		generate(v1,v2,v1+v2,"add",0.01)
		generate(v1,v2,v1-v2,"sub",0.01)	
		generate(v1,v2,v1*v2,"mul",0.01,abs(v1*v2) >= 0x800000)	
		#
		#		Integer division.
		#
		i1 = int(v1)
		i2 = int(v2)
		if i2 != 0 and i1 != 0:
			r = int(math.floor(abs(i1) // abs(i2)))
			r = -r if i1*i2 < 0 else r
			generate(i1,i2,r,"idv",0)
		#
		#		Float division.
		#
		if v2 != 0 and v1/v2 > 0.1 and v1/v2 < 100000.0:
				generate(v1,v2,v1/v2,"div",0.01,True)
		#
		#		Comparisons.
		#
		if random.randint(0,3) == 0:
			generate(v1,v1,0,"cmp",0)
		else:
			c = abs(v1-v2) / (abs(v1)+abs(v2))  	# keep numbers far apart to avoid issues with close zero.
			if c > 0.01:
				generate(v1,v2,compare(v1,v2),"cmp",0)
		#
		#		Int/Frac
		#
		n = int(abs(v1)) * (-1 if v1 < 0 else 1)
		generateUnary(v1,n,"int",0)
		generateUnary(v1,abs(v1)-int(abs(v1)),"frc",0.2)
		#
		#		Bitwise operations.
		#
		i1 = int(abs(v1))
		i2 = int(abs(v2))
		generate(i1,i2,i1 & i2,"and",0)
		generate(i1,i2,i1 | i2,"orr",0)
		generate(i1,i2,i1 ^ i2,"xor",0)
		#
		#		Square root
		#
		v3 = abs(v1)
		generateUnary(v3,math.sqrt(v3),"sqr",0.01)
