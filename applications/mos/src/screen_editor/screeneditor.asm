; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		screeneditor.asm
;		Purpose:	Screen editor
;		Created:	29th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Screen line into buffer
;
; ************************************************************************************************

OSScreenLine:
		stz 	OSEditLength 				; clear buffer
_OSScreenLoop:		
		jsr 	OSReadKeystroke	 			; get key.
		cmp 	#$10						; insert
		beq 	_OSSInsert
		cmp 	#$07 						; delete / backspace
		beq 	_OSSDelete
		cmp 	#$08
		beq 	_OSSBackspace
		cmp 	#$0D 						; Return key ?
		beq 	_OSSReturn
		jsr 	OSWriteScreen
		bra 	_OSScreenLoop
		;
		;		Handle backspace
		;
_OSSBackspace:
		lda 	OSXPos 						; backspace blocked if first character on line
		bne 	_OSSBackspaceOk
		ldx 	OSYPos 						; and its the start of a group.
		lda 	OSNewLineFlag,x
		bne 	_OSScreenLoop
_OSSBackspaceOk:
		jsr 	OSSLeft 					; move left.
		;
		;		Handle Delete
		;
_OSSDelete:
		jsr 	OSSSaveGetFrame 			; save current position and get frame.
_OSSDeleteLoop:
		lda 	OSYFrameBottom 				; reached the end
		cmp 	OSYPos
		bcc 	_OSSDelComplete
		;
		jsr 	OSSRight 					; shuffle everything
		jsr 	OSDReadPhysical
		jsr 	OSSLeft
		jsr 	OSDWritePhysical
		jsr 	OSSRight
		bra 	_OSSDeleteLoop
_OSSDelComplete:
		jsr 	OSSLeft 					; blank last character
		lda 	#' '
		jsr 	OSDWritePhysical
		jsr 	OSSLoadPosition
		bra		_OSScreenLoop
		;
		;		Handle Insert
		;
_OSSInsert:
		.debug
		;
		;		Handle Return
		;
_OSSReturn:
		.debug		
		jsr 	OSSSaveGetFrame 			; save current position and get frame.

; ************************************************************************************************
;
;										Reset position
;
; ************************************************************************************************

OSSLoadPosition:
		ldx 	OSXPosSave	
		stx 	OSXPos 		
		ldx 	OSYPosSave
		stx 	OSYPos
		rts

; ************************************************************************************************
;
;					Save position ; establish top and bottom of frame area
;
; ************************************************************************************************

OSSSaveGetFrame:
		ldx 	OSXPos 						; save current position
		stx 	OSXPosSave	
		ldx 	OSYPos
		stx 	OSYPosSave
		;
		;		Work out top line.
		;
_OSSSFindTop:
		cpx 	#0 							; top of screen
		beq 	_OSSSTFound
		lda 	OSNewLineFlag,x  			; start of frame.
		bne 	_OSSSTFound
		dex
		bra 	_OSSSFindTop
		;
_OSSSTFound:
		stx 	OSYFrameTop		
		;
		;		Get line after bottom.
		;
		ldx 	OSYPos
_OSSSFindBottom:
		cpx 	OSYSize 					; bottom of screen
		beq 	_OSSSBFound
		lda 	OSNewLineFlag+1,x
		bne 	_OSSSBFound
		inx
		bra 	_OSSSFindBottom
		;
_OSSSBFound:
		stx 	OSYFrameBottom
		rts

; ************************************************************************************************
;
;											Move left
;
; ************************************************************************************************

OSSLeft:
		pha
		dec 	OSXPos
		bpl 	_OSSLExit
		dec 	OSYPos
		lda 	OSXSize
		dec 	a
		sta 	OSXPos
_OSSLExit:
		pla
		rts

; ************************************************************************************************
;
;											Move right
;
; ************************************************************************************************

OSSRight:
		pha
		inc 	OSXPos
		lda 	OSXPos
		cmp 	OSXSize
		bne 	_OSSRExit
		stz 	OSXPos
		inc 	OSYPos
_OSSRExit:
		pla
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

