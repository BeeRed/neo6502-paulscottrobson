; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scroll.asm
;		Purpose:	Scroll screen up
;		Created:	13th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Scroll screen up (off the bottom)
;
; ************************************************************************************************

OSDScrollUp:
		ldy 	#0 							; done a line at a time because it is odd :)
_OSDSScrollLine:		
		ldx 	#0 							; get address of line to copy to.
		jsr 	OSDGetAddressXY
		lda 	rTemp0 						; copy to rTemp1
		sta 	rTemp1
		lda 	rTemp0+1
		sta 	rTemp1+1
		iny 								; get address of line to copy from
		jsr 	OSDGetAddressXY
		phy
		ldy 	#39 						; copy one line
_OSDSCopy:
		lda 	(rTemp0),y
		sta 	(rTemp1),y
		dey
		bpl 	_OSDSCopy
		ply		

		cpy 	#23 						; copied from bottom line ?
		bne 	_OSDSScrollLine

		ldy 	#39 						; clear bottom line
_OSDSClear:
		lda 	#$E0
		sta 	(rTemp0),y
		dey
		bpl 	_OSDSClear		
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

