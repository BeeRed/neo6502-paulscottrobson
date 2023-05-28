; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokdecimal.asm
;		Purpose:	Tokenise decimal
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;									Tokenise a decimal.
;
; ************************************************************************************************

TOKTokeniseDecimals:
		jsr 	TOKGetNext 					; consume the .
		jsr 	TOKExtractInteger 			; pull an integer out as text.
		lda 	#PR_DECIMAL				 	; decimal token
		jsr 	TOKWriteA
		jsr 	TOKOutputElementBuffer 		; then the buffer
		clc
		rts

; ************************************************************************************************
;
;							  Output current element in ASCII
;	
; ************************************************************************************************

TOKOutputElementBuffer:
		lda 	TOKElement 					; get count and write that
		jsr 	TOKWriteA
		tay 								; put in Y
		beq 	_TOEExit 					; exit if empty which is okay.
		ldx 	#1
_TOELoop: 									; output Y characters
		lda 	TOKElement,x
		jsr 	TOKWriteA
		inx
		dey
		bne 	_TOELoop		
_TOEExit:
		rts		
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

