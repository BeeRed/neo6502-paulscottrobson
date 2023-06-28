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
		phy 								; save base
		ldx 	#IFR0 						; set into R0
		jsr 	IFloatSetByte
_TOKDILoop:
		lda 	(zTemp2) 					; followed by a 00-3F
		cmp 	#$40
		bcs 	_TOKDIHaveInteger
		ldx 	#IFR0 						; R0 << 6
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	TOKDGet 					; OR byte in.
		ora 	IFR0+IM0
		sta 	IFR0+IM0
		bra 	_TOKDILoop
		
_TOKDIHaveInteger:							; integer in R0, base in Y
		ply 								; restore base
		tya 								; base in A
		jsr 	IFloatIntegerToStringR0 		
		stx 	zTemp0
		sty 	zTemp0+1
		lda 	(zTemp0)
		jsr 	TOKDSpacing 				; check spacing okay.
		ldy 	#1 							; output buffer.
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

