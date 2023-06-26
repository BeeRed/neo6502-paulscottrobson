; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		charout.asm
;		Purpose:	Write character / control to device
;		Created:	25th May 2023
;		Reviewed: 	26th June 2024
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
		ldx 	#0 							; screen is device #0
		jsr 	OSWriteDevice
		plx
		rts

; ************************************************************************************************
;
;						Write character A to device X (x = 0 => screen)
; 				(currently there is only the screen, device 0, to write to !)
;
; ************************************************************************************************

OSWriteDevice:
		pha 								; save AXY
		phx
		phy
		cmp 	#32 						; standard character $20,$FF (we allow for cyrillic possibility here)
		bcs 	_OSWriteDirect 
		;
		cmp 	#16 						; 16-32 for set colours, reserved.
		bcs 	_OSWriteDeviceExit
		;
		asl 	a 							; make to an offset in vector table
		tax
		lsr 	a
		jsr 	_OSCallVectorCode 			; call that code
		bra 	_OSWriteDeviceExit 			; and leave
		;
_OSWriteDirect:
		jsr 	OSWritePhysical 			; $20-$FF write to screen
		jsr 	_OSCursorAdvance 			; and forwards.
_OSWriteDeviceExit:		
		ply
		plx
		pla
		clc 								; written fine.
		rts

_OSCallVectorCode: 							; no jsr ($xxxx,X)
		jmp 	(_OSWDVector,x) 			

_OSWNoFunction: 							; dummy.
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

		; these are keys in only.			; $10 	
											; $11-A Function Keys 1-10
											; $1B 	Escape key.

; ************************************************************************************************
;
;								Cursor movement functionality
;
; ************************************************************************************************
;
;		Backspace (e.g. back one and erase)
;
_OSBackspace:
		lda 	OSXPos 						; left side already ?
		beq 	_OSCLExit
		dec 	OSXPos 						; go left one.
		lda 	#' ' 						; ovewrite the character there.
		jsr 	OSWritePhysical
		rts
;
;		Cursor left
;
_OSCursorLeft:
		lda 	OSXPos 						; left side
		beq 	_OSCLExit 					; yes, exit
		dec 	OSXPos 						; cursor left		
_OSCLExit:
		rts
;
;		Cursor right (limited to RHS)
;
_OSCursorRight:
		lda 	OSXPos 						; reached right side ?
		inc 	a
		cmp 	OSXSize
		beq 	_OSCRExit 					; yes, exit, no, fall through.
;
;		Cursor forward on screen.
;		
_OSCursorAdvance:
		inc 	OSXPos 						; advance cursor and position.
		lda 	OSXPos 						; reached RHS
		cmp 	OSXSize
		bcc 	_OSCRExit 					; if not, then exit.
;
;		Carriage return, start of next line.
;		
_OSNewLine:		
		stz 	OSXPos 						; start next line.
;
;		Cursor down
;	
_OSCursorDown:
		inc 	OSYPos 						; down one line.
		lda 	OSYPos 						; reached bottom
		cmp 	OSYSize
		bcc 	_OSCRExit 					; no, we're done.
		dec 	OSYPos 						; position back to bottom line.
		jsr 	OSScrollUp 					; scroll whole screen up.
_OSCRExit:
		rts
;
;		Cursor up
;
_OSCursorUp:
		dec 	OSYPos 						; up one line ?
		bpl 	_OSCRExit 					; exit if still on screen
		inc 	OSYPos 						; fix up position.
		jsr 	OSScrollDown 				; scroll down.
		rts
;
;		Right to next TAB
;
_OSWHTab:									; move right.
		jsr 	_OSCursorAdvance
		lda 	OSXPos
		and 	#7
		bne 	_OSWHTab
		rts
;
;		Home position.
;
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

