; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokpunctuation.asm
;		Purpose:	Tokenise punctuation
;		Created:	28th May 2023
;		Reviewed: 	7th July 2023
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
		;
		;		Try 2 char ones first, e.g. >=
		;
		jsr 	TOKGet 						; what follows ?
		cmp 	#' '						; space, not 2 character.
		beq 	_TTPOne
		;
		jsr 	TOKIsAlphaNumeric 			; if alphanumeric don't bother doing 2 character
		bcs 	_TTPOne 					; these speed things up a bit.
		jsr 	TOKWriteElement 			; this is what we will search for.
		jsr 	TOKFindToken
		bcs 	_TTPConsumeExit 			; it was found, consume, generate, exit.
		dec 	TOKElement 					; make it a single character 		
_TTPOne:
		;
		;		Try 1 character
		;
		jsr 	TOKFindToken 				; look for one character punctuation
		bcs 	_TTPOutputExit 				; we found it
		sec 								; not recognised.
		rts
		;
		;		Consume 2nd punc char
		;
_TTPConsumeExit:
		pha
		jsr 	TOKGetNext 					; get the 2nd char out.
		pla
		;
		;		Output, checking for comments.
		;
_TTPOutputExit:		
		cmp 	#PR_SQUOTE 					; single quote
		beq 	_TTPComment
		jsr  	TOKWriteA 					; write token out
		clc
		rts
		;
		;		If comment found, do comment code.
		;
_TTPComment:		
		jsr 	TOKDoComment
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
;		26/06/23 		Added code to handle single quote comment auto-string
;
; ************************************************************************************************

