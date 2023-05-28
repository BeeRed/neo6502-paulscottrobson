; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokpunctuation.asm
;		Purpose:	Tokenise punctuation
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;									Tokenise punctuation
;
; ************************************************************************************************

TOKTokenisePunctuation:
		jsr 	TOKResetElement 			; copy first punctuation character into element.
		jsr 	TOKGetNext 
		jsr 	TOKWriteElement

		jsr 	TOKGet 						; what follows ?
		cmp 	#' '						; space, not 2 character
		beq 	_TTPOne
		jsr 	TOKIsAlphaNumeric 			; if alphanumeric don't bother doing 2 character
		bcs 	_TTPOne 					; these speed things up a bit.
		jsr 	TOKWriteElement 			; this is what we will search for.
		jsr 	TOKFindToken
		bcs 	_TTPConsumeExit 			; it was found, consume, generate, exit.
		dec 	TOKElement 					; make it a single character 
_TTPOne:
		jsr 	TOKFindToken 				; look for one character punctuation
		bcs 	_TTPOutputExit 				; we found it
		sec 								; not recognised.
		rts

_TTPConsumeExit:
		pha
		jsr 	TOKGetNext 					; get the 2nd char out.
		pla
_TTPOutputExit:		
		jsr  	TOKWriteA 					; write token out
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
;
; ************************************************************************************************

