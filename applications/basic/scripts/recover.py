# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		recover.py
#		Purpose :	Recover program from memory dump
#		Date :		4th July 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import sys,os,re,random

def filename(n):
	return "backups"+os.sep+"rescue."+str(n)

dump = [x for x in open("memory.dump","rb").read(-1)]	

start = 0x3800

if dump[start] == 0x05 and dump[start+1] == 0xe8 and dump[start+2] == 0x03 and dump[start+3] == 0x97:
	dump = dump[0x3800:]
	p = 0
	while dump[p] != 0:
		#print(dump[p+1]+dump[p+2]*256)
		p = p + dump[p]
	dump = dump[:p+1]

	bID = 1
	while os.path.isfile(filename(bID)):
		bID += 1

	h = open(filename(bID),"wb")
	h.write(bytes(dump))
	h.close()