; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		write.asm
;		Purpose:	Write byte to memory/screen
;		Created:	6th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Write byte to memory and optionally screen
;
; ************************************************************************************************

		.section code

ASWriteByte:
		ldx 	('P'-'A')*4 + FastVariables + 0
		stx 	zTemp0
		ldx 	('P'-'A')*4 + FastVariables + 1
		stx 	zTemp0+1
		sta 	(zTemp0)

		tax
		lda 	ASMOption
		lsr 	a
		bcc 	_ASWBNoEcho
		lda 	#32
		jsr 	OSWriteScreen
		txa
		jsr 	ASPrintHex
_ASWBNoEcho:

		inc 	('P'-'A')*4 + FastVariables + 0
		bne 	_ASWBNoCarry
		inc 	('P'-'A')*4 + FastVariables + 1
_ASWBNoCarry:
		rts

; ************************************************************************************************
;
;									Write out address stuff
;
; ************************************************************************************************

ASAddress:
		lda 	ASMOption
		lsr 	a
		bcc 	_ASAExit
		lda 	('P'-'A')*4 + FastVariables + 1
		jsr 	ASPrintHex
		lda 	('P'-'A')*4 + FastVariables + 0
		jsr 	ASPrintHex
		lda 	#32
		jsr 	OSWriteScreen
		lda 	#':'
		jsr 	OSWriteScreen
_ASAExit:		
		rts

; ************************************************************************************************
;
;									Write EOL for assembly
;
; ************************************************************************************************

ASEndLine:
		lda 	ASMOption
		lsr 	a
		bcc 	_ASEExit
		lda 	#13
		jsr 	OSWriteScreen
_ASEExit:		
		rts

; ************************************************************************************************
;
;										Write A as 2 hex digits.
;
; ************************************************************************************************

ASPrintHex:		
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_ASPrintNibble
		pla
_ASPrintNibble:
		and 	#15
		cmp 	#10
		bcc 	_ASNotHex
		adc 	#6
_ASNotHex:
		adc 	#48
		cmp 	#64
		bcc 	_ASNotChar
		eor 	#32
_ASNotChar:		
		jmp 	OSWriteScreen

		.send code

		
; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************

