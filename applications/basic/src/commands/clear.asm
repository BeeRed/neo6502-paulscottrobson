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
		;		Reset stack
		;
		lda 	PGMEndMemoryHigh
		jsr 	StackReset
		;
		;		Initialise string usage.
		;
		jsr 	StringSystemInitialise 		
		;
		;		TODO: Scan for procedures
		;
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
		phy
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
		jsr 	ClearCheckMemory
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

; ************************************************************************************************	
;
;					Check space between free memory and string memory
;
; ************************************************************************************************	

ClearCheckMemory:
		lda 	freeMemory+1
		inc 	a
		inc 	a
		cmp 	stringMemory+1
		bcs  	_CCMError
		rts

_CCMError:
		.error_memory		
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

