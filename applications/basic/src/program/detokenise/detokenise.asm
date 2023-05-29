; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		detokenise.asm
;		Purpose:	Detokenise line
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Detokenise token A
;
; ************************************************************************************************

TOKDetokenise:
		stx 	zTemp2 						; save tokenised code in zTemp2
		sty 	zTemp2+1
		stz		TOKLastCharacter 			; clear last character
		;
		;		Main detokenising loop
		;
_TOKDLoop:
		jsr 	TOKDGet 					; get next
		cmp 	#PR_LSQLSQENDRSQRSQ			; end of line
		beq 	_TOKDExit
		;
		cmp 	#PR_LSQLSQSTRINGRSQRSQ		; is it a string/integer with additional data.
		beq 	_TOKDDataItem
		cmp 	#PR_LSQLSQDECIMALRSQRSQ
		beq 	_TOKDDataItem
		;
		cmp 	#0 							; is it a token 80-FF
		bpl 	_TOKDNotToken
		jsr 	TOKDToken 					; token to text.		
		bra 	_TOKDLoop
		;
_TOKDNotToken:
		cmp 	#$40  						; 40-7F Identifier
		bcc 	_TOKDNotIdentifier
		jsr 	TOKDIdentifier
		bra 	_TOKDLoop
		;
_TOKDNotIdentifier: 						; 00-3F Base 10 Integer
		ldy 	#10 						
; ****	jsr 	TOKDInteger
		bra 	_TOKDLoop

_TOKDDataItem:								; [[STRING]] [[DECIMAL]]
		jsr 	TOKDDataItem
		bra 	_TOKDLoop

_TOKDExit:
		clc
		rts

; ************************************************************************************************
;
;										Read Next Character
;
; ************************************************************************************************

TOKDGet:lda 	(zTemp2)
		inc 	zTemp2
		bne 	_TKDGExit
		inc 	zTemp2+1
_TKDGExit:
		rts

; ************************************************************************************************
;
;						Output one character to whatever handler is set up
;
; ************************************************************************************************

TOKDOutput:
		sta 	TOKLastCharacter
		jmp 	(TOKOutputMethod)

; ************************************************************************************************
;
;									Set the handler.
;
; ************************************************************************************************

TOKSetDetokeniseOutput:	
		stx 	TOKOutputMethod
		sty 	TOKOutputMethod+1
		rts

		.send code
		
		.section storage
TOKOutputMethod:		
		.fill 	2
TOKLastCharacter:
		.fill 	1		
		.send storage

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

