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
		jsr 	TOKToUpper
		jsr 	TOKIsIdentifierElement
		bcc 	_TOKEndIdent
		jsr		TOKWriteElement
		jsr 	TOKGetNext
		bra 	_TOKGetIdentifier
		;
_TOKEndIdent:		
		cmp 	#"$" 						; last one $
		bne 	_TOKNotString
		jsr 	TOKWriteElement 			; add it
		jsr 	TOKGetNext 					; consume it
_TOKNotString:		
		jsr 	TOKGet 						; finally check for (
		cmp 	#"("
		bne 	_TOKNoArray
		jsr 	TOKWriteElement 			; add it
		jsr 	TOKGetNext 					; consume it
_TOKNoArray:
		jsr 	TOKFindToken 				; find it
		bcc		_TOKIsVariable 				; it must be a variable or proc name if not found
		cmp 	#PR_REM 					; is it REM ?
		beq 	_TOKComment 				; yes, do comment code.
		;
		cpx 	#PR_LSQLSQSHIFTRSQRSQ 		; shifted token
		bne 	_TOKNoShift
		pha 								; write the shift.
		txa
		jsr 	TOKWriteA
		pla
_TOKNoShift:		
		jsr 	TOKWriteA 					; write the main token.
		clc
		rts

_TOKComment:
		jsr 	TOKDoComment
		clc
		rts		

_TOKIsVariable:
		ldx 	#0 							; output element buffer
_TOKOutputBuffer:
		lda 	TOKElementText,x 			; output it translated. 			
		jsr 	TOKTranslateIdentifier
		jsr 	TOKWriteA
		inx
		lda 	TOKElementText,x
		jsr 	TOKIsIdentifierElement
		bcs 	_TOKOutputBuffer

		tay 								; last char in Y
		lda 	#$7C 						; token is $7C
		cpy 	#0 							; if no modifier use this
		beq 	_TOKIVExit
		cpy 	#'$'						; array mod ?
		bne 	_TOKIVCheckArray 			; no, check for (
		inc 	a 							; token is $7D
		ldy 	TOKElementText+1,x 			; get next one.
_TOKIVCheckArray:
		cpy 	#'('						; is it ( ?
		bne 	_TOKIVExit 					; yes, then add 2 more, so 7C->7E and 7D->7F
		inc 	a
		inc 	a
_TOKIVExit:		
		jsr 	TOKWriteA 					; ending token
		clc
		rts

; ************************************************************************************************
;
;		Convert U/C character to identifier equivalent. Assumes it is already legitimate.
;
; ************************************************************************************************

TOKTranslateIdentifier:
		cmp 	#"_" 						; _ is 0x64
		beq 	_TTI64
		sec
		sbc 	#"A" 						; map A-Z onto 0-25
		bpl 	_TTIExit
		clc 								; map 09 onto 26-35
		adc 	#"A"-"0"+26
_TTIExit:		
		ora 	#$40 						; correct range.
		rts
_TTI64:	lda 	#$64		
		rts

; ************************************************************************************************
;
;									Do a comment. A has token
;
; ************************************************************************************************

TOKDoComment:
		jsr 	TOKWriteA					; output the token.
_TOKSkipSpaces:		
		jsr 	TOKGet 						; skip over spaces
		cmp 	#' '
		bne 	_TOKEndSpaces
		jsr 	TOKGetNext
		bra 	_TOKSkipSpaces
		;
_TOKEndSpaces:
		pha 								; save it
		pla
		beq 	_TOKDCExit 					; end of line.
		cmp 	#'"'						; does it have a speech mark ?
		bne 	_TOKDCDoLine 				; otherwise the comment is the whole line.
_TOKDCExit:
		rts

_TOKDCDoLine:				
		jsr 	TOKResetElement 			; start getting the string
_TOKDCLoop:
		jsr 	TOKGet 						; check EOL
		cmp 	#0 					
		beq 	_TOKDCEndComment
		jsr 	TOKGetNext 					; get and consume
		jsr 	TOKWriteElement
		bra 	_TOKDCLoop

_TOKDCEndComment:
		lda 	#PR_LSQLSQSTRINGRSQRSQ
		jsr 	TOKWriteA
		jsr 	TOKOutputElementBuffer
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
;		27/06/23 		TOKDoComment passes the token to use (' or REM) in in A
;		28/06/23 		Allows shifted tokens.
; 		01/07/23 		. is no longer part of an identifier, it's a token.
;
; ************************************************************************************************

