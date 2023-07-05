; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		expression.asm
;		Purpose:	Evaluate expression to R0
;		Created:	26th May 2023
;		Reviewed: 	5th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						Evaluate an expression into R0 from (codePtr),y
;
; ************************************************************************************************

		.section code	

EXPEvaluateExpression:
		lda 	#0 							; current precedence
EXPEvaluateExpressionPrecedenceA:
		pha		
		jsr 	EXPTermValueR0				; do first term.
		;
		;		Main loop (precedence on TOS)
		;		
_EELoop:		
		lda 	(codePtr),y 				; what follows needs to be a binary operator
		cmp 	#PR_BINARY_FIRST 			; binary tokens are the last ones up to $FF
		bcc 	_EEExit
		;
		tax 								; access the precedence of the operator.
		pla 								; restore precedence.if >= operator precedence then exit
		cmp 	BinaryPrecedence-PR_BINARY_FIRST,x 	
		bcs 	_EEExit2
		;
		pha 								; save current precedence.
		phx 								; save operator
		iny 								; consume operator

		phx
		ldx 	#IFR0 						; push R0 on the stack
		jsr 	IFloatPushRx
		plx
											; get precedence of operator, and evaluate at that precedence -> R0
		lda 	BinaryPrecedence-PR_BINARY_FIRST,x 	
		jsr 	EXPEvaluateExpressionPrecedenceA

		ldx 	#IFR1 						; pop LHS to R1.
		jsr 	IFloatPullRx

		plx 								; operator

		lda 	IFR0+IExp 					; check if types match.
		eor 	IFR1+IExp
		bmi 	_EEType		 				; MSBs differ, error.

_EETypeOkay:		
		txa
		asl 	a 							; double -> X
		tax
		jsr 	_EECallBinary 				; call the operator R0 := R1 <op> R0
		bra 	_EELoop

_EEType:
		.error_type
_EECallBinary:
		jmp 	(VectorTable,x)
_EEExit:
		pla 								; throw precedence
_EEExit2:
		clc 					
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

