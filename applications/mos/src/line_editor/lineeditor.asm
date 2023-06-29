; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		lineeditor.asm
;		Purpose:	Line editor
;		Created:	5th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;			Edit line into buffer - classic type-in with backspace/CR nothing else
;
; ************************************************************************************************

OSEnterLine:
		stz 	OSEditLength 				; clear buffer

		sec 								; calculate edit box max width.
		lda 	OSXSize
		sbc 	OSXPos
		dec 	a 							; one for RHS
		sta 	OSEditWidth

_OSEditLoop:		
		jsr 	OSReadKeystroke 			; get one key.
		cmp 	#' '	 					; standard character
		bcs 	_OSECharacter
		cmp 	#8 							; check for backspace
		beq 	_OSEBackspace
		cmp 	#13	 						; check for CR.
		bne 	_OSEditLoop 				; ignore everything else
		;
		jsr 	OSWriteScreen
		ldx 	OSEditLength 				; make it ASCIIZ as well (!)
		stz 	OSEditBuffer,x
		ldx 	#OSEditLength & $FF 		; XY = Buffer
		ldy 	#OSEditLength >> 8
		rts
		;
		;		Backspace
		;
_OSEBackspace:
		ldx 	OSEditLength 				; can't backspace past beginning
		beq 	_OSEditLoop
		jsr 	OSWriteScreen 				; backspace one.
		dec 	OSEditLength
		bra 	_OSEditLoop
		;
		;		Standard character
		;
_OSECharacter:		
		ldx 	OSEditLength 				; too many characters ?
		cpx 	OSEditWidth
		beq 	_OSEditLoop
		sta 	OSEditBuffer,x 				; write in buffer
		inc 	OSEditLength 				; bump length
		jsr 	OSWriteScreen
		bra 	_OSEditLoop

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

