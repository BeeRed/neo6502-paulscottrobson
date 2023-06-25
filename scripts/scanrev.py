# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		scanrev.py
#		Purpose :	Scan for review files
#		Date :		24th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,re

names = "january,february,march,april,may,june,july,august,september,october,november,december".split(",")
todo = []
for root,dirs,files in os.walk("applications"):
	for f in files:
		if f.endswith(".py") or f.endswith(".asm") or f.endswith(".inc"):
			cDate = None
			for s in open(root+os.sep+f).readlines():
				if s.startswith(";"):
					s = s.lower()
					if s.find("created") >= 0:
						m = re.search("created\\s*(.*)$",s.replace(":",""))
						assert m is not None,s
						cDate = m.group(1)
						for i in range(0,len(names)):
							cDate = cDate.replace(names[i],"-{0}-".format(i+1))
						cDate = cDate.replace("nd","").replace("rd","").replace("th","").replace("st","").replace(" ","")
						cDate = [int(x) for x in cDate.split("-")]
						cDate = "{0:04}-{1:02}-{2:02}".format(cDate[2],cDate[1],cDate[0])
					if s.find("reviewed") >= 0 and s.find("no") >= 0:
						todo.append("{0:10} : {1}".format(cDate,root+os.sep+f))
todo.sort()					
print("\n".join(todo))
print("\nTotal remaining : {0}\n".format(len(todo)))