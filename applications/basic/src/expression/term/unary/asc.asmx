; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		asc.asm
;		Purpose:	ASCII value of first character
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

EXPUnaryAsc: ;; [ASC(]
		jsr 	EXPEvalString 					; string to R0, zTemp0		
		jsr 	ERRCheckRParen 					; )

		phy 									; figure out length zero ?
		ldy 	#1
		lda 	(zTemp0)
		ora 	(zTemp0),y
		beq 	_EXAZero 						; if so return 0
		iny 									; otherwise return offset 2
		lda 	(zTemp0),y
_EXAZero:		
		ldx 	#IFR0
		jsr 	IFloatSetByte
		ply
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

