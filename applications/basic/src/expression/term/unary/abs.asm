; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		abs.asm
;		Purpose:	Absolute value of number
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								Absolute value of number
;
; ************************************************************************************************

		.section code	

EXPUnaryAbs: ;; [abs(]
		jsr 	EXPEvalNumber 					; number to R0
		jsr 	ERRCheckRParen 					; )
		jsr 	IFloatAbsoluteR0 				; take absolute value of it.
		rts

		.send code

;: [abs(n)]\
; Returns the absolute value of the parameter\
; { print abs(-4) , abs(5) } prints 4 5
				
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

