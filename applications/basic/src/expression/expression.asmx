; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		expression.asm
;		Purpose:	Evaluate expression to R0
;		Created:	21st May 2023
;		Reviewed: 	No
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
		jsr 	EXPEvaluateValTermR0		; do RHS
		;
		;		Main loop (precedence on TOS)
		;		
_EELoop:		
		lda 	(codePtr),y 				; what follows needs to be a binary operator
		bpl		_EEExit
		cmp 	#PR_BINARY_UPPER+1 		
		bcs 	_EEExit
		;
		tax 								; access the precedence of the operator.
		pla 								; restore precedence
		cmp 	EXPBinaryPrecedence-$80,x 	; if >= operator precedence then exit
		bcs 	_EEExit2
		;
		pha 								; save current precedence.
		phx 								; save operator
		iny 								; consume operator

		phx
		ldx 	#IFR0 						; push R0 on the stack
		jsr 	IFloatPushRx
		plx

		lda 	EXPBinaryPrecedence-$80,x 	; get precedence of operator, and evaluate at that precedence -> R0
		jsr 	EXPEvaluateExpressionPrecedenceA

		ldx 	#IFR1 						; pop LHS to R1.
		jsr 	IFloatPullRx

		plx 								; operator

		cpx 	#PR_LOWEST_BINARY_COMPARE  	; is it a comparison
		bcs 	_EECheckCompare

		lda 	IFR0+IExp 					; if not, both must be numbers
		ora 	IFR1+IExp
		bmi 	_EEType
		bra 	_EETypeOkay

_EECheckCompare:
		lda 	IFR0+IExp 					; if comparison must be the same type.
		eor 	IFR1+IExp
		bmi 	_EEType		

_EETypeOkay:		
		txa
		asl 	a 							; double -> X
		tax
		jsr 	_EECallBinary 				; call the operator R0 := R1 <op> R0
		bra 	_EELoop

_EEType:
		.error_type
_EECallBinary:
		jmp 	(EXPBinaryVectors,x)
_EEExit:
		pla 								; throw precedence
_EEExit2:
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

