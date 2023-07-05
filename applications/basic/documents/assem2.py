#
#	Another idea for packing ; doesn't work.
#
opcodes = """
	ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL BRA BRK BVC BVS CLC CLD CLI CLV CMP CPX CPY DEC DEX DEY EOR INC INX INY JMP	
	JSR LDA LDX LDY LSR NOP ORA PHA PHP PHX PHY PLA PLP PLX PLY ROL ROR RTI RTS SBC SEC SED SEI STA STX STY STZ TAX TAY
	TSX TXA TXS TYA BBS BBR SMB SMR WAI STP"""

opcodes = opcodes.strip().split()

chars = [ {},{},{} ]

for op in opcodes:
	for i in range(0,3):
		chars[i][op[i]] = True 

chars = [ "".join([c for c in x.keys()]) for x in chars]

for i in range(0,3):
	print("{0} {1:2} {2}".format(i,len(chars[i]),chars[i]))

c1 = [len(n) for n in chars]
print(c1[0] * c1[1] * c1[2])	