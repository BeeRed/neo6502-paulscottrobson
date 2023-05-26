; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		basic.asm
;		Purpose:	BASIC main program
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.include "build/ramdata.inc"
		.include "build/osvectors.inc"

		* = $1000
		.dsection code

; ************************************************************************************************
;
;										   Main Program
;
; ************************************************************************************************

		.section code

boot:	
		jsr 	IFInitialise
		jsr 	StringSystemInitialise 		
		stz 	stringInitialised

		;
		lda 	#$40
		sta 	codePtr+1
		stz 	codePtr
		ldy 	#4
		jsr 	EXPTermR0
		jmp 	$FFFF

		.include "include.files"
		.include "build/libmathslib.asmlib"

NotImplemented:
		lda 	#$FF
ErrorHandler:
		.debug
		lda 	#$EE
		jmp 	ErrorHandler
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

