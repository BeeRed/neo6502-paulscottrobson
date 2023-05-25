; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fractional.asm
;		Purpose:	Get Rx Fractional part
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;								Get Fractional Part of R0
;
; ************************************************************************************************

IFloatFractionalR0:
		lda 	IFR0+IExp					; is it integer already ?
		and 	#IFXMask
		beq 	_FIPZero 					; if so, return with zero as no fractional part.
		jsr 	IFloatAbsoluteR0 			; absolute value R9

		ldx 	#IFR0
		jsr 	IFloatNormalise 			; normalise R0

		ldx 	#IFRTemp 					; copy to RTemp
		jsr 	IFloatCopyToRegister
		jsr 	IFloatIntegerR0 			; take integer part of R0		
		ldx 	#IFRTemp 					; subtract
		jsr 	IFloatSubtract
		bra 	_FIPExit
		
_FIPZero:
		ldx 	#IFR0
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
