; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		charwrite.asm
;		Purpose:	Physical character write
;		Created:	25th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Read char at current screen position
;
; ************************************************************************************************

OSDReadPhysical:
		jsr 	OSDGetAddress
		lda 	(rTemp0)
		rts

; ************************************************************************************************
;
;							Write char A at current screen position
;
; ************************************************************************************************

OSDWritePhysical:
		pha		
		jsr 	OSDGetAddress
		pla
		sta 	(rTemp0)
		rts

; ************************************************************************************************
;
;							  Current/Specific cursor address in rTemp0
;
; ************************************************************************************************	

OSDGetAddress:
		ldy     OSYPos        
		ldx 	OSXPos

;
;		Map Y 000abcde -> 00001cd eabab000 in rTemp0
;
OSDGetAddressXY:        
		tya 								; do CDE first
		and 	#7 							; A is now 00000cde
		ora 	#8 							; 00001cde
		stz 	rTemp0
		lsr 	a 							; A is now 000001cd and e is in carry.
		ror 	rTemp0
		sta 	rTemp0+1 					; zTemp0 now 000001cd:e0000000

		tya 								; get AB
		and 	#$18 		
		pha 								; save on stack
		ora 	rTemp0 						; OR into rTemp0 now 00001cd:e00ab0000
		sta 	rTemp0
		pla 								; get AB back and shift left twice
		asl 	a
		asl 	a
		ora 	rTemp0 						; OR into rTemp0 now 00001cd:eabab000
		sta 	rTemp0

		clc 								; add X
		txa
		adc 	rTemp0
		sta 	rTemp0
		bcc 	_OSGAExit
		inc 	rTemp0+1
_OSGAExit:	
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

