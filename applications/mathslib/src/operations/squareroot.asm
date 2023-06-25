; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		squareroot.asm
;		Purpose:	Square Root
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;								Calculate Square Root of R0 
;
; ************************************************************************************************

IFloatSquareRootR0:
		ldx 	#IFR0 						; if zero, return zero.
		jsr 	IFloatCheckZero
		beq 	_IFSRZero

		lda	 	IFR0+IExp 					; if negative fail.
		and 	#IFSign
		bne 	_IFSRFail

		jsr 	IFloatNormalise 			; it will work better !
		;
		ldx 	#IFR1 						; R1 contains original throughout
		jsr 	IFloatCopyToRegister
		;
		lda 	IFR0+IExp 					; if exponent is $2A..$3F * 64 otherwise is / 64
		jsr 	IFMSignExtend 				; sign extended version of the exponent
		clc
		adc 	#23 						; this makes it a 0.xxx mantissa
		sta 	IFR0+IExp
		lsr 	a 							; which we can halve.
		sec 								; convert back
		sbc 	#23 
		and 	#IFXMask 					; make appropriate
		sta 	IFR0+IExp 					; to R0
		;
		jsr 	_IFSRNewton 				
		jsr 	_IFSRNewton
		jsr 	_IFSRNewton
		jsr 	_IFSRNewton

		clc 
		rts

_IFSRZero:
		ldx 	#IFR0
		jsr 	IFloatSetZero
		clc
		rts				
_IFSRFail:
		sec
		rts		

_IFSRNewton:
		ldx 	#IFR1 						; push original value (R3) on the stack
		jsr 	IFloatPushRx
		ldx 	#IFR0 						; push current guess (R0) on the stack.
		jsr 	IFloatPushRx
		ldx 	#IFR1 						; guess = original / guess
		jsr 	IFloatDivideFloat 			
		ldx 	#IFR1 						; restore current guess (was in R0) to R3
		jsr 	IFloatPullRx		
		jsr 	IFloatAdd 					; now guess + original/guess
		ldx 	#IFR0 						; divide by 2
		jsr 	IFloatShiftRight
		ldx 	#IFR1
		jsr 	IFloatPullRx 				; Finally pull the oeifinal
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
