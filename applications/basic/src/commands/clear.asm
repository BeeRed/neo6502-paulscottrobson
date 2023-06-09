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
		lda 	(codePtr),y 				; check for CLEAR <something>
		cmp 	#PR_COLON
		beq 	_CLNoParam
		cmp 	#PR_LSQLSQENDRSQRSQ 
		beq 	_CLNoParam
		jsr 	EXPEvalInteger16 			; address for CLEAR
		lda 	IFR0+IM1 					; high byte
		cmp 	#ENDMEMORY >> 8 			; too high
		bcs 	_CLMemory
		cmp 	#(BASICCODE >> 8)+1 		; too low
		bcc 	_CLMemory
		sta 	PGMEndMemoryHigh 			; update end of memory.
_CLNoParam:		
		jsr 	ClearCode
		rts
_CLMemory:
		.error_memory

; ************************************************************************************************
;
;									Do CLEAR functionality
;
; ************************************************************************************************

ClearCode:
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
		;		Scan for procedures
		;
		jsr 	ScanProcedures
		;
		;		Reset READ/DATA
		;
		jsr 	Command_RESTORE
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

;:[CLEAR <address>]\
; Clear effectively resets the BASIC interpreter without actually restarting the program. It erases
; all variables and arrays, resets the stack and memory allocation, and checks for callable
; procedures. It should not normally be used as the RUN command does this as well. CLEAR takes an 
; optional parameter which sets the high memory address for BASIC to use, so CLEAR $7E00 will mean 
; any memory above $7E00 will not be used ; the stack and string will be placed there.

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

