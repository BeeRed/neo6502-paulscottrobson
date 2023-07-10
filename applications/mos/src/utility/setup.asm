; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		setup.asm
;		Purpose:	Set everything up
;		Created:	25th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										Initialise
;
; ************************************************************************************************

OSInitialise:
		lda 	#52 						; 52 x 30 display
		sta 	OSXSize
		lda 	#30
		sta 	OSYSize
		jsr 	OSDClearScreen 				; clear the display
		jsr 	OSDKeyboardInitialise 		; reset the keyboard state.
		rts

; ************************************************************************************************
;
;									Get Screen Size -> XY
;
; ************************************************************************************************

OSGetScreenSize:
		ldx 	OSXSize
		ldy 	OSYSize
		rts

; ************************************************************************************************
;
;									Get Cursor Position -> XY
;
; ************************************************************************************************

OSGetScreenPosition:
		ldx 	OSXPos
		ldy 	OSYPos
		rts
		
; ************************************************************************************************
;
;									Get break status
;
; ************************************************************************************************		

OSCheckBreak:
		lda 	OSEscapePressed
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

