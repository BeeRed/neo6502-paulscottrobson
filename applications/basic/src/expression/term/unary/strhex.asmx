; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		strhex.asm
;		Purpose:	Convert number to string
;		Created:	22nd May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										number to string
;
; ************************************************************************************************

		.section code	

EXPUnaryHex: ;; [hex$]
		jsr 	ERRCheckLParen 					; (
		jsr 	EXPEvalInteger 					; expr
		jsr 	ERRCheckRParen 					; )
		phy
		lda 	#16 				
		jsr 	IFloatIntegerToStringR0
		bra 	EUSMain

;: [hex$(n)]\
; Converts the integer to a hexadecimal string equivalent\
; { print hex$(154) } prints 9A

EXPUnaryStr: ;; [str$]
		jsr 	ERRCheckLParen 					; (
		jsr 	EXPEvalNumber 					; expr
		jsr 	ERRCheckRParen 					; )
		phy
		jsr 	IFloatFloatToStringR0 			; convert to string
EUSMain:		
		bcs 	_EUSError
		jsr 	EXPResetBuffer
		stx 	zTemp0
		sty 	zTemp0+1
		tax 									; count in A
		ldy 	#0
_EUSCopy:
		lda 	(zTemp0),y
		iny
		jsr 	EXPRAppendBuffer
		dex
		bne	 	_EUSCopy		
		jsr 	EXPSetupStringR0 				; and return it.
		ply
		rts

_EUSError:
		.error_range

		.send code

;: [str$(n)]\
; Converts the number to a string equivalent\
; { print str$(154.9) } prints 154.9
				
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

