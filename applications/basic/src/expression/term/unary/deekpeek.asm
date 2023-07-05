; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		deekpeek.asm
;		Purpose:	Deek and Peek
;		Created:	3rd June 2023
;		Reviewed: 	5th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										Read Memory
;
; ************************************************************************************************

		.section code	

EXPUnaryPeek: ;; [peek(]
		jsr 	EXPEvalInteger16 				; number to R0
		jsr 	ERRCheckRParen 					; )
		lda 	(IFR0) 							; read byte and set it
		ldx 	#IFR0
		jsr 	IFloatSetByte
		rts

;: [peek(n)]\
; Returns the byte at memory location n\
; { print peek(32707) }

EXPUnaryDeek: ;; [deek(]
		jsr 	EXPEvalInteger16 				; number to R0
		jsr 	ERRCheckRParen 					; )

		phy 									; read MSB and push on stack
		ldy 	#1
		lda 	(IFR0),y
		ply
		pha

		lda 	(IFR0) 							; set LSB
		ldx 	#IFR0
		jsr 	IFloatSetByte
		pla 									; set MSB
		sta 	IFR0+IM1
		rts

;: [deek(n)]\
; Returns the word at memory location n\
; { print deek(32707) }

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

