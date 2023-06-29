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
		pha 								; save AXY
		phx
		phy
		cmp 	#32 						; standard character $20,$FF (we allow for cyrillic possibility here)
		bcs 	_OSWriteDirect 
		;
		cmp 	#16 						; 16-32 for set colours, reserved - this copies fgr -> bgr, updates fgr.
		bcs 	_OSWriteDeviceExit
		;
		asl 	a 							; make to an offset in vector table
		tax
		lsr 	a
		jsr 	_OSCallVectorCode 			; call that code
		bra 	_OSWriteDeviceExit 			; and leave
		;
_OSWriteDirect:
		jsr 	OSDWritePhysical 			; $20-$FF write to screen
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
		.word 	_OSWNoFunction				; $05 	
		.word 	_OSCursorUp 				; $06	Up 			(Ctrl-F)
		.word 	_OSWNoFunction 				; $07 	Delete 		(Del)
		.word 	_OSBackspace				; $08 	Backspace 	(Backspace)
		.word 	_OSWHTab 					; $09	Tab 		(Tab stop)
		.word 	_OSWNoFunction 				; $0A
		.word 	_OSWNoFunction 				; $0B
		.word 	_OSClearScreen 				; $0C	ClearScreen	(Ctrl-L)
		.word 	_OSNewLine 					; $0D 	CarriageRet (Enter)
		.word 	_OSWNoFunction 				; $0E   
		.word 	_OSWNoFunction 				; $0F

		; these are keys in only.			; $10 	Insert key.
											; $11-A Function Keys 1-10
											; $1B 	Escape key.

; ************************************************************************************************
;
;								Cursor movement functionality
;
; ************************************************************************************************
;
;		Right to next TAB
;
_OSWHTab:									; move right.
		jsr 	_OSCursorRight
		lda 	OSXPos
		and 	#7
		bne 	_OSWHTab
		rts
;
;		Backspace (e.g. back one and erase)
;
_OSBackspace:
		lda 	OSXPos 						; left side already ?
		beq 	_OSCLExit
		dec 	OSXPos 						; go left one.
		lda 	#' ' 						; ovewrite the character there.
		jsr 	OSDWritePhysical
		rts
;
;		Cursor left
;
_OSCursorLeft:
		lda 	OSXPos 						; left side
		dec 	OSXPos 						; cursor left		
		cmp 	#0 							; if at left side
		bne 	_OSCLExit 					; no, exit
		lda 	OSXSize 					; yes, shift to right.
		dec 	a
		sta 	OSXPos
_OSCLExit:
		rts
;
;		Cursor right 
;
_OSCursorRight:
		inc 	OSXPos 						; go right ?
		lda 	OSXPos 						; reached right side ?
		cmp 	OSXSize
		bne 	_OSCLExit 					; no, then exit
		stz 	OSXPos 						; back to left
		rts
;
;		Cursor down
;	
_OSCursorDown:
		inc 	OSYPos 						; down one line.
		lda 	OSYPos 						; reached bottom
		cmp 	OSYSize
		bcc 	_OSCDExit 					; no, we're done.
		stz 	OSYPos 						; position back to top line
_OSCDExit:
		rts
;
;		Cursor up
;
_OSCursorUp:
		dec 	OSYPos 						; up one line ?
		bpl 	_OSCUExit 					; exit if still on screen
		lda 	OSYSize 					; back to top
		dec 	a
		sta 	OSYPos 		
_OSCUExit:		
		rts
;
;		Cursor forward on screen.
;		
_OSCursorAdvance:
		inc 	OSXPos 						; try moving right
		lda 	OSXPos						; reached the write.
		cmp 	OSXSize
		bne 	_OSLCExit 	 				; exit if not at the RHS.
		ldx 	#0 							; we want to zero any consequent CRs.
;
;		Carriage return, start of next line.
;		
_OSNewLine:		
		phx 								; save CR/char flag.
		stz 	OSXPos 						; left side
		inc 	OSYPos 						; down one.
		lda 	OSYPos 						; reached the bottom
		cmp 	OSYSize
		bcc 	_OSLCUpdateCR				; no, update CR flag and exit
		lda 	OSYSize 					; bottom of screen
		dec 	a
		sta 	OSYPos 						; back up one line
		jsr 	OSDScrollUp 				; scroll the whole screen up.
		ldx 	#0 							; scroll the CR flag table up 
_OSNLScrollFlag:
		lda 	OSNewLineFlag+1,x		
		sta 	OSNewLineFlag,x	
		inx
		cpx 	OSYSize
		bne	 	_OSNLScrollFlag
_OSLCUpdateCR:		
		ldx 	OSYPos 						; set appropriate flag.
		pla
		sta 	OSNewLineFlag,x
_OSLCExit:		
		rts		
;
;		Clear Screen.
;		
_OSClearScreen:
		jsr 	OSDClearScreen 				; physical clear.
		ldx 	OSYSize 					; set all the CR flags on each row
_OSCSSetLoop:
		lda 	#$FF
		sta 	OSNewLineFlag-1,x
		dex
		bne		_OSCSSetLoop
		rts		
;
;		Home position.
;
OSHomeCursor: 								; home cursor.
		stz 	OSXPos
		stz	 	OSYPos
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
