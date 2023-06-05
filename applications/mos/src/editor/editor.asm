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
		lda 	OSXPos 						; save edit point.
		sta 	OSXEdit
		lda 	OSYPos
		sta 	OSYEdit

		lda 	OSEditLength 				; edit point at end of line.
		sta 	OSEditPos
		stz 	OSEditScroll 				; no initial scrolling

		sec 								; calculate edit box width.
		lda 	OSXSize
		sbc 	OSXPos
		sta 	OSEditWidth

		sec 								; force repaint.
		jsr 	OSEUpdatePosition 			; update the position.
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

		
; ************************************************************************************************
;
;			Update the scrolling position. Repaint on this changing or CS on entry
;
; ************************************************************************************************

OSEUpdatePosition:
		.debug
		php 								; save repaint flag.
		lda 	OSEditScroll 				; save old edit scroll position.
		pha
		jsr 	OSECheckPosition 			; check position in range of text
		jsr 	OSECheckVisible 			; is it on screen ?

		pla 								; has the edit scroll position changed ?
		cmp 	OSEditScroll 				
		beq 	_OSECVNoChange
		plp 								; if so, set repaint flag
		sec
		php
_OSECVNoChange:
		plp	 								; do we need a repaint.
		bcc 	_OSECVNoRepaint
		jsr 	OSERepaint
_OSECVNoRepaint:				
		rts		

; ************************************************************************************************
;
;					Check position actually in the range of the string
;
; ************************************************************************************************

OSECheckPosition:
		lda 	OSEditPos 					; if position = 255 (e.g. -1) then off left.
		cmp 	#255
		bne 	_OSECPNotLeft
		stz 	OSEditPos 
		rts
_OSECPNotLeft:
		cmp 	OSEditLength 				; if >= edit length reset to edit length
		bne 	_OSEPCNotRight
		lda 	OSEditLength
		sta 	OSEditPos
_OSEPCNotRight:		
		rts

; ************************************************************************************************
;
;							Check actually visible on the screen
;
; ************************************************************************************************

OSECheckVisible:
		lda 	OSEditPos 					; if editpos < editscroll
		cmp 	OSEditScroll
		bcs 	_OSENotOffLeft
		sta 	OSEditScroll 				; then scroll at that position.
		rts

_OSENotOffLeft:								; if editpos - editscroll >= editwidth off screen
		sec
		lda 	OSEditPos
		sbc 	OSEditScroll
		cmp 	OSEditWidth
		bcs 	_OSEOffRight
		rts

_OSEOffRight:													

; ************************************************************************************************
;
;							Repaint according to current settings.
;
; ************************************************************************************************

OSERepaint:
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

