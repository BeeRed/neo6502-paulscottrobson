; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		osrom.asm
;		Purpose:	OSRom wrapper program.
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										  Clear Screen
;
; ************************************************************************************************

OSClearScreen:		
		lda 	#$C0 						; set screen pos.
		sta 	rTemp0+1
		stz 	rTemp0
		ldy 	OSYSize 					; clear height * width bytes.
_OSCSLoop1:		
		ldx 	OSXSize
_OSCSLoop2:
		lda 	#' '
		sta 	(rTemp0)
		inc 	rTemp0
		bne 	_OSCSNoCarry
		inc 	rTemp0+1
_OSCSNoCarry:
		dex
		bne 	_OSCSLoop2
		dey
		bne 	_OSCSLoop1 	
		jsr 	OSHomeCursor 				; cursor to (0,0)
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

