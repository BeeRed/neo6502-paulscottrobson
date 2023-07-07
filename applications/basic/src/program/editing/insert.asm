; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		insert.asm
;		Purpose:	Insert line in token space into program.
;		Created:	28th May 2023
;		Reviewed: 	7th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Insert line
;
; ************************************************************************************************

PGMInsertLine:
		jsr 	PGMEndProgram 				; end of program into zTemp0
		;
		;		Point to start of program code
		;
		stz 	zTemp1						; copy base address of code to zTemp1
		lda 	PGMBaseHigh		
		sta 	zTemp1+1
		;
		;		Try to find the line whose line number is greater than the one in the token 
		;		buffer.
		;
_PGMILoop:
		lda 	(zTemp1) 					; reached the end, it goes here on the end.
		beq 	_PGMIInsert
		;
		ldy 	#1 							; compare in-program line vs token line.
		lda 	(zTemp1),y
		cmp 	TOKLineNumber
		iny
		lda 	(zTemp1),y
		sbc 	TOKLineNumber+1
		bcs 	_PGMIInsert 				; insert here.
		;
		;		Go to next line.
		;
		clc
		lda 	(zTemp1)
		adc 	zTemp1
		sta 	zTemp1
		bcc 	_PGMILoop		
		inc 	zTemp1+1
		bra 	_PGMILoop
		;
		;		Insert space for current line.
		;
_PGMIInsert:
		ldy 	TOKLineSize 				; space required is length in token buffer.
_PGMIInsertLoop:
		lda 	(zTemp0) 					; shift byte up.
		sta 	(zTemp0),y 			
		;
		lda 	zTemp1 						; reached insert point
		cmp 	zTemp0
		bne 	_PGMINext		
		lda 	zTemp1+1
		cmp 	zTemp0+1
		beq 	_PGMIInserted
_PGMINext: 									; back one.
		lda 	zTemp0
		bne 	_PGMINoBorrow
		dec 	zTemp0+1
_PGMINoBorrow:
		dec 	zTemp0
		bra 	_PGMIInsertLoop 			; do previous byte.
		;
		;		Copy new line into the created space.
		;
_PGMIInserted:
		ldy 	#0 							; copy tokenbuffer to insert point
_PGMICopyLoop:
		lda 	TOKLineSize,y
		sta 	(zTemp1),y
		iny
		cpy 	TOKLineSize
		bne 	_PGMICopyLoop

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

