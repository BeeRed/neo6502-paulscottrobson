; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		run.asm
;		Purpose:	Run Program
;		Created:	26th May 2023
;		Reviewed: 	No
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
	
		jsr 	Command_CLEAR 				; clear everything out.

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
		ldy 	#3 							; offset into codePtr for start of line.

		; ----------------------------------------------------------------------------------------
		;
		;									New command
		;
		; ----------------------------------------------------------------------------------------

RUNNewCommand:		
		stz 	stringInitialised 			; reset string system.
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

		; ----------------------------------------------------------------------------------------
		;
		; 							Handle non-token commands
		;
		; ----------------------------------------------------------------------------------------

_RUNNotToken:		
		.error_unimplemented

; ************************************************************************************************
;
;										Shifted command
;
; ************************************************************************************************

Command_Shift_Handler: ;; [[[shift]]]
		.error_unimplemented

; ************************************************************************************************
;
;										END command
;
; ************************************************************************************************

Command_END: ;; [end]
		jmp 	$FFFF

;:[END]\
; Ends the current program and returns to the main prompt.

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

