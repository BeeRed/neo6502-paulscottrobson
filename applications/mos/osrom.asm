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
		ldx 	#MainPrompt & $FF
		ldy 	#MainPrompt >> 8
		jsr 	OSWriteStringZ
		jmp 	$1000
NoInt:
		rti

		.include "include.files"

; ************************************************************************************************
;
;										Main prompt
;
; ************************************************************************************************

MainPrompt:
		.text 	"*** OLIMEX Neo6502 RetroComputer ***",13,13
		.text 	"Build "
		.include "src/generated/time.incx"
		.byte 	13,13,0

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

