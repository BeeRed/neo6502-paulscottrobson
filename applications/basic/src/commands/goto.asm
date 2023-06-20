; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		goto.asm
;		Purpose:	GOTO line number
;		Created:	20th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										GOTO Command
;
; ************************************************************************************************

		.section code

Command_GOTO:	;; [goto]
		jsr 	EXPEvalInteger16 			; get line number
GotoR0:		
		lda 	PGMBaseHigh 				; back to the program start
		sta 	codePtr+1
		stz 	codePtr
		;
_GOSearch:		
		lda 	(codePtr) 					; end of program.
		beq 	_GOError
		ldy 	#1 							; found line #
		lda 	(codePtr),y
		cmp 	IFR0+IM0
		bne 	_GONext
		iny
		lda 	(codePtr),y
		cmp 	IFR0+IM1
		bne 	_GONext
		jmp 	RUNNewLine

_GONext:		
		clc 								; advance to next line.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_GOSearch
		inc 	codePtr+1
		bra 	_GOSearch
		
_GOError:		
		.error_line

		.send code
		
;:[GOTO line]
; Transfer execution to given line number. Not recommended except for old software.
				
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

