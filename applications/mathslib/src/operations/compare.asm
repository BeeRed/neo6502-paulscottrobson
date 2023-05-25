; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		compare.asm
;		Purpose:	Compare two numbers
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							 Compare two numbers R0 = RX vs R0 (-1,0,1)
;
; ************************************************************************************************

IFloatCompare:
		jsr 	IFloatSubtract 				; subtract R0 from RX.
		lda 	IExp,x 						; check if integer comparison
		ora 	IFR0+IExp
		ldx 	#IFR0 						; only using R0 from now on.
		and 	#IFXMask
		bne 	_IFCNonInteger
		;
		;		Integer compare
		;
		jsr 	IFloatCheckZero 			; check if zero
		beq 	_IFCZero
_IFCReturnSign:
		lda 	IFR0+IExp 					; get the sign bit/unused -> stack.
		and 	#(IFXMask ^ $FF)
		pha
		lda 	#1
		jsr 	IFloatSetByte 				; return to +1
		pla 								; sign bit back
		sta 	IFR0+IExp					; set that sign
		clc
		rts

_IFCZero:									; return 0.
		jsr 	IFloatSetZero
		clc
		rts
		;
		;		Float compare - check the upper 2 bytes are zero - this is *nearly* zero.
		; 		can vary how many of lower byte we check.
		;
_IFCNonInteger:		
		lda 	IFR0+IM0
		and		#$00
		ora 	IFR0+IM1
		ora 	IFR0+IM2
		beq 	_IFCZero 					; near enough !
		bra 	_IFCReturnSign 				; return the sign of the difference.

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

