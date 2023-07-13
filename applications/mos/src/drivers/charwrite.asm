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

OSDGetAddressXY:        
		lda     OSXSize                     
		lsr     a                           ; prime the carry bit for the loop
		sta     rTemp0
		sty     rTemp0+1
		lda     #0
		ldy     #8
_IFMLoop:
		bcc     _IFMNoAdd
		clc
		adc     rTemp0+1
_IFMNoAdd:
		ror     a
		ror     rTemp0                      ; pull another bit out for the next iteration
		dey        
		bne     _IFMLoop                   
		ora 	#$04
		tay

		clc
		txa
		adc 	rTemp0
		sta 	rTemp0
		bcc 	_IFMNoCarry
		iny
_IFMNoCarry:        
		sty 	rTemp0+1
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

