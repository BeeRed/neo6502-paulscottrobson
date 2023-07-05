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
		.debug
		lda 	(codePtr),y 				; what's next.
		iny 								; consume it.

		cmp 	#PR_PERIOD 					; .label 
		beq 	_CALabel
		cmp 	#PR_RSQ  					; ] exit
		beq 	_CAExit
		cmp 	#PR_COLON 					; : loop back round again.
		beq 	_CALoop
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

