; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scanforward.asm
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
;		Scan forward looking for A or X, skipping complete structures, A contains match
;
; ************************************************************************************************


ScanForward:
		stz 	zTemp1 						; clear structure count.
ScanForwardMain:		
		sta 	zTemp0 						; save scan options in zTemp0
		stx 	zTemp0+1
		;
		;
		;		Scan forward loop.
		;
_ScanLoop:		
		lda 	zTemp1 						; if structure count non zero, don't check for end.
		bne 	_ScanNoCheck
		;
		lda 	(codePtr),y 				; reached either target token.
		cmp 	zTemp0
		beq 	_ScanExit
		cmp 	zTemp0+1
		beq 	_ScanExit
_ScanNoCheck:
		jsr 	SkipOneInstruction
		bcc 	_ScanLoop
		.error_structure

_ScanExit:
		iny 								; consume final token.		
		rts

; ************************************************************************************************
;
;					Skip one instruction, return CS on underflow error
;
; ************************************************************************************************

SkipOneInstruction:
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
		bcs 	_SOIExit
		cmp 	#PR_STRUCTURE_FIRST
		bcc 	_SOIExit
		;
		tax 								; access the table to get the adjustment.
		clc
		lda 	zTemp1 						; add it to structure count.
		adc 	StructureOffsets-PR_STRUCTURE_FIRST,x
		sta 	zTemp1
		bpl		_SOIExit 		 			; error if -ve ?
		sec
		rts

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
		bne 	_SOIExit
		sec 								; failed.
		rts
;
;		Scan over [decimal] or [string]
;
_ScanDataItem:	 					
		tya
		sec
		adc 	(codePtr),y
		tay
		bra 	_SOIExit

_SOIExit:
		clc
		rts		

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		07/07/2013 		Factored out the 'advance forward' code, which now returns CS on underflow.
;						(for getting the LIST)
;
; ************************************************************************************************
