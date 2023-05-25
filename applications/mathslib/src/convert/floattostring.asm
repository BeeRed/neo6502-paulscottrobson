; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		floattostring.asm
;		Purpose:	Convert float to string, base 10 only
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Convert Float R0 to String. Returns CC ok, YX buffer, A count
;
; ************************************************************************************************

IFloatFloatToStringR0:
		ldx 	#IFR2 						; copy R2 to stack,value to R2
		jsr 	IFloatPushRx
		jsr 	IFloatCopyToRegister

		jsr 	IFloatIntegerR0				; make R0 integer
		lda 	#10 						; base 10.
		jsr 	IFloatIntegerToStringR0 	; do the integer part.
		stz 	IFloatDecimalCount 			; zero the decimal count.

		lda 	IFR2+IExp 					; is integer.
		and 	#IFXMask
		beq 	_IFFSExit

_IFloatFracLoop:
		ldx 	#IFR2 						; R0 = fractional part of R2
		jsr 	IFloatCopyFromRegister
		jsr 	IFloatFractionalR0
		jsr 	IFloatNormalise
		ldx 	#IFR2
		jsr 	IFloatCopyToRegister 		; copy to R2

		ldx 	#IFR2 						; set R2 to 10
		lda 	#10
		jsr 	IFloatSetByte 		

		ldx 	#IFR2						; R0,R2 = R2 * 10
		jsr 	IFloatMultiply

		ldx 	#IFR2
		jsr 	IFloatCopyToRegister

		jsr 	IFloatIntegerR0 			; get integer part of R0

		lda 	IFloatDecimalCount 			; done 5 dp, no more
		cmp 	#3
		beq 	_IFFSExitStripZero

		lda 	IFloatDecimalCount 			; written the DP yet ?
		bne 	_IFloatNotFirst
		lda 	#"." 						; write decimal point
		jsr 	IFloatBufferWrite
_IFloatNotFirst:
		inc 	IFloatDecimalCount

		lda 	IFR0+IM0 					; get digit
		ora 	#"0"						; ASCII
		jsr 	IFloatBufferWrite 			; write to the buffer.
		bra 	_IFloatFracLoop

_IFFSExitStripZero:
		;
		;		Remove trailing zeros, except the last one.
		;
		jsr 	IFloatStripTrailingZeros
_IFFSExit:
		ldx 	#IFR2 						; restore R2
		jsr 	IFloatPullRx
		jsr 	IFloatGetBufferAddress
		clc
		rts
		.send code

		.section storage
IFloatDecimalCount:
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

