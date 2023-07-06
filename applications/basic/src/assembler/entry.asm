; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		entry.asm
;		Purpose:	Assembler entry point
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Assembler command (takes over RUN thread)
;
; ************************************************************************************************

		.section code

Command_AssemblerStart: 	;; [[]		
		;
		;		Main assembly loop
		;
_CALoop:
		lda 	(codePtr),y 				; what's next.
		iny 								; consume it.

		cmp 	#PR_PERIOD 					; .label 
		beq 	_CALabel
		cmp 	#PR_RSQ  					; ] exit
		beq 	_CAExit
		cmp 	#PR_COLON 					; : loop back round again.
		beq 	_CALoop
		cmp 	#PR_LSQLSQENDRSQRSQ 		; end of line.
		beq 	_CAEnd
		;
		and 	#$C0 						; is it an identifier (which we will make an opcode)
		cmp 	#$40
		beq 	_CAOpcode
		.error_syntax 						; give up

_CALabel:
		jsr 	ASLabel 					; handle a label
		bra 	_CALoop

_CAOpcode:
		dey 								; get it back
		jsr 	ASOpcode 					; assemble that opcode.
		bra 	_CALoop

_CAEnd:	clc 								; next line
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_CANoCarry
		inc 	codePtr+1
_CANoCarry:

		ldy 	#1 							; copy error line#
		lda 	(codePtr),y 
		sta 	ERRLine
		iny
		lda 	(codePtr),y 
		sta 	ERRLine+1
		ldy 	#3 							; tokenised code position.

		lda 	(codePtr) 					; code present
		bne 	_CALoop 					; go round again
		jmp 	Command_END 				; do END.

_CAExit:
		rts		
		
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

