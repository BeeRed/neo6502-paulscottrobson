; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokidentifier.asm
;		Purpose:	Tokenise an identifier
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;								Tokenise an identifier
;
; ************************************************************************************************

TOKTokeniseIdentifier:
		jsr 	TOKResetElement 			; extract an identifier
_TOKGetIdentifier:
		jsr 	TOKGet
		jsr 	TOKIsAlphaNumeric
		bcc 	_TOKEndIdent
		jsr		TOKWriteElement
		jsr 	TOKGetNext
		bra 	_TOKGetIdentifier
		;
_TOKEndIdent:		
		cmp 	#"$" 						; append $ or ( if typed, not both.
		beq 	_TOKAppendType 
		cmp 	#"("
		bne 	_TOKNoAppend
_TOKAppendType:		
		jsr 	TOKWriteElement 			; add it
		jsr 	TOKGetNext 					; consume it
_TOKNoAppend:
		jsr 	TOKFindToken 				; find it
		bcc		_TOKIsVariable 				; it must be a variable or proc name

		cpx 	#0 							; shifted ?
		beq 	_TOKNoShift
		pha
		txa
		jsr 	TOKWriteA
		pla
_TOKNoShift:		
		jsr 	TOKWriteA
		clc
		rts

_TOKIsVariable:				
		jsr 	PGMFindIdentifier 			; find/create identifier.
		tya
		jsr 	TOKWriteA
		txa
		jsr 	TOKWriteA
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

