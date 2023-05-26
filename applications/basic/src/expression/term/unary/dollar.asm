; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dollar.asm
;		Purpose:	Dollar pass through
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								Dollar pass through for hex
;
; ************************************************************************************************

		.section code	

EXPUnaryNull: ;; [$]
		jsr 	EXPTermValueR0
		rts

		.send code

;: $\
; $ is used as a hexadecimal marker, so if you have $7FFE in your code it is the same as the
; constant 32766. This can improve readability.\
; { print $2a } prints 42
				
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
