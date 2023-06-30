#
#		Check that if you read the table backwards *all* zero page are less than their absolute equivalents.
#		Hence the assembler can work backwards.
#
opcodes = """
BRK ,ORA izx ,,,TSB zp ,ORA zp ,ASL zp ,RMB zp ,PHP ,ORA imm ,ASL ,,TSB abs ,ORA abs ,ASL abs ,BBR zpr 
BPL rel ,ORA izy ,ORA izp ,,TRB zp ,ORA zpx ,ASL zpx ,RMB zp ,CLC ,ORA aby ,INC ,,TRB abs ,ORA abx ,ASL abx ,BBR zpr 
JSR abs ,AND izx ,,,BIT zp ,AND zp ,ROL zp ,RMB zp ,PLP ,AND imm ,ROL ,,BIT abs ,AND abs ,ROL abs ,BBR zpr 
BMI rel ,AND izy ,AND izp ,,BIT zpx ,AND zpx ,ROL zpx ,RMB zp ,SEC ,AND aby ,DEC ,,BIT abx ,AND abx ,ROL abx ,BBR zpr 
RTI ,EOR izx ,,,,EOR zp ,LSR zp ,RMB zp ,PHA ,EOR imm ,LSR ,,JMP abs ,EOR abs ,LSR abs ,BBR zpr 
BVC rel ,EOR izy ,EOR izp ,,,EOR zpx ,LSR zpx ,RMB zp ,CLI ,EOR aby ,PHY ,,,EOR abx ,LSR abx ,BBR zpr 
RTS ,ADC izx ,,,STZ zp ,ADC zp ,ROR zp ,RMB zp ,PLA ,ADC imm ,ROR ,,JMP ind ,ADC abs ,ROR abs ,BBR zpr 
BVS rel ,ADC izy ,ADC izp ,,STZ zpx ,ADC zpx ,ROR zpx ,RMB zp ,SEI ,ADC aby ,PLY ,,JMP iax ,ADC abx ,ROR abx ,BBR zpr 
BRA rel ,STA izx ,,,STY zp ,STA zp ,STX zp ,SMB zp ,DEY ,BIT imm ,TXA ,,STY abs ,STA abs ,STX abs ,BBS zpr 
BCC rel ,STA izy ,STA izp ,,STY zpx ,STA zpx ,STX zpy ,SMB zp ,TYA ,STA aby ,TXS ,,STZ abs ,STA abx ,STZ abx ,BBS zpr 
LDY imm ,LDA izx ,LDX imm ,,LDY zp ,LDA zp ,LDX zp ,SMB zp ,TAY ,LDA imm ,TAX ,,LDY abs ,LDA abs ,LDX abs ,BBS zpr 
BCS rel ,LDA izy ,LDA izp ,,LDY zpx ,LDA zpx ,LDX zpy ,SMB zp ,CLV ,LDA aby ,TSX ,,LDY abx ,LDA abx ,LDX aby ,BBS zpr 
CPY imm ,CMP izx ,,,CPY zp ,CMP zp ,DEC zp ,SMB zp ,INY ,CMP imm ,DEX ,WAI  ,CPY abs ,CMP abs ,DEC abs ,BBS zpr 
BNE rel ,CMP izy ,CMP izp ,,,CMP zpx ,DEC zpx ,SMB zp ,CLD ,CMP aby ,PHX ,STP  ,,CMP abx ,DEC abx ,BBS zpr 
CPX imm ,SBC izx ,,,CPX zp ,SBC zp ,INC zp ,SMB zp ,INX ,SBC imm ,NOP,,CPX abs ,SBC abs ,INC abs ,BBS zpr 
BEQ rel ,SBC izy ,SBC izp ,,,SBC zpx ,INC zpx ,SMB zp ,SED ,SBC aby ,PLX ,,,SBC abx ,INC abx ,BBS zpr 
"""

opcodes = opcodes.strip().replace("\n",",")
opcodes = [x.strip() for x in opcodes.strip().split(",") ]

assert(len(opcodes) == 0x100)

for o1 in range(0,256):
	op = opcodes[o1]
	if op.find("ab") >= 0:	
		zop = op.replace("ab","zp").replace("zps","zp")	
		o2 = 0
		if zop in opcodes:	
			o2 = opcodes.index(zop)
			print("{0}:{1:02x}\t\t{2:7}:{3:02x} {4}".format(op,o1,zop,o2,"Ok" if o1 > o2 else "**FAIL**"))
			assert(o1 > o2)
		else:
			print("{0}:{1:02x} no zero page".format(op,o1))

