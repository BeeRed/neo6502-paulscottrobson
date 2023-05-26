; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		val.asm
;		Purpose:	Convert string to number
;		Created:	22nd May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						Convert string to number
;
; ************************************************************************************************

		.section code	

EXPUnaryVal: ;; [val(]
		jsr 	EXPEvalString 					; string to R0, zTemp0		
		jsr 	ERRCheckRParen 					; )
		phy
		clc
		lda		zTemp0 							; point XY to the text
		adc 	#2
		tax
		lda 	zTemp0+1
		adc 	#0
		tay
		lda 	(zTemp0) 						; get length.
		jsr 	IFloatStringToFloatR0 			; do conversion
		bcs 	_EUVError
		ply
		rts
_EUVError:
		.error_value		

		.send code

;: [val(string)]\
; Converts string to a number. Errors if not possible.\
; { print val("146") } prints 146

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

