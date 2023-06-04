; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		ramdata.inc
;		Purpose:	Common setup program, allocate RAM for MOS.
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
iTemp0:										; temporary register for maths library, zero page.
		.fill 	2

IFR0:	 									; work registers
		.fill 	4
IFR1:	
		.fill 	4
IFR2:	
		.fill 	4
IFRTemp:
		.fill 	4

		.dsection zeropage

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

		.fill 	32
		.align 	256
		
		.dsection storage

debug 	.macro
		.byte 	$DB
		.endm
		
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

