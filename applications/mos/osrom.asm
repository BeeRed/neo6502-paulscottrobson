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

		jmp 	$1000
h2:
		jsr 	OSKeyboardDataProcess 		; this scans the keyboard, could be interrupt
		jsr 	OSReadKeyboard
		bcs 	h2	
		jsr 	OSWriteScreen
		jsr 	OSTWriteHex
		lda 	#' '
		jsr 	OSWriteScreen
		bra 	h2
		
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

