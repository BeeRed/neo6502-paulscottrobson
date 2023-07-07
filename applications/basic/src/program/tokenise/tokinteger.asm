; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokinteger.asm
;		Purpose:	Tokenise integer
;		Created:	28th May 2023
;		Reviewed: 	7th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;									Tokenise an integer
;
; ************************************************************************************************

TOKTokeniseInteger:
		;
		;		Get number
		;
		jsr 	TOKExtractInteger 			; pull an integer out as text.
		ldx 	#TOKElementText & $FF 		; get length/address
		ldy 	#TOKElementText >> 8
		lda		TOKElement 			
		jsr 	IFloatStringToFloatR0 		; convert to R0 integer
		;
		lda 	TOKIsFirstElement 			; first element ?
		beq 	_TOKNotLineNumber
		;
		;		Tokenising first object e.g. it's a line number.
		;
		lda 	IFR0+IM2 					; check it's a 2 digit number
		bne 	_TOKBadLineNumeber
		lda 	IFR0+IM0 					; copy it to the line number section.
		sta 	TOKLineNumber
		lda 	IFR0+IM1
		sta 	TOKLineNumber+1
		clc
		rts
_TOKBadLineNumeber:
		sec
		rts
		;
		;		Any other integer
		;
_TOKNotLineNumber:
		jsr 	TOKTokeniseConstant 		; tokenise the constant in R0
		clc
		rts

; ************************************************************************************************
;
;							Extract an integer to TOKElement
;
; ************************************************************************************************

TOKExtractInteger:
		jsr 	TOKResetElement 			; restart
_TTILoop:
		jsr 	TOKGet 						; keep getting and copying while numeric.
		jsr 	TOKIsDigit
		bcc 	_TOKEIExit
		jsr 	TOKWriteElement
		jsr 	TOKGetNext
		bra 	_TTILoop
_TOKEIExit:			
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
