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
IFR0:	 									; work registers
		.fill 	4
IFR1:	
		.fill 	4
IFR2:	
		.fill 	4
IFRTemp:
		.fill 	4
codePtr: 									; it's more readable if these don't move.
		.fill 	4

rTemp0: 									; temporary register for OS, zero page
		.fill 	2
rTemp1:
		.fill 	2		
iTemp0:										; temporary register for maths library, zero page.
		.fill 	2



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
OSEscapePressed: 							; non zero if escape pressed.
		.fill 	1
OSRKOriginal: 								; character under cursor (for keystroke)
		.fill 	1

OSTextBufferSize = 192

OSXEdit: 									; position of start of edit area
		.fill 	1			
OSYEdit:
		.fill 	1		
OSEditWidth: 								; width in characters of edit area.
		.fill 	1	
OSEditPos: 									; current cursor position in string.
		.fill 	1			
OSEditScroll: 								; offset in characters of the left most character.
		.fill 	1		
OSEditLength: 								; number of characters on line
		.fill 	1
OSEditBuffer: 								; text buffer.
		.fill 	OSTextBufferSize+1

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

