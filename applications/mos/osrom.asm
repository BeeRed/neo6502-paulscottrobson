; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		osrom.asm
;		Purpose:	OSRom wrapper program.
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.include "ramdata.inc"

		* = $F000 							; very small 2k monitor ROM
		.dsection code

; ************************************************************************************************
;
;										   Main Program
;
; ************************************************************************************************

		.section code
Boot:	jsr 	OSInitialise 				; set everything up.
		jsr 	FSInitialise 				; initialise the WWFS
		ldx 	#MainPrompt & $FF 			; display the boot prompt
		ldy 	#MainPrompt >> 8
		jsr 	OSWriteString

;_h1:
;		jsr		OSReadKeystroke
;		jsr 	OSWriteScreen
;		bra 	_h1
		
		ldx 	#setup & $FF
		ldy 	#setup >> 8
		jsr 	OSWriteFile

		jmp 	$1000 						; and run from $1000 onwards

NoInt:
		rti

setup:	.word 	name
		.word 	$1BB2
		.word 	69
name:	.text 	9,"text3.dat"		

		.include "include.files"
		.include "build/libwwfslib.asmlib"
		
; ************************************************************************************************
;
;										Main prompt
;
; ************************************************************************************************

MainPrompt:
		.byte 	_MPEnd-MainPrompt-1
		.text 	12,"*** OLIMEX Neo6502 RetroComputer ***",13,13
		.text 	"Alpha : Built "
		.include "src/generated/time.incx"
		.byte 	13,13
		.text 	"Please report bugs: paul@robsons.org.uk",13,13
_MPEnd:		

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
