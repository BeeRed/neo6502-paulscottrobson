; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		ps2keyboard.asm
;		Purpose:	Process PS/2 scancodes -> keystrokes & status
;		Created:	25th May 2023
;		Reviewed: 	26th May 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Process keyboard input queue
;
; ************************************************************************************************

OSKeyboardDataProcess:
		lda 	$CF00 						; read keyboard port
		beq 	_OSKExit 					; no events available.

		cmp 	#$F0 						; check key up ?
		beq 	_OSKUp
		cmp 	#$E0 						; check extended scancode ?
		beq 	_OSKShift

		ora 	OSIsKeyShift 				; actual key code - sets bit 7 if extended scancode.

		pha
		jsr 	OSKeyboardUpdateBits 		; update the up/down bits
		pla

		ldx 	OSIsKeyUp 					; if key up reset up and shift flags.
		beq 	_OSKInsertQueue 			; if key down insert into queue

		stz 	OSIsKeyUp 					; reset up/shift
		stz 	OSIsKeyShift
		bra 	_OSKExit

_OSKInsertQueue:							; insert keystroke into queue.
		jsr 	OSTranslateToASCII 			; convert to ASCII
		bcs 	_OSKExit 					; carry set, exit (unknown key)
		jsr 	OSInsertKeyboardQueue 		; insert into keyboard queue.
		bra 	_OSKExit

_OSKShift: 									; received $E0 (shift)
		lda 	#$80 						; set this so the OR seets bit 7.
		sta 	OSIsKeyShift
		bra 	_OSKExit

_OSKUp:
		dec 	OSIsKeyUp 					; received $F0 (key up), set that flag

_OSKExit:		
		lda 	OSKeyStatus+$0E 			; and on the way out check if ESC was pressed.
		and 	#$40
		sta 	OSEscapePressed
		rts

; ************************************************************************************************
;
;									Update key status bits table
;
; ************************************************************************************************

OSKeyboardUpdateBits:
		ldx 	#0 							; offset in table		
_OSKUCalculate: 								
		cmp 	#8 							; work out the row
		bcc 	_OSKUHaveRow
		inx
		sec
		sbc 	#8
		bra 	_OSKUCalculate
_OSKUHaveRow:
		tay 								; work out the column
		lda 	#0
		sec
_OSKUCalculate2:
		rol 	a
		dey
		bpl 	_OSKUCalculate2  			; at end , A is bitmask, X is row (table entry)

		bit 	OSIsKeyUp 					; check up
		bmi 	_OSKUUp 
		ora 	OSKeyStatus,x 				; down set bit
		sta 	OSKeyStatus,x
		rts
_OSKUUp:
		eor 	#$FF 						; make maske
		and 	OSKeyStatus,x 				; up clear bit
		sta 	OSKeyStatus,x
		rts

; ************************************************************************************************
;
;								  Insert in Keyboard Queue
;
; ************************************************************************************************

OSInsertKeyboardQueue:		
		ldx 	OSKeyboardQueueSize 		; check to see if full
		cpx	 	#OSKeyboardQueueMaxSize
		bcs 	_OSIKQExit 					; if so, you will never know.

		sta 	OSKeyboardQueue,x 			; add keyboard entry to queue.
		inc 	OSKeyboardQueueSize
_OSIKQExit:		
		rts

; ************************************************************************************************
;
;									Reset keyboard system
;
; ************************************************************************************************
		
OSKeyboardInitialise:
		ldx 	#OSIsKeyShift-OSKeyStatus
_OSKILoop:
		stz 	OSKeyStatus,x
		dex
		bpl 	_OSKILoop
		stz 	OSIsKeyUp 					; reset up/shift
		stz 	OSIsKeyShift
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
;		26/06/23 		Cleared iskeyup/shift flags on OSKeyboardInitialise
;
; ************************************************************************************************

