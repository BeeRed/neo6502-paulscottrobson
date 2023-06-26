; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		chr.asm
;		Purpose:	Convert integer to string
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Byte to String with that ASCII character
;
; ************************************************************************************************

		.section code	

EXPUnaryChr: ;; [CHR$(]
		jsr 	EXPEvalInteger8 				; expr
		pha 									; push on stack
		jsr 	ERRCheckRParen 					; )
		lda 	#1 								; alloc temp mem for result, 1 byte only.
		jsr 	StringTempAllocate
		pla 									; get value back
		jsr 	StringTempWrite 				; write to string.
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

