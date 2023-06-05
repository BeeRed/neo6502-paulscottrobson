; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		osrom.asm
;		Purpose:	OSRom wrapper program.
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.include "ramdata.inc"

		* = $F800
		.dsection code

; ************************************************************************************************
;
;										   Main Program
;
; ************************************************************************************************

		.section code
Boot:	jsr 	OSInitialise 				; set everything up.

;		jmp 	$1000
;		jmp 	KeyEcho

TestEdit:
		lda 	#30
		sta 	OSXPos
		lda 	#3
		sta 	OSYPos

		ldx 	#16
		stx 	OSEditLength
_TEFill:txa
		ora 	#64
		sta 	OSEditLength,x
		dex
		bne 	_TEFill		
		jsr 	OSEditLine

h1:		jsr 	OSReadKeystroke
		jsr 	OSWriteScreen
		bra 	h1				


KeyEcho:
		jsr 	OSReadKeystroke
		jsr 	OSWriteScreen
		jsr 	OSTWriteHex
		lda 	#' '
		jsr 	OSWriteScreen
		bra 	KeyEcho
		
NoInt:
		rti

		.include "include.files"

OSTWriteHex:
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_OSTWriteNibble		
		pla
_OSTWriteNibble:
		pha
		and 	#15
		cmp 	#10
		bcc 	_OSTNotAlpha
		adc 	#6
_OSTNotAlpha:
		adc 	#48
		jsr 	OSWriteScreen
		pla
		rts				

; ************************************************************************************************
;
;									Vectors to $FFFA
;
; ************************************************************************************************

		.include "src/generated/vectors.asmx"

; ************************************************************************************************
;
;									Hardware vectors.
;
; ************************************************************************************************

		.word 	NoInt 						; NMI
		.word 	Boot 						; Reset
		.word 	NoInt						; IRQ

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

