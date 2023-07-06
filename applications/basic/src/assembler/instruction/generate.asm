; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		generate.asm
;		Purpose:	Scan hash table and generate opcode.
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								Generate machine code
;
; ************************************************************************************************

		.section code

ASGenerateCode:
		phy
		;
		;		So we now have an opcode hash and a mode. We scan forward through the table
		; 		looking for a matching hash and see if the address modes match and/or are
		;		compatible.
		;
		ldx 	#0
_ASGSearch:
		lda 	AssemblerLookup,x 			; check table
		cmp 	ASCurrOpcode 				; do we have a match ?
		bne 	_ASGNoMatch
		phx 								; save X
		txa 								; get the address mode for this instruction
		sta 	ASGOpcode
		jsr 	ASGetModeForOpcode 			; into A.
		jsr 	ASGTryGenerate		 		; try to generate with mode A
		plx
		bcs 	_ASGDone 					; successful :)
_ASGNoMatch:		
		inx 								; keep going.
		bne 	_ASGSearch
		.error_syntax 						; we couldn't find it.

_ASGDone:	
		ply	
		rts

; ************************************************************************************************
;
;						Attempt to generate for current instruction.
;
; ************************************************************************************************

ASGTryGenerate:
		cmp 	ASCurrMode 					; do the modes match ?
		beq 	_ASGMatches 				; yes, we have a result. 
		;
		ldx 	ASCurrMode 					; get the instruction mode.
		cpx 	#AM_ABSOLUTE 				; is it an absolute we can try as ZP
		beq 	_ASGTryZero 				; this works because in the 65C02 all the
		cpx 	#AM_ABSOLUTEX 				; ZP equivalents are before the Absolutes
		beq 	_ASGTryZero 				; numerically.
		cpx 	#AM_ABSOLUTEY
		beq 	_ASGTryZero
		cpx 	#AM_ABSOLUTEI
		beq 	_ASGTryZero
		cpx 	#AM_ABSOLUTEIX
		beq 	_ASGTryZero

_ASGFail:
		clc 								; give up.
		rts		
		;
		;		We have an Absolute Absolute,X or Absolute,Y. We want to see if this 
		;		instruction is the zero page equivalent and we can use it.
		;
_ASGTryZero:		
		and 	#$7F 						; this is the ZP equivalent of A,AX,AY ?
		cmp 	ASCurrMode 					; does that match ?
		bne  	_ASGFail 					; no, this won't work.
		ora 	#$80 						; try with a ZP 
		ldx 	IFR0+IM1 					; check if this is okay for zero page.
		bne 	_ASGFail 					; cannot use as the value is too large (e.g. >256)
		;
		;		We now have a workable address mode in A - we deal with Abs vs ZPage
		;		And relative mode.
		;
_ASGMatches:		
		pha
		jsr 	ASAddress 					; address out.
		lda 	ASGOpcode 					; write opcode
		jsr 	ASWriteByte 				; write a byte
		pla

		cmp 	#AM_IMPLIED 				; dispatch
		beq 	_ASGExit
		cmp 	#AM_RELATIVE
		beq 	_ASGRelative
		cmp 	#0 
		bmi 	_ASGZeroPage
		;
_ASGAbsolute:								; absolute
		lda 	IFR0+IM1
		jsr 	ASWriteByte
_ASGWriteLSB:		
		lda 	IFR0+IM0
		jsr 	ASWriteByte
_ASGExit:	
		jsr 	ASEndLine
		sec	
		rts

_ASGZeroPage: 								; zero page
		lda 	IFR0+IM1 					; check operand
		beq 	_ASGWriteLSB
		.error_value

_ASGRelative: 								; relative
		.debug

		.send code
		.section storage
ASGOpcode:		
		.fill 	1
		.send storage

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

