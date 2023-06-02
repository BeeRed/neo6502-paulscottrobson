; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		keyboard.asm
;		Purpose:	Keyboard handling
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						Is Key Available - returns CC if yes, CS if no.
;
; ************************************************************************************************

OSIsKeyAvailable:
		pha
		clc
		lda 	OSKeyboardQueueSize  		; get entries in queue
		bne 	_OSIKAHasKey
		sec
_OSIKAHasKey:		 	
		pla
		rts

; ************************************************************************************************
;
;						Read from keyboard to A, CS if data received.
;
; ************************************************************************************************

OSReadKeyboard:
OSReadKeyboardWithCursor:
		phx
		ldx 	#1
		jsr 	OSReadDevice
		plx
		rts

; ************************************************************************************************
;
;						Read from device X to A, CS if data received.
;
; ************************************************************************************************

OSReadDevice:
		jsr 	OSIsKeyAvailable 			; key available ?
		bcs 	_OSRDExit
		lda 	OSKeyboardQueue 			; push char on stack
		pha	
		phx
		ldx		#0 							; remove from queue array
_OSRDDequeue:
		lda 	OSKeyboardQueue+1,x
		sta 	OSKeyboardQueue,x
		inx
		cpx 	OSKeyboardQueueSize
		bne 	_OSRDDequeue		
		dec 	OSKeyboardQueueSize			; dec queue count
		plx
		pla 								; restore key
		clc
_OSRDExit:		
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

