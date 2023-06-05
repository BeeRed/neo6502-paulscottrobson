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

		.weak
runEdit = 0 								; setting to 1 builds with the program/testing stuff in.
		.endweak

		* = $1000
		.dsection code

; ************************************************************************************************
;
;										   Main Program
;
; ************************************************************************************************

		.section code

boot:	
		ldx 	#BASICCODE >> 8
		ldy 	#ENDMEMORY >> 8
		jsr 	PGMSetBaseAddress
		jsr 	IFInitialise

		.if  	runEdit==1
		jmp 	TestCode
		.include "src/program/testing/testing.asmx"
		.endif

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

