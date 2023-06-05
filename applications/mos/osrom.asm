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
		ldx 	#0
_Intro:	lda 	MainPrompt,x
		jsr 	OSWriteScreen
		inx
		lda 	MainPrompt,x
		bne 	_Intro
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
		.text 	"*** Neo6502 RetroComputer ***",13,13
		.text 	"Hardware:",13
		.text	"    Olimex Ltd, 2 Pravda St",13
		.text 	"    PO Box 237, Plovdiv 4000 Bulgaria",13
		.text 	"Software:",13
		.text 	"    Paul Robson paul@robsons.org.uk",13
		.byte 	13,0

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

