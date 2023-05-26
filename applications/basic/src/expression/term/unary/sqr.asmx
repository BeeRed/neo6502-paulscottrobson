; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		sqr.asm
;		Purpose:	Square Root unary
;		Created:	21st May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									String length
;
; ************************************************************************************************

		.section code	

EXPUnarySqr: ;; [SQR(]
		jsr 	EXPEvalNumber 					; number to R0
		jsr 	ERRCheckRParen 					; )
		jsr 	IFloatSquareRootR0 				; square root.
		bcs 	_EUSValue
		rts
_EUSValue:
		.error_range		

		.send code

;: [sqr(n)]\
; Returns the square root of the given number \
; { print sqr(144) } prints 12.0

				
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

