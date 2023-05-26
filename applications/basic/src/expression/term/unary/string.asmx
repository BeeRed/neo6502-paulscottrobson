; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		string.asm
;		Purpose:	Unary string 'function' (e.g. [[EXPRING]])
;		Created:	21st May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Inline immutable string
;
; ************************************************************************************************

		.section code	

EXPUnaryInlineString: ;; [[[STRING]]]
		lda 	(codePtr),y 				; string length
		cmp 	#EXPMaxStringSize
		bcs 	_EXPUISRange 				; too long

		jsr 	EXPResetBuffer 				; reset the buffer
		iny 								; consume length
		tax 								; count zero, length to X
		beq 	_EXPUIDone
_EXPUICopy:
		lda 	(codePtr),y
		iny		
		jsr 	EXPRAppendBuffer	
		dex
		bne 	_EXPUICopy
_EXPUIDone:
		jsr 	EXPSetupStringR0 			; set up the temporary string in R0		
		rts

_EXPUISRange:
		.error_range


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

