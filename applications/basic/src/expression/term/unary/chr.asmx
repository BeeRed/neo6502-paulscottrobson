; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		chr.asm
;		Purpose:	Convert integer to string
;		Created:	21st May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										Byte to String
;
; ************************************************************************************************

		.section code	

EXPUnaryChr: ;; [CHR$]
		jsr 	ERRCheckLParen 					; (
		jsr 	EXPEvalInteger8 				; expr
		pha 									; push on stack
		jsr 	ERRCheckRParen 					; )
		jsr 	EXPResetBuffer 					; reset buffer and write that byte.
		pla
		jsr 	EXPRAppendBuffer
		jsr 	EXPSetupStringR0 				; and return it.
		rts

		.send code

;: [chr$(n)]\
; Returns a one character string containing the character whose ASCII code is n\
; { print chr$(42) } prints *
				
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

