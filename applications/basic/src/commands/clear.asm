; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Clear variables / general reset
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										CLR Command
;
; ************************************************************************************************

		.section code

Command_CLEAR:	;; [clear]
		;
		;		TODO: Reset stack
		;

		;
		;		Reset variable memory pointer
		;
		jsr 	PGMEndProgram 				; end program => zTemp0
		stz 	freeMemory 					; start on next free page
		lda 	zTemp0+1
		inc 	a
		sta 	freeMemory+1
		;
		;		Reset hash tables
		; 
		jsr 	VARClearHashTables
		;
		;		TODO: Scan for procedures
		;

		;
		;		Initialise string usage.
		;
		jsr 	StringSystemInitialise 		
		rts

		.send code

		.section zeropage
freeMemory:
		.fill 	2
		.send zeropage		

;:[CLR]\
; Clear effectively resets the BASIC interpreter without actually restarting the program. It erases
; all variables and arrays, resets the stack and memory allocation, and checks for callable
; procedures. It should not normally be used as the RUN command does this as well.		

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

