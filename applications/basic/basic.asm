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
autoRun = 0 								; setting to 1 autoruns program in memory space.
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
		ldx 	#BASICCODE >> 8 			; common setup
		ldy 	#ENDMEMORY >> 8
		jsr 	PGMSetBaseAddress
		jsr 	IFInitialise 				; setup math library

		.if  	runEdit==1 					; run edit check code (checks line editing)
		jmp 	TestCode
		.include "src/program/testing/testing.asmx"
		.endif

		.if 	autoRun==1 					; run program in memory.
		lda 	#12
		jsr 	OSWriteScreen
		jmp 	Command_RUN
		.endif

		jmp 	Command_NEW

		.include "include.files"
		.include "build/libmathslib.asmlib"

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

