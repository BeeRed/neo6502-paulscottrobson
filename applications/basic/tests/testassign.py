# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testassign.py
#		Purpose :	Test unary functions
#		Date :		26th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re,random
from testutils import *

identifiers = []
idValues = {}
for i in range(0,50):
	newID = ""
	for i in range(0,random.randint(1,6)):
		if i % 2 == 0:
			newID += chr(random.randint(65,90))
		else:
			newID += chr(random.randint(48,57))

	if newID not in idValues:
		identifiers.append(newID)

for i in range(0,len(identifiers)*3):
	n1 = TestNumber()
	idn = identifiers[random.randint(0,len(identifiers)-1)]
	idValues[idn] = n1
	print("{0}{1} = {2}".format("let " if random.randint(0,1) == 0 else "",idn,n1.render()))

for i in range(0,len(identifiers)):	
	idn = identifiers[i]
	if idn in idValues:
		v = idValues[idn].render()
		print("assert {0} = {1}".format(idn,v))
