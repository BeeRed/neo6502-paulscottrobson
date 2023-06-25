; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		normalise.asm
;		Purpose:	Normalise register
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Normalise register X, CS if error.
;
; ************************************************************************************************

IFloatNormalise:
		jsr 	IFloatCheckZero 			; is it zero
		beq 	_IFNExitZero 				; if so exit
		;
_IFNLoop:		
		lda 	IM2,x 						; is it normalised e.g. bits 7/6 are 01
		and 	#$C0
		cmp 	#$40 
		beq 	_IFNExitOkay 				; if so , then we are done.
		;
		lda 	IExp,x 						; check exponent is not -32 already.
		and 	#$3F
		cmp 	#$20 
		beq 	_IFNExitOkay 				; if so, then we cannot normalise any more.
		;
		jsr 	IFloatDecExponent 

		jsr 	IFloatShiftLeft 			; shift mantissa left, e.g. multiply by 2
		bra 	_IFNLoop

_IFNExitZero:		
		jsr 	IFloatSetZero 				; set the result to zero

_IFNExitOkay:		
		clc  								; return with CC.							
		rts

; ************************************************************************************************
;
;		Increment/Decrement exponent, preserving upper bits. Returns the new exponent in A
;
; ************************************************************************************************

IFloatIncExponent:
		lda 	IExp,x
		pha
		and 	#$C0
		sta 	IFXTemp
		pla
		inc 	a
		and 	#$3F
		pha
		ora 	IFXTemp
		sta 	IExp,x
		pla
		rts

IFloatDecExponent:
		lda 	IExp,x
		pha
		and 	#$C0
		sta 	IFXTemp
		pla
		dec 	a
		and 	#$3F
		pha
		ora 	IFXTemp
		sta 	IExp,x
		pla
		rts

		.send 	code

		.section storage
IFXTemp:
		.fill 	1
		.send 	storage		

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

