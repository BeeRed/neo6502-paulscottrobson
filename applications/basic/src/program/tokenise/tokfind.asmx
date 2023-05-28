; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokfind.asm
;		Purpose:	Find a token in the element buffer in upper case.
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;			Find a token in the element buffer, return X:A/CS if found, CC if not found
;
; ************************************************************************************************

TOKFindToken:
		;
		;		Handle default set.
		;
		ldx 	#StandardTokens & $FF 		; do this table
		ldy 	#StandardTokens >> 8
		jsr 	TOKFindTokenXY 				; find it, or not
		bcc 	_TOKFTCheckShift

		cmp 	#PR_GAP_START 				; do we adjust for unary ?
		bcc 	_TOKFTNoAdjust
		clc 								; if so, do it.
		adc 	#PR_GAP_ADJUST
_TOKFTNoAdjust:		
		ldx 	#0
		sec
		rts
		;
		;		Shifted set
		;
_TOKFTCheckShift:
		ldx 	#ShiftedTokens & $FF 		; do this table
		ldy 	#ShiftedTokens >> 8
		jsr 	TOKFindTokenXY 				; find it, or not
		bcc 	_TOKFTFail
		ldx 	#PR_LSQLSQSHIFTRSQRSQ
		sec
		rts


_TOKFTFail		
		clc
		rts

; ************************************************************************************************
;
;								General token finder using table at YX
;
; ************************************************************************************************

TOKFindTokenXY:
		stx 	zTemp0 						; save token table address
		sty 	zTemp0+1
		lda 	#$80 						; table starts at $80
		sta 	TOKCurrent
_TOKFindLoop:				
		lda 	(zTemp0) 					; get token length from table
		clc 		 						; clear carry in case of fail
		bmi 	_TOKExit 					; end of table, fail, so return CC.
		cmp 	TOKElement 					; compare against the element length
		bne 	_TOKNext 					; different, try next.
		tax 								; number of chars to compare.
		ldy 	#1 							; offset to actual text.
_TOKCompare:
		lda 	(zTemp0),y 					; compare the characters 
		cmp 	TOKElementText-1,y
		bne 	_TOKNext 					; different ? try next
		iny 								; compare next two
		dex
		bne 	_TOKCompare 				; until done X characters.
		sec
		lda 	TOKCurrent 					; return current ID.
_TOKExit:		
		rts

_TOKNext:
		inc 	TOKCurrent 					; increment token #
		sec 								; add length+1 to ptr
		lda 	(zTemp0) 					
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_TOKFindLoop
		inc 	zTemp0+1
		bra 	_TOKFindLoop

		.send code

		.section storage
TOKCurrent:
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

