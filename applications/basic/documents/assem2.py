# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		assem2.py
#		Purpose :	Create the assembler LUT
#		Date :		30th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import sys

# *******************************************************************************************
#
#							This is an 8 bit rotate left
#
# *******************************************************************************************
def rol(n):
	return (n << 1) + (0 if (n & 0x80) == 0 else 1)

# *******************************************************************************************
#
#								Convert opcode to hash
#
# *******************************************************************************************

def hash(op,trace = False):
	multiplier = 5
	additive = 68
	xor = 165

	values = [ord(c)-ord('A') for c in op.upper()]
	calc = values[0]
	calc = (calc * multiplier + additive ) & 0xFF
	if trace:
		print(";{0:02x}".format(calc))
	calc = (calc + values[1]) & 0xFF
	if trace:
		print(";{0:02x}".format(calc))
	calc = rol(calc)
	if trace:
		print(";{0:02x}".format(calc))
	calc = calc ^ xor
	if trace:
		print(";{0:02x}".format(calc))
	calc = (calc * multiplier + additive ) & 0xFF
	if trace:
		print(";{0:02x}".format(calc))
	calc = (calc + values[2]) & 0xFF
	if trace:
		print(";{0:02x}".format(calc))
	calc = calc & 0xFF
	return calc



print(hash("AND"))