# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		checktest.py
#		Purpose :	Check editing/tokenisation results
#		Date :		29th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import sys

def checkList(d1,d2,p1,p2):
	errors = 0
	print("Scanning from ${0:04x} ${0:04x}".format(p1,p2))
	eCount = 0
	while d1[p1] != 0:
		print("{0:04x} {1:04x} {2} {3}".format(p1,p2,d1[p1],d2[p2]))
		assert d1[p1] == d2[p2]
		eCount += 1
		for i in range(0,d1[p1]):
			if d1[p1+i] != d2[p2+i]:
				errors += 1
				print("\t\tOffset {0:2} ${0:04x} : Python {1:3} Asm {2:3}".format(p1,d1[p1+i],d2[p2+i]))
		p1 = p1 + d1[p1]
		p2 = p2 + d2[p2]
		#print("{0:x} {1:x} {2:x} ".format(l1[p],l2[p],p))
	print("\tScanned {0} element pairs to ${1:04x} ${2:04x}".format(eCount,p1,p2))
	return errors

vpy = [x for x in open("build/vpython.bin","rb").read(-1)]

vas = [x for x in open("memory.dump","rb").read(-1)][0x6000:]

e = checkList(vpy,vas,0,0)

print("\nErrors",e)
if e != 0:
	sys.exit(1)