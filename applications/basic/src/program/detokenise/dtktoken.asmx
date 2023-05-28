; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dtktoken.asm
;		Purpose:	Detokenise token
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Detokenise line
;
; ************************************************************************************************

TOKDToken:
		cmp 	#PR_LSQLSQSHIFTRSQRSQ 		; shifted ?
		bne 	_TOKDNotShifted
		jsr 	TOKDGet 					; get what is shifted
		ldx 	#ShiftedTokens & $FF
		ldy 	#ShiftedTokens >> 8
		bra 	_TOKDSearch

_TOKDNotShifted:		
		cmp 	#PR_GAP_START 				; rejoin the two halves of the token.
		bcc 	_TOKDNoGap
		sec
		sbc 	#PR_GAP_ADJUST
_TOKDNoGap:
		ldx 	#StandardTokens & $FF
		ldy 	#StandardTokens >> 8
		;
		;		Seach for token A in table YX.
		;
_TOKDSearch:		
		stx 	zTemp0 						; put table in zTemp0
		sty 	zTemp0+1
		tax 								; token ID in X.				
_TOKDFind:
		dex 								; reached the start
		bpl 	_TOKDFound		
		sec 								; go to next entry
		lda 	(zTemp0)
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_TOKDFind
		inc 	zTemp0+1
		bra 	_TOKDFind
_TOKDFound:		
		lda 	(zTemp0) 					; length to X
		beq 	_TOKDExit
		tax 	
		ldy 	#1 							; output the token.
		lda 	(zTemp0),y 					; check spacing
		jsr 	TOKDSpacing
_TOKDOutput:
		lda 	(zTemp0),y
		jsr 	TOKToLower
		jsr 	TOKDOutput
		iny
		dex
		bne 	_TOKDOutput		

_TOKDExit:
		rts		

; ************************************************************************************************
;
;							Check if spacing required, next character out is A
;
; ************************************************************************************************

TOKDSpacing:
		jsr 	TOKIsAlphaNumeric 			; next character alphanumeric
		bcc 	_TOKDSExit
		lda 	TOKLastCharacter			; and last character also alphanumeric
		jsr 	TOKIsAlphaNumeric
		bcc 	_TOKDSExit
		lda 	#" " 						; we need a space.
		jsr 	TOKDOutput
_TOKDSExit:
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

