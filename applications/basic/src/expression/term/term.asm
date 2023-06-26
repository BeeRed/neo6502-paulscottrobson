; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		term.asm
;		Purpose:	Term evaluation
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
; 						Evaluate Term as below but dereferences any reference.
;
; ************************************************************************************************

EXPTermValueR0:
		jsr 	EXPTermR0 					; get term
		bcc 	_ETVNotReference 			; exit if value.
		;
		phy
		ldy 	#3 							; get type
		lda 	(IFR0),y
		bmi 	_ETVDereferenceString
		;
		;		Dereference a number
		;
		sta 	IFR0+IExp 					; save byte 3 into R0
		dey 								; get byte 2
		lda 	(IFR0),y
		sta 	IFR0+IM2 					; save byte 2
		dey 								; get byte 1
		lda 	(IFR0),y
		tax 								; save in X so we can overwrite it
		lda 	(IFR0) 						; get byte 0
		stx 	IFR0+IM1  					; save bytes 1 & 0
		sta 	IFR0+IM0
		ply
		clc
		rts

		;
		;		Dereference a string, allowing for case of unintialised (e.g. $0000)
		;
_ETVDereferenceString:		

		ldy 	#1 							; check if it is as yet unassigned.
		lda 	(IFR0),y 					; (e.g. the address is zero)
		ora 	(IFR0)
		beq 	_ETVNull 					; if so, return a fake NULL.
		; 						
		lda 	(IFR0),y 					; load address of string to XA
		tax
		lda 	(IFR0)
		clc 								; add two so points to actual string.
		adc 	#2
		bcc 	_EVDSNoCarry
		inx
_EVDSNoCarry:		
		stx 	IFR0+IM1 					; save in slots
		sta 	IFR0
		bra 	_ETVFillExit 				; tidy up and exit.
		;
		;		Return ""
		;
_ETVNull:
		lda 	#_EVTNString & $FF
		sta 	IFR0+IM0
		lda 	#_EVTNString >> 8
		sta 	IFR0+IM1
		;
		; 		Tidy up
		;
_ETVFillExit:		
		stz 	IFR0+IM2 					; clear byte 2, not strictly required :)
		lda 	#$80 						; set type to string.
		sta 	IFR0+IExp
		ply
		rts
		
_EVTNString: 								; a null string.
		.byte 	0

_ETVNotReference:
		rts

; ************************************************************************************************
;
;						   Evaluate a term into R0 from (codePtr),y
;						   Returns CS if a reference, CC if a value.
;
; ************************************************************************************************

		.section code	

EXPTermR0:
		lda 	(codePtr),y 				; get next token/element
		bmi 	_ETMIsUnaryOrMinus 			; if it's a token $80-$FF, it's a unary function, maybe ....

		iny 								; consume element

		cmp 	#$40 						; 40-7F are identifiers.
		bcs 	_ETMIdentifier  			

; ------------------------------------------------------------------------------------------------		
;
;						Token 00-3F which can repeat is an integer
;
; ------------------------------------------------------------------------------------------------		

		jsr 	EXPExtractTokenisedInteger 	; pull out tokenised integer to R0
		jsr 	EXPCheckDecimalFollows 		; check for decimals.
		clc 								; return value ok
		rts

; ------------------------------------------------------------------------------------------------		
;
;										Handle Identifiers
;
; ------------------------------------------------------------------------------------------------		

_ETMIdentifier:
		jmp 	VARCheckSimple 				; check variables, seperate module.

; ------------------------------------------------------------------------------------------------		
;
;						Handle unary minus and unary functions
;
; ------------------------------------------------------------------------------------------------		

_ETMIsUnaryOrMinus:
		iny 								; consume element
		cmp 	#PR_MINUS 					; handle - seperately as it has two roles.
		bne 	_ETMCheckUnary
		jsr 	EXPTermValueR0 				; get a term to negate
		ldx 	#IFR0 						; and negate it
		jsr 	IFloatNegate  			
		bit 	IFR0+IExp 					; is it a string
		bmi 	_ETMUnaryType				; if so error.
		clc
		rts

_ETMCheckUnary:
		cmp 	#PR_UNARY_FIRST 			; check unary function.
		bcc 	_ETMUnarySyntax
		cmp 	#PR_UNARY_LAST+1
		bcs 	_ETMUnarySyntax
		asl 	a 							; make it into an index => X
		tax
		jsr 	_ETMCallUnaryFunction 		; call the function
		clc 								; and return it.
		rts

_ETMCallUnaryFunction:
		jmp 	(VectorTable,x)

_ETMUnarySyntax:
		.error_syntax				
_ETMUnaryType:
		.error_type				

; ************************************************************************************************
;
;								Pull out sequence of 00-3F to R0
;
; ************************************************************************************************

EXPExtractTokenisedInteger:
		sta 	IFR0+IM0 					; initial value in IM0
		stz 	IFR0+IExp	 				; zero the rest.
		stz 	IFR0+IM1
		stz 	IFR0+IM2		
_ETMConstant:
		lda 	(codePtr),y 				; what follows.
		cmp 	#$40 						; continuing constant
		bcs 	_ETMCExit 					; no, exit.

		ldx 	IFR0+IM2 					; x 256 into A:M2 M1 M0
		lda 	IFR0+IM1
		sta 	IFR0+IM2
		lda 	IFR0+IM0
		sta 	IFR0+IM1
		stz 	IFR0+IM0
		txa

		lsr 	a 							; shift right twice, e.g. whole thing is x 64
		ror 	IFR0+IM2
		ror 	IFR0+IM1
		ror 	IFR0+IM0

		lsr 	a
		ror 	IFR0+IM2
		ror 	IFR0+IM1
		ror 	IFR0+IM0

		lda 	IFR0+IM0 					; LSB in.
		ora 	(codePtr),y
		sta 	IFR0+IM0
		iny 								; consume, loop back
		bra 	_ETMConstant
		
_ETMCExit:
		rts

; ************************************************************************************************
;
;				If followed by a [[DECIMAL]] adjust R0 to floating point value
;
; ************************************************************************************************

EXPCheckDecimalFollows:
		lda 	(codePtr),y 				; check for decimal
		cmp 	#PR_LSQLSQDECIMALRSQRSQ
		bne 	_ETMCDExit

		iny 								; consume token.
		lda 	(codePtr),y 				; get count		
		phy									; save current position
		pha 								; save count of chars.

		sec 								; address into YX : y + codePtr+1
		tya
		adc 	codePtr
		tax
		lda 	codePtr+1
		adc 	#0
		tay
		pla 								; get count.
		jsr 	IFloatAddDecimalToR0 		; add the decimal to R0

		ply 								; go to next token.
		tya
		sec
		adc 	(codePtr),y
		tay

_ETMCDExit:		
		rts

		.send code
				
; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		26/06/23 		-<string> generates a type error.
;
; ************************************************************************************************

