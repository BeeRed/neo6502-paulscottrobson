; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		main.asm
;		Purpose:	Run program
;		Created:	25th May 2023
;		Reviewed: 	24th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										   Main Program
;
; ************************************************************************************************

		.include "ramdata.inc"

		* = $1000
		.dsection code

		.section code
Start:		
		ldx 	#$FF
		txs
		jsr 	IFInitialise

;
;		This is for string to float conversion.
;
;		lda 	#text2-text
;		ldx 	#text & $FF
;		ldy 	#text >> 8
;		jsr 	IFloatStringToFloatR0

		.include "build/_test.asm" 			; test code
		.include "build/libmathslib.asmlib" ; assembler library

text:	.text 	"9403.318"
text2:

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

