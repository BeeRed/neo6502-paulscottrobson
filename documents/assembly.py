import random

def rol(n):
	return (n << 1) + (0 if (n & 0x80) == 0 else 1)

opcodes = """
	ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL BRA BRK BVC BVS CLC CLD CLI CLV CMP CPX CPY DEC DEX DEY EOR INC INX INY JMP	
	JSR LDA LDX LDY LSR NOP ORA PHA PHP PHX PHY PLA PLP PLX PLY ROL ROR RTI RTS SBC SEC SED SEI STA STX STY STZ TAX TAY
	TSX TXA TXS TYA BBS BBR SMB SMR WAI STP"""

opcodes = opcodes.strip().split()

charValues = {}
usedConstants = {}
for c in "".join(opcodes):
	if c not in charValues:
		n = random.randint(0,25)
		while n in usedConstants:
			n = random.randint(0,25)
		usedConstants[n] = True
		charValues[c] = n 

print(charValues)

for attempts in range(0,1000000):
	multiplier = random.randint(2,31)
	additive = random.randint(0,255)
	xor = random.randint(0,255)
	mask = 255

	used = {}	

	for opc in opcodes:
		values = [c for c in opc.upper()]												# characters
		values = [ord(c) - 65 for c in values]
		#values = [charValues[a] for a in values]										# translated value

		calc = values[0]
		calc = (calc * multiplier + additive ) & 0xFF
		calc = (calc + values[1]) & 0xFF
		calc = rol(calc)
		calc = calc ^ xor
		calc = (calc * multiplier + additive ) & 0xFF
		calc = (calc + values[2]) & 0xFF
		#calc = rol(calc)
		#calc = calc ^ xor
		calc = calc & mask 

		if calc not in used:
			used[calc] = []
		used[calc].append(opc)

	analyse = [ 0 ] * 256
	reject = False
	for x in used.keys():
		analyse[len(used[x])] += 1
		if len(used[x]) > 3:
			reject = True

	if not reject:
		if analyse[2] == 0 and analyse[3] == 0:
			print("x{0} +{1} ^{2} => {3}:1 {4}:2".format(multiplier,additive,xor,	analyse[2],analyse[3]))
