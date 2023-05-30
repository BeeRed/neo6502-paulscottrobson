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

; ************************************************************************************************
;
;								Allocate XA bytes all zeroed
;
; ************************************************************************************************	

AllocateMemory:
		phy 								; save Y
		ldy 	freeMemory 					; save addr.low
		phy
		ldy 	freeMemory+1 				; save addr.high
		ply
		tay 								; count is now in XY
_AllocateLoop:
		cpx 	#0 							; allocate count is zero ?
		bne 	_AllocateOne
		cpy 	#0
		beq 	_AllocateExit 
_AllocateOne:		
		;
		lda 	#0 							; zero byte
		sta 	(freeMemory)
		;
		inc 	freeMemory 					; bump pointer
		bne 	_AllocateSkipCarry
		inc 	freeMemory+1
_AllocateSkipCarry:
		;
		cpy 	#0 							; decrement XY
		bne 	_AllocateSkipBorrow
		dex
_AllocateSkipBorrow:
		dey
		bra 	_AllocateLoop				
		;
_AllocateExit:
		plx 								; restore address
		pla		
		ply 								; restore Y
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

