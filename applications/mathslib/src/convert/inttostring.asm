; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		inttostring.asm
;		Purpose:	Convert integer to string, base 2..16
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;			Convert Integer R0 to String, uses R1. Returns CC ok, YX buffer, A count
;
; ************************************************************************************************

IFloatIntegerToStringR0:
		sta 	IFBase 						; save base to use.

		jsr 	IFloatBufferReset			; empty buffer

		lda 	IFR0+IExp					; check integer, cant't convert float
		and 	#IFXMask
		bne 	_IFIFail
		;
		;		Output - sign if -ve
		;
		ldx 	#IFR0 						; skip - check if zero.
		jsr 	IFloatCheckZero
		beq 	_IFINotNegative
		lda 	IFR0+IExp 					; is signed ?
		and 	#IFSign
		beq 	_IFINotNegative
		lda 	#"-"						; output -
		jsr 	IFloatBufferWrite
		jsr 	IFloatNegate 				; negate the value, e.g. make it +ve.
_IFINotNegative:
		jsr 	_IFIRecursiveConvert 		; start converting
		jsr 	IFloatGetBufferAddress 		; get the return address and exit
		clc
		rts

_IFIFail:
		sec
		rts		

; ************************************************************************************************
;
;								Classic recursive integer conversion
;
; ************************************************************************************************

_IFIRecursiveConvert:
		ldx 	#IFR1		
		jsr 	IFloatCopyToRegister 		; R0->R1
		ldx 	#IFR0
		lda 	IFBase 						; Base -> R0
		jsr 	IFloatSetByte
		ldx 	#IFR1 						; R0 = R1 / R0
		jsr 	IFloatDivideInteger
		ldx 	#IFR0 						; if result <> 0
		jsr 	IFloatCheckZero
		beq 	_IFIOutDigit 				
		;
		lda 	IFR1+IM0 					; save remainder LSB only
		pha
		jsr 	_IFIRecursiveConvert 		; convert the divide result
		pla
		sta 	IFR1+IM0 					; restore remainder
_IFIOutDigit:		
		lda 	IFR1+IM0 					; get remainder.
		cmp	 	#10 						; convert to hexadecimal.
		bcc 	_IFINotHex
		adc 	#6
_IFINotHex:
		adc 	#48
		jsr 	IFloatBufferWrite 			; write character to buffer.
		rts
		.send code

		.section storage
IFBase:
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

