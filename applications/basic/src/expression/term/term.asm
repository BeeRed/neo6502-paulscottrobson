; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		term.asm
;		Purpose:	Term evaluation
;		Created:	25th May 2023
;		Reviewed: 	No
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
		jsr 	EXPTermR0
		bcc 	_ETVNotReference
		.error_unimplemented
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
		bmi 	_ETMIsUnaryOrMinus 			; if it's a token, it's a unary function, maybe -

		iny 								; consume element

		cmp 	#$40 						; 40-7F are identifiers.
		bcs 	_ETMIdentifier

; ------------------------------------------------------------------------------------------------		
;
;						Token 00-3F which can repeat is an integer
;
; ------------------------------------------------------------------------------------------------		

		sta 	IFR0+IM0 					; initial value in IM0
		stz 	IFR0+IExp	
		stz 	IFR0+IM1
		stz 	IFR0+IM2		
_ETMConstant:
		lda 	(codePtr),y 				; what follows.
		cmp 	#$40 						; continuing constant
		bcs 	_ETMCExit 					; no.

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
		jsr 	EXPCheckDecimalFollows 		; check for decimals.
		clc 								; return value
		rts

; ------------------------------------------------------------------------------------------------		
;
;										Handle Identifiers
;
; ------------------------------------------------------------------------------------------------		

_ETMIdentifier:
		.error_unimplemented

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
		clc
		rts

_ETMCheckUnary:
		cmp 	#PR_UNARY_FIRST 			; check unary function.
		bcc 	_ETMUnarySyntax
		cmp 	#PR_UNARY_LAST+1
		bcs 	_ETMUnarySyntax
		asl 	a
		tax
		jsr 	_ETMCallUnaryFunction
		clc
		rts

_ETMCallUnaryFunction:
		jmp 	(VectorTable,x)

_ETMUnarySyntax:
		.error_syntax				

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
;
; ************************************************************************************************

