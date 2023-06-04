; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		charout.asm
;		Purpose:	Write character / control to device
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Write character A to screen
;
; ************************************************************************************************

OSWriteScreen:
		phx
		ldx 	#0
		jsr 	OSWriteDevice
		plx
		rts

; ************************************************************************************************
;
;						Write character A to device X (x = 0 => screen)
;
; ************************************************************************************************

OSWriteDevice:
		pha
		phx
		phy
		cmp 	#32 						; standard character
		bcs 	_OSWriteDirect 
		cmp 	#16 						; 16-32 for set colours, reserved.
		bcs 	_OSWriteDeviceExit
		asl 	a 							; make to an offset in vector table
		tax
		lsr 	a
		jsr 	_OSCallVectorCode
		bra 	_OSWriteDeviceExit
_OSWriteDirect:
		jsr 	OSWritePhysical
		jsr 	_OSCursorAdvance
_OSWriteDeviceExit:		
		ply
		plx
		pla
		clc 								; written fine.
		rts

_OSCallVectorCode:
		jmp 	(_OSWDVector,x) 			
_OSWNoFunction:
		rts
_OSWDVector:
		.word 	_OSWNoFunction 				; $00 	No operation
		.word 	_OSCursorLeft 				; $01 	Left 		(Ctrl-A)
		.word 	OSHomeCursor 				; $02 	Home Cursor (Ctrl-B)
		.word 	_OSCursorDown 				; $03 	Down 		(Ctrl-C)
		.word 	_OSCursorRight 				; $04 	Right 		(Ctrl-D)
		.word 	_OSCursorAdvance			; $05 	Advance 
		.word 	_OSCursorUp 				; $06	Up 			(Ctrl-F)
		.word 	_OSWNoFunction 				; $07 	Delete 		(Del)
		.word 	_OSBackspace				; $08 	Backspace 	(Backspace)
		.word 	_OSWHTab 					; $09	Tab
		.word 	_OSWNoFunction 				; $0A
		.word 	_OSWNoFunction 				; $0B
		.word 	OSClearScreen 				; $0C	ClearScreen	(Ctrl-L)
		.word 	_OSNewLine 					; $0D 	CarriageRet (Enter)
		.word 	OSScrollUp 					; $0E 	Scroll Up 	(e.g. off bottom)
		.word 	OSScrollDown 				; $0F 	Scroll Down (e.g. off top)
											; $10 	
											; $11-A Function Keys 1-10
											; $1B 	Escape key.

; ************************************************************************************************
;
;								Cursor movement functionality
;
; ************************************************************************************************

_OSBackspace:
		lda 	OSXPos 						; left side already ?
		beq 	_OSCLExit
		dec 	OSXPos
		lda 	#' '
		jsr 	OSWritePhysical
		rts

_OSCursorLeft:
		lda 	OSXPos 						; left side
		beq 	_OSCLExit 					; yes, exit
		dec 	OSXPos 						; cursor left		
_OSCLExit:
		rts

_OSCursorRight:
		lda 	OSXPos 						; reached right side ?
		inc 	a
		cmp 	OSXSize
		beq 	_OSCRExit 					; yes, exit.
		;
_OSCursorAdvance:
		inc 	OSXPos 						; advance cursor and position.
		lda 	OSXPos 						; reached RHS
		cmp 	OSXSize
		bcc 	_OSCRExit 					; if so exit.
		;
_OSNewLine:		
		stz 	OSXPos 						; start next line.
_OSCursorDown:
		inc 	OSYPos
		lda 	OSYPos 						; reached bottom
		cmp 	OSYSize
		bcc 	_OSCRExit
		dec 	OSYPos 						; back to bottom line.
		jsr 	OSScrollUp 					; scroll whole screen up.
_OSCRExit:
		rts

_OSCursorUp:
		dec 	OSYPos 						; up
		bpl 	_OSCRExit 					; still on screen
		inc 	OSYPos 						; fix up
		jsr 	OSScrollDown 				; scroll down.
		rts

_OSWHTab:									; move right.
		jsr 	_OSCursorAdvance
		lda 	OSXPos
		and 	#7
		bne 	_OSWHTab
		rts

OSHomeCursor: 								; home cursor.
		stz 	OSXPos
		stz 	OSYPos
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

