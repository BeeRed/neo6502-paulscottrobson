; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokstring.asm
;		Purpose:	Tokenise a string
;		Created:	28th May 2023
;		Reviewed: 	7th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;									Tokenise a string
;
; ************************************************************************************************

TOKTokeniseString:
		jsr 	TOKGetNext 					; consume the "
		jsr 	TOKResetElement 			; start getting the string
_TOKTSLoop:
		jsr 	TOKGet 						; check EOL
		cmp 	#0 					
		beq 	_TOKTSExit
		jsr 	TOKGetNext 					; get and consume
		cmp 	#'"' 						; exit if " consumed
		beq 	_TOKTSExit
		jsr 	TOKWriteElement
		bra 	_TOKTSLoop

_TOKTSExit:
		lda 	#PR_LSQLSQSTRINGRSQRSQ		; token for [[string]]
		jsr 	TOKWriteA
		jsr 	TOKOutputElementBuffer 		; output collected data.
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

