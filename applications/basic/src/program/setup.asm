; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		setup.asm
;		Purpose:	Set up Program space
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;						Set the base/top address for the program space
;								   Base:(XX00) Limit:(UU00)
;
; ************************************************************************************************

PGMSetBaseAddress:
		stx 	PGMBaseHigh
		sty 	PGMEndMemoryHigh
		rts

; ************************************************************************************************
;
;									Create a new program
;
; ************************************************************************************************

PGMNewProgram:
		stz 	zTemp0						; copy base address to zTemp0
		lda 	PGMBaseHigh
		sta 	zTemp0+1
		lda 	#0 							; overwrite the offset
		sta 	(zTemp0)
		rts

; ************************************************************************************************
;
;							Last byte of program (the 0 offset) => zTemp0
;
; ************************************************************************************************		

PGMEndProgram:
		stz 	zTemp0 						; copy base address to zTemp0
		lda 	PGMBaseHigh
		sta 	zTemp0+1
_PGMEPLoop:
		lda 	(zTemp0)
		beq 	_PGMEPExit
		clc
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_PGMEPLoop
		inc 	zTemp0+1
		bra 	_PGMEPLoop
_PGMEPExit:
		rts		

		.send code
		
		.section storage
PGMBaseHigh:								; high byte program base address.
		.fill 	1
PGMEndMemoryHigh:							; high byte of first memory location after program/variable/stack space.
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

