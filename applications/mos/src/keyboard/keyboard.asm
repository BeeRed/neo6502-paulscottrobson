; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		keyboard.asm
;		Purpose:	Keyboard handling
;		Created:	25th May 2023
;		Reviewed: 	26th June 2023
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
		lda 	OSKeyboardQueueSize  		; get count of entries in queue
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
		phx 								; just a shortcut to read device #1
		ldx 	#1
		jsr 	OSReadDevice
		plx
		rts

; ************************************************************************************************
;
;							Read a keypress to A displaying cursor
;
; ************************************************************************************************

OSReadKeystroke:
		phx 								; save XY
		phy
		jsr 	OSReadPhysical 				; save old character under cursor
		sta 	OSRKOriginal
		lda 	#$7F 						; write prompt
		jsr 	OSWritePhysical
_OSWaitKey:
		jsr 	OSKeyboardDataProcess 		; this scans the keyboard, could be interrupt
		jsr 	OSReadKeyboard 				; key available
		bcs 	_OSWaitKey 					' no keep going
		;
		pha 								; save key
		lda 	OSRKOriginal 				; old character back and write to screen.
		jsr 	OSWritePhysical
		pla 								; restore
		ply
		plx
		clc 								; success
		rts

; ************************************************************************************************
;
;						Read from device X to A, CC if data received.
;				Currently we only have one device, so it reads they keyboard
;
; ************************************************************************************************

OSReadDevice:
		jsr 	OSKeyboardDataProcess 		; this scans the keyboard etc.
		;
		jsr 	OSIsKeyAvailable 			; key available ?
		bcs 	_OSRDExit 					; no exit with CS.

		lda 	OSKeyboardQueue 			; push char from head of queueon stack
		pha	

		phx 								; shift everything else up one.
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

