# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		vectors.py
#		Purpose :	Vector code generation
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import sys	

vectors = """
	OSReadDirectory 				: Read file directory.
	OSDeleteFile 					: Delete file
	OSReadFile 						: Read file into memory
	OSWriteFile 					: Write file from memory
	OSFormatFlash 					: Format drive

	OSSetDisplayMode 				: Set display mode (returns old)
	OSGetScreenPosition 			: Screen position to XY
	OSGetScreenSize 				: Get size of screen to XY
	OSWriteString 					: Write length prefixed string YX to screen

	OSEnterLine						: Edit line, return line in YX length prefixed, backspace only editing.
	OSScreenLine 					: Edit line, return line in YX length prefixed, full screen editing.

	OSKeyboardDataProcess 			: Keyboard update process.
	OSCheckBreak					: NZ if ESC pressed.
	OSIsKeyAvailable 				: Check if key available (CS if so)
	OSReadKeystroke 				: Read A from keyboard, display cursor, wait for key.

	OSReadKeyboard 					: Read A from keyboard, CC = success, CS = no key
	OSWriteScreen 					: Write A to screen, CC = success

"""
vectors = [x.strip() for x in vectors.split("\n") if x.strip() != ""]

h1 = open("src/generated/vectors.asmx","w")
h1.write(";\n;\tThis file is automatically generated.\n;\n")
h2 = sys.stdout
h2.write(";\n;\tThis file is automatically generated.\n;\n")

start = 0xFFFA-len(vectors)*3
h1.write("\t* = ${0:04x}\n\n".format(start))
for v in vectors:
	p = [x.strip() for x in v.split(":")]
	h1.write("\tjmp\t\t{0:24} ; {1}\n".format(p[0],p[1]))
	h2.write("{0:24} = ${1:04x} ; {2}\n".format(p[0],start,p[1]))
	start += 3
h1.close()	
h2.close()


