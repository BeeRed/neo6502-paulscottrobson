; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dtkinteger.asm
;		Purpose:	Detokenise integer
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;							Detokenise integer, first token A, base Y
;
; ************************************************************************************************

TOKDInteger:
		pha 								; erase R0 preserving A. 	
		ldx 	#IFR0
		jsr 	IFloatSetZero
		pla
		cmp 	#PR_INTEGER 				; integer handler
		beq 	_TOKD3ByteInteger
		sec 	
		sbc 	#$60 						;  now 60-7F mapped on to $00-$1F
		sta 	IFR0+IM0 					
		bpl 	_TOKDHaveInteger
		;
		clc 								; map 20-5F to 00-3F
		adc 	#$40
		sta 	IFR0+IM1 					; the MS Byte
		jsr 	TOKDGet 					; the LS Byte
		sta 	IFR0+IM0
		bra 	_TOKDHaveInteger

_TOKD3ByteInteger: 							; copy 3 bytes of integer data.
		jsr 	TOKDGet
		sta 	IFR0+IM0
		jsr 	TOKDGet
		sta 	IFR0+IM1
		jsr 	TOKDGet
		sta 	IFR0+IM2

_TOKDHaveInteger:							; integer in R0, base in Y
		tya 								; base in A
		jsr 	IFloatIntegerToStringR0 		
		stx 	zTemp0
		sty 	zTemp0+1
		lda 	(zTemp0)
		jsr 	TOKDSpacing 				; check spacing okay.
		ldy 	#0 							; output buffer.
_TOKDOutput:
		lda 	(zTemp0),y
		jsr 	TOKDOutput
		iny		
		lda 	(zTemp0),y
		bne 	_TOKDOutput
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

