
def rol(n):
	return (n << 1) + (0 if (n & 0x80) == 0 else 1)

opcodes = """
	ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL BRA BRK BVC BVS CLC CLD CLI CLV CMP CPX CPY DEC DEX DEY EOR INC INX INY JMP	
	JSR LDA LDX LDY LSR NOP ORA PHA PHP PHX PHY PLA PLP PLX PLY ROL ROR RTI RTS SBC SEC SED SEI STA STX STY STZ TAX TAY
	TSX TXA TXS TYA BBS BBR SMB SMR WAI STP"""

opcodes = opcodes.strip().split()

mapping = [ None ] * 256

multiplier = 5
additive = 68
xor = 165

for op in opcodes:

	values = [ord(c)-ord('A') for c in op]

	calc = values[0]
	calc = (calc * multiplier + additive ) & 0xFF
	calc = (calc + values[1]) & 0xFF
	calc = rol(calc)
	calc = calc ^ xor
	calc = (calc * multiplier + additive ) & 0xFF
	calc = (calc + values[2]) & 0xFF

	assert mapping[calc] is None,op
	mapping[calc] = op

print(len([x for x in mapping if x is not None]))
print(len(opcodes))