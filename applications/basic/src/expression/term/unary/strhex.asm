; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		strhex.asm
;		Purpose:	Convert number to string
;		Created:	26th May 2023
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

EXPUnaryHex: ;; [hex$(]
		jsr 	EXPEvalInteger 					; expr
		jsr 	ERRCheckRParen 					; )
		phy
		lda 	#16 				
		jsr 	IFloatIntegerToStringR0
		bra 	EUSMain

;: [hex$(n)]\
; Converts the integer to a hexadecimal string equivalent\
; { print hex$(154) } prints 9A

EXPUnaryStr: ;; [str$(]
		jsr 	EXPEvalNumber 					; expr
		jsr 	ERRCheckRParen 					; )
		phy
		jsr 	IFloatFloatToStringR0 			; convert to string
EUSMain:		
		bcs 	_EUSError

		stx 	zTemp0 							; save string address
		sty 	zTemp0+1

		lda 	#32 							; allocate space for result.
		jsr 	StringTempAllocate

		lda 	(zTemp0) 						; get count
		tax 									; count in X
		ldy 	#1
_EUSCopy:
		lda 	(zTemp0),y
		iny
		jsr 	StringTempWrite
		dex
		bne	 	_EUSCopy		
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

