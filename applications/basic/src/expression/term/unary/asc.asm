; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		asc.asm
;		Purpose:	ASCII value of first character
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								ASCII code of first character
;
; ************************************************************************************************

		.section code	

EXPUnaryAsc: ;; [ASC(]
		jsr 	EXPEvalString 					; string to R0, zTemp0		
		jsr 	ERRCheckRParen 					; )

		lda 	(zTemp0) 						; length 0 ?
		beq 	_EXAZero 						; if so return 0

		phy 									; otherwise get first character
		ldy 	#1 
		lda 	(zTemp0),y
		ply

_EXAZero:		
		ldx 	#IFR0
		jsr 	IFloatSetByte
		rts

		.send code

;: [asc(string)]\
; Returns the ASCII code of the first character of the string or zero if empty.\
; { print asc("!") } prints 33
				
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

