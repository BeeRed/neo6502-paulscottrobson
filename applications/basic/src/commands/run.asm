; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		run.asm
;		Purpose:	Run Program
;		Created:	26th May 2023
;		Reviewed: 	5th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										RUN Command
;
; ************************************************************************************************

		.section code

Command_RUN:	;; [run]

		jsr 	ClearCode					; clear everything out.

		lda 	PGMBaseHigh 				; back to the program start
		sta 	codePtr+1
		stz 	codePtr
		bra 	RUNNewLine

;:[RUN]\
; Runs the current program, clearing all variables and arrays first.

		; ----------------------------------------------------------------------------------------
		;
		;								End of current line
		;
		; ----------------------------------------------------------------------------------------

RUNEndOfLine: ;; [[[end]]]
		clc 								; advance to next line.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_RELNoCarry
		inc 	codePtr+1
_RELNoCarry:		

		; ----------------------------------------------------------------------------------------
		;
		;									New line
		;
		; ----------------------------------------------------------------------------------------

RUNNewLine:
		ldx 	#$FF 						; 6502 stack reset.
		txs
		lda 	(codePtr) 					; check off end of program
		beq 	Command_END
		ldy 	#1 							; copy error line#
		lda 	(codePtr),y 
		sta 	ERRLine
		iny
		lda 	(codePtr),y 
		sta 	ERRLine+1
		iny 								; offset into codePtr for start of line.

		; ----------------------------------------------------------------------------------------
		;
		;									New command
		;
		; ----------------------------------------------------------------------------------------

RUNNewCommand:		
		stz 	stringInitialised 			; reset string system flag.

		dec 	checkCounter				; don't do these checks ever command
		bne 	_RNCNoCheck
		phy 								; keyboard check.
		jsr 	OSKeyboardDataProcess
		ply
		jsr 	OSCheckBreak 				; check escape.
		bne 	_RUNBreak
_RNCNoCheck:		

		lda 	(codePtr),y 				; get next token
		bpl		_RUNNotToken 				; probably an identifier
		iny 								; consume token
		cmp 	#PR_COLON 					; fast skip colon
		beq 	RUNNewCommand

		cmp 	#PR_STANDARD_LAST+1 		; check unary function
		bcs 	_RUNSyntax
		cmp 	#PR_STRUCTURE_FIRST 		; adjust for binaries at start.
		bcc 	_RUNSyntax

		asl 	a 							; double into X.
		tax
		jsr 	_RUNDispatchMain			; call the main dispatcher
		bra 	RUNNewCommand

_RUNDispatchMain:
		jmp 	(VectorTable,x)
	
_RUNSyntax:
		.error_syntax
_RUNBreak:
		.error_break

		; ----------------------------------------------------------------------------------------
		;
		; 							Handle non-token commands
		;
		; ----------------------------------------------------------------------------------------

_RUNNotToken:		
		cmp 	#$40 						; 00-3F is a syntax error (numbers)
		bcc 	_RUNSyntax
		jsr 	CommandLET 					; assignment
		bra 	RUNNewCommand 				; loop round.

; ************************************************************************************************
;
;										Shifted command
;
; ************************************************************************************************

Command_Shift_Handler: ;; [[[shift]]]
		lda 	(codePtr),y 				; get token shifted
		iny
		asl 	a 							; double into X
		tax
		jmp 	(AlternateVectorTable,x) 	; and go there.

; ************************************************************************************************
;
;										END command
;
; ************************************************************************************************

Command_END: ;; [end]
		jmp 	WarmStart

;:[END]\
; Ends the current program and returns to the main prompt.

		.send code

		.section storage
checkCounter:
		.fill 	1
		.send storage

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		28/06/23 		Implemented [[shift]].
;
; ************************************************************************************************

