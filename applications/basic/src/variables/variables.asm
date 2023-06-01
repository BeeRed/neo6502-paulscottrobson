; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		variables.asm
;		Purpose:	Check for simple variables, then complex.
;		Created:	29th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Check for simple variables
;
; ************************************************************************************************

		.section code

VARCheckSimple:
		tax 								; save in X
		lda 	(codePtr),y
		cmp 	#$7C 		
		bne 	_VCSComplex
		;
		iny 								; consume the second byte, the type.
		txa  								; character (40-7F) x 4
		asl 	a
		asl  	a
		clc
		adc 	#FastVariables & $FF
		sta 	IFR0+IM0
		lda 	#FastVariables >> 8
		adc 	#0
		sta 	IFR0+IM1
		stz 	IFR0+IM2
		stz 	IFR0+IExp
		sec 								; it's a reference
		rts
		;
_VCSComplex:
		dey	 								; extract information.
		jsr 	VARGetInfo
		jsr 	VARFind 					; search for variable
		bcs 	_VCSHaveVariable
		lda 	VARType 					; error if arrays, cannot autocreate
		and 	#2
		bne 	_VCNoCreate
		jsr 	VARCreate 					; create variable
_VCSHaveVariable:							; address of data part of variable is in XA.
	
		pha 								; save LSB on the stack
		lda 	VARType 					; get var type, and shift bit 1 into carry
		ror 	a
		ror 	a
		pla 								; restore LSB
		bcc 	_VCSNotArray 				; skip if not an array
			
		jsr 	VARArrayLookup 				; look for subscripts.
		pha 								; check )
		jsr 	ERRCheckRParen
		pla
		
_VCSNotArray:		

		stx 	IFR0+IM1 					; save address
		sta 	IFR0+IM0
		stz 	IFR0+IM2 					; clear the unused byte.
		;
		lda 	VARType 					; number/string bit into carry
		ror 	a
		lda 	#0
		ror 	a 							; now $00 or $80
		sta 	IFR0+IExp

		sec 								; it's a reference
		rts

_VCNoCreate:
		.error_uninitialised
				
		.send code
		
		.section storage
FastVariables: 								; 26 A-Z variables
		.fill	26*4
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

