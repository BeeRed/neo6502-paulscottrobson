; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		ramdata.inc
;		Purpose:	Common setup program
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

ZeroPageBase = $08 							; zero page usage
StorageBase = $200 							; ROM usage

; ************************************************************************************************
;
;									Zero Page usage
;
; ************************************************************************************************

		* = ZeroPageBase
rTemp0: 									; temporary register for OS, zero page
		.fill 	2

		.dsection zeroxpage

; ************************************************************************************************
;
;									Non Zero Page usage
;
; ************************************************************************************************

		* = StorageBase
OSXPos:	 									; cursor position
		.fill 	1
OSYPos:	
		.fill 	1		
OSXSize:									; screen size
		.fill 	1
OSYSize:
		.fill 	1		


OSKeyboardQueueMaxSize = 16					; keyboard queue max size.

OSKeyStatus: 								; status bits for keys.
		.fill 	32 
OSKeyboardQueue:							; keyboard queue
		.fill 	OSKeyboardQueueMaxSize		
OSKeyboardQueueSize:						; entries in keyboard queue
		.fill 	1		
OSIsKeyUp: 									; $FF if $F0 received else $F0
		.fill 	1
OSIsKeyShift: 								; $80 if $E0 received else $00
		.fill 	1			

		.dsection storxage

		
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

