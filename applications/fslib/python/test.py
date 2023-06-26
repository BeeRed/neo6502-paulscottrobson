# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test.py
#		Purpose :	File System test script
#		Date :		26th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,os,re,sys
from fakefile import *
from flash import *
from filesystem import *


if __name__ == '__main__':

	fs = FileSystem()  																	# new file system formatted
	fs.format()

	memory = [ 0 ] * 0x11000 															# for checking

	fObj = [] 																			# create an array of file objects, with a saved flag for each.
	fSaved = []
	for i in range(0,10):
		fObj.append(FakeFile(i))
		fSaved.append(False)

	halt = False
	while not halt:																		# several tests

		sel = random.randint(0,len(fObj)-1) 											# check one to work with

		if fSaved[sel]: 																# if saved, erase it.
			fSaved[sel] = False
			fs.erase(fObj[sel])
			print("Erasing "+fObj[sel].getName())
			if random.randint(0,4) == 0: 												# if erased, occasionally change the data.
				fObj[sel].create()
				print("Changing "+fObj[sel].getName())
		else: 																			# if not saved, save it
			ok = fs.write(fObj[sel])		
			print("Saving "+fObj[sel].getName()+("" if ok else " *FAIL*"))
			if ok:
				fSaved[sel] = True 

		for i in range(0,len(fObj)): 													# validate the state of all
			ok1 = fs.read(fObj[i].getName(),memory,0x1000)
			if fSaved[i]:
				err1 = fObj[i].check(memory,0x1000)
				if not (ok1 and err1 == 0):
					print(t,"*** Verify failed",ok1,err1,fObj[i].getName())
					halt = True
			else:
				if ok1:
					print(t,"*** Erase failed",f.obj[i].getName())
					halt = True

print("")
fs.dump()

	# ok = fs.read(f1.getName(),memory,0x1000)
	# print(ok)
	# print(f1.check(memory,0x1000))

	# ok = fs.read(f2.getName(),memory,0x1000)
	# print(ok)
	# print(f2.check(memory,0x1000))
