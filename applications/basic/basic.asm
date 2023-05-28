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
		ldx 	#$40
		ldy 	#$A0
		jsr 	PGMSetBaseAddress
		jsr 	IFInitialise

		ldx 	#TokTest & $FF
		ldy 	#TokTest >> 8
		clc
		jsr 	TOKTokenise

		jmp 	Command_RUN

		.include "include.files"
		.include "build/libmathslib.asmlib"

NotImplemented:
		lda 	#$FF
		bra 	EnterDbg
ErrorHandler:			
		plx
		ply
		lda 	#$EE
EnterDbg:		
		.debug
		jmp 	EnterDbg
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

