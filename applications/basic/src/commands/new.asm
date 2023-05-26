; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		new.asm
;		Purpose:	New program
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										NEW Command
;
; ************************************************************************************************

		.section code

Command_NEW:	;; [new]
		jsr 	PGMNewProgram
		jsr 	Command_CLEAR
		jmp 	Command_END
		.send code
		
;:[new]
; Erase current program and variables and then return to command line.
				
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
