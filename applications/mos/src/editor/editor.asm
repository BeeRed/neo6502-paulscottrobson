; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		editor.asm
;		Purpose:	Line editor
;		Created:	4th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						Edit line from current position / preset width.
;
; ************************************************************************************************

OSEditNewLine:
		stz 	OSEditLength 				; clear buffer
OSEditLine:
		lda 	OSEditLength 				; edit point at end of line.
		sta 	OSEditPos
		stz 	OSEditScroll 				; no initial scrolling
		sec 								; calculate edit box width.
		lda 	OSYSize
		sbc 	OSYPos
		sta 	OSEditWidth
		sec 								; force repaint.
		jsr 	OSECheckVisible 			; do we need to make it visible ?
_OSEditLoop:		
		jsr 	OSReadKeystroke 			; get one key.
		;
		cmp 	#3 							; down, up, esc, CR all exit
		beq 	_OSEditExit
		cmp 	#6
		beq 	_OSEditExit
		cmp 	#13
		beq 	_OSEditExit
		cmp 	#27
		bne 	_OSEditContinue
_OSEditExit:
		rts
_OSEditContinue:

		.send code
		
; ************************************************************************************************
;
;	Check if write position on screen, if not put it on screen. Repaint on this or CS on entry
;
; ************************************************************************************************

OSECheckVisible:
		rts		

; ************************************************************************************************
;
;							Repaint according to current settings.
;
; ************************************************************************************************

OSERepaint:
		rts

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

