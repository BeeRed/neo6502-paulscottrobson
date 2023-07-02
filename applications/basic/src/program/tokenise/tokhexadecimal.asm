; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokhexadecimal.asm
;		Purpose:	Tokenise hex integer
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;								Tokenise a hexadecimal integer
;
; ************************************************************************************************

TOKTokeniseHexadecimal:
		jsr 	TOKGetNext 					; consume the $
		ldx 	#IFR0
		jsr 	IFloatSetZero 				; set R0 = 0
_TTHLoop:
		jsr 	TOKGet 						; keep getting and copying while numeric.
		jsr 	TOKIsHexadecimal
		bcc 	_TTHDone
		ldx 	#IFR0 						; shift R0 right 4
		jsr 	IFloatShiftLeft		
		jsr 	IFloatShiftLeft		
		jsr 	IFloatShiftLeft		
		jsr 	IFloatShiftLeft		
		jsr 	TOKGetNext
		jsr 	TOKToUpper 					; make U/C
		sec 								; convert to decimal.
		sbc 	#48
		cmp 	#10
		bcc 	_TTHNotAlpha
		sbc 	#7
_TTHNotAlpha:
		ora 	IFR0+IM0 					; OR in
		sta 	IFR0+IM0		
		bra 	_TTHLoop
_TTHDone:
		lda 	#PR_AMPERSAND 				; write & function out
		jsr 	TOKWriteA
		jsr 	TOKTokeniseConstant 		; write integer out.
		clc
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
;		01/07/23 		&1A and &1a different - no upper case conversion.
;
; ************************************************************************************************

