; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scan.asm
;		Purpose:	Scan Forward
;		Created:	2nd June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Scan forward looking for A or X, skipping complete structures
;
; ************************************************************************************************

ScanForward:
		sta 	zTemp0 						; save scan options in zTemp0
		stx 	zTemp0+1
		;
		stz 	zTemp1 						; clear structure count.
		;
		;		Scan forward loop.
		;
_ScanForwardLoop:		
		lda 	zTemp1 						; if structure count non zero, don't check for end.
		bne 	_ScanNoCheck
		;
		lda 	(codePtr),y 				; reached either target token.
		cmp 	zTemp0
		beq 	_ScanExit
		cmp 	zTemp0+1
		beq 	_ScanExit
_ScanNoCheck:

		lda 	(codePtr),y 				; get the token and consume it.
		iny
		;
		cmp 	#PR_LSQLSQDECIMALRSQRSQ 	; check for special multi-byte elements
		beq		_ScanDataItem
		cmp 	#PR_LSQLSQSTRINGRSQRSQ
		beq 	_ScanDataItem
		;
		cmp 	#PR_LSQLSQENDRSQRSQ 		; handle end of line.
		beq 	_ScanNextLine
		;
		cmp 	#PR_LSQLSQSHIFTRSQRSQ 		; if shift, skip one.
		bne 	_ScanNoShift
		iny
_ScanNoShift:		
;
;		Handle structures open/close
;
		cmp 	#PR_STRUCTURE_LAST+1 		; nested structures
		bcs 	_ScanForwardLoop
		cmp 	#PR_STRUCTURE_FIRST
		bcc 	_ScanForwardLoop
		;
		tax 								; access the table to get the adjustment.
		clc
		lda 	zTemp1 						; add it to structure count.
		adc 	StructureOffsets-PR_STRUCTURE_FIRST,x
		sta 	zTemp1
		bpl		_ScanForwardLoop 			; error if -ve ?
		.error_structure
;
;		Scan over end of line.
;
_ScanNextLine:
		clc	 								; forward to next line.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_ScanNoCarry
		inc 	codePtr+1
_ScanNoCarry:
		ldy 	#3		
		lda 	(codePtr) 					; off end of program ?
		bne 	_ScanForwardLoop
		.error_structure
;
;		Scan over [decimal] or [string]
;
_ScanDataItem:	 					
		.debug
		tya
		sec
		adc 	(codePtr),y
		tay
		bra 	_ScanForwardLoop

_ScanExit:
		iny 								; consume final token.		
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
