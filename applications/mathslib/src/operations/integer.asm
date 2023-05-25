; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		integer.asm
;		Purpose:	Make Rx Integer
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;									Make R0 into an integer
;
; ************************************************************************************************

IFloatIntegerR0:
		lda 	IFR0+IExp					; is it integer already ?
		and 	#IFXMask
		beq 	_FIPExit 					; if so do nothing
		ldx 	#IFR0
		jsr 	IFloatNormalise 			; normalise
		jsr 	IFloatCheckZero 			; is it zero ?
		beq 	_FIPZero 					; if so return zero.
_FIPShift:
		lda 	IFR0+IExp 					; if Exponent >= 0 exit.
		and 	#$20 						; still -ve
		beq 	_FIPExit
		jsr 	IFloatShiftRight 			; shift mantissa right
		jsr 	IFloatIncExponent 			; bump exponent 
		bra 	_FIPShift
_FIPZero:
		jsr 	IFloatSetZero
_FIPExit:
		clc		
		rts		

		.send 	code

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
