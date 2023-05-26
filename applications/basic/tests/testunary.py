# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testunary.py
#		Purpose :	Test unary functions
#		Date :		26th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re,random
from testutils import *

def sign(n):
	if n == 0:
		return 0 
	return -1 if n < 0 else 1

uc = UnaryChecker()
for i in range(0,40):
	n1 = TestNumber()
	s1 = TestString()
	uc.generate(n1,"abs",abs(n1.get()))
	uc.generate(s1,"len",len(s1.get()))
	uc.generate(n1,"sgn",sign(n1.get()))
	fn1 = abs(n1.get())
	uc.generate(n1,"frac",fn1-math.floor(fn1))
	in1 = math.floor(abs(n1.get()))
	in1 = in1 if n1.get() > 0 else -in1
	uc.generate(n1,"int",in1)
	n1 = TestNumber().absolute()
	uc.generate(n1,"sqr",math.sqrt(n1.get()),0.5)
	uc.generate(s1,"asc",ord(s1.get()[0]) if len(s1.get()) != 0 else 0)
	h1 = TestHexNumber(True).absolute()
	uc.generate(h1,"dec",h1.get())
	sc1 = TestNumberString()
	uc.generate(sc1,"val",sc1.get())
