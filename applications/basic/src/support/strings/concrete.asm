; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		concrete.asm
;		Purpose:	Concrete string
;		Created:	30th May 2023
;		Reviewed: 	No
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Concrete the string at R0
;
; ************************************************************************************************

StringConcrete:
		phy 								; save position on stack
		;
		;		R0 points to the string to be concreted.
		;
		lda 	(IFR0) 						; get string length
		cmp 	#253 						; string too long - cannot concrete.
		bcs 	_SALengthError

		clc 								; length of the new string
		adc 	#5+3 						; add 5 characters total plus 3 (length,status,EOS)
		bcc 	_SAHaveLength
		lda 	#255 						; string max length is 255
_SAHaveLength:
		pha 								; save length to be allocated for concreting.
		;
		sec
		eor 	#$FF 						; add to StringMemory using 2's complement
		adc 	stringMemory
		sta 	stringMemory
		sta 	zTemp2 						; update storage address
		;
		lda 	#$FF 						; now do the MSB
		adc 	stringMemory+1
		sta 	stringMemory+1
		sta 	zTemp2+1
		;
		pla 								; save length allocated in +0
		sta 	(zTemp2)
		lda 	#0 							; clear the status byte in +1
		ldy 	#1
		sta 	(zTemp2),y		
		;
		;		Copy string into the space
		;
_SACopyNewString:
		lda 	(IFR0) 						; copy length at +2
		ldy 	#2
		sta 	(zTemp2),y
		tax 								; bytes to copy
		beq 	_SACopyExit
		ldy 	#1 							; first character from here
_SACopyNSLoop:
		lda 	(IFR0),y 					; get character from here 
		iny 								; write two on in string storage
		iny
		sta 	(zTemp2),y
		dey
		dex									; until copied all the string lengths.
		bne 	_SACopyNSLoop

_SACopyExit:		
		ldx 	zTemp2+1 					; XA contain the concreted string.
		lda 	zTemp2
		ply
		rts		

_SALengthError:
		.error_string

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
