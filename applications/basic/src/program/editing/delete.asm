; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		delete.asm
;		Purpose:	Delete line in token space, if it exists
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Delete line
;
; ************************************************************************************************

PGMDeleteLine:
		jsr 	PGMEndProgram 				; end of program into zTemp0
		;
		;		Point to start of program code
		;
		stz 	zTemp1						; copy base address of code to zTemp1
		lda 	PGMBaseHigh		
		sta 	zTemp1+1
		;
		;		Try to find the line.
		;
_PGMDLoop:
		lda 	(zTemp1) 					; finished, not found ?
		sec
		beq 	_PGMDExit
		;
		ldy 	#1 							; found line number ?
		lda 	(zTemp1),y
		cmp 	TOKLineNumber
		bne 	_PGMDNext
		iny
		lda 	(zTemp1),y
		cmp 	TOKLineNumber+1
		beq 	_PGMDDelete
		;
		;		Go to next line.
		;
_PGMDNext: 									; next slot
		clc
		lda 	(zTemp1)
		adc 	zTemp1
		sta 	zTemp1
		bcc 	_PGMDLoop		
		inc 	zTemp1+1
		bra 	_PGMDLoop
		;
		;		Found line, delete it.
		;
_PGMDDelete:								; delete line at zTemp1
		lda 	(zTemp1) 					; offset to next in Y
		tay
_PGMDCopy:
		lda 	(zTemp1),y 					; copy down.
		sta 	(zTemp1)

		lda 	zTemp1 						; reached the end ?
		cmp 	zTemp0
		bne 	_PGMDNext2
		lda 	zTemp1+1
		cmp 	zTemp0+1
		clc
		beq 	_PGMDExit
_PGMDNext2:
		inc 	zTemp1 						; advance pointer.
		bne 	_PGMDCopy
		inc 	zTemp1+1
		bra 	_PGMDCopy

_PGMDExit:		
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

