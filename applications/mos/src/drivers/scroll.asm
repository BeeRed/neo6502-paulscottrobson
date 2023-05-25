; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scroll.asm
;		Purpose:	Scroll screen up/down
;		Created:	25th May 2023
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

OSScrollUp:
		lda 	#$C0
		stz 	rTemp0
		sta 	rTemp0+1
		ldy 	OSYSize
		dey
_OSSULoop1:	
		ldx 	OSXSize
		phy
		ldy 	OSXSize
_OSSULoop2:
		lda 	(rTemp0),y
		sta 	(rTemp0)
		inc 	rTemp0
		bne 	_OSSUCarry
		inc 	rTemp0+1
_OSSUCarry:
		dex
		bne 	_OSSULoop2
		ply
		dey
		bne 	_OSSULoop1
		ldy 	OSXSize
_OSSUFill:		
		lda 	#' '
		dey
		sta 	(rTemp0),y
		bne 	_OSSUFill
		rts

; ************************************************************************************************
;
;								Scroll screen down (off the top)
;
; ************************************************************************************************

OSScrollDown:
		ldx 	OSXSize
		ldy 	OSYSize
		dex
		dey
		dey
		jsr 	OSGetAddressXY

		ldy 	OSXSize
_OSSDLoop:		
		lda 	(rTemp0)
		sta 	(rTemp0),y
		lda 	rTemp0
		bne 	_OSSDNoBorrow
		lda 	rTemp0+1
		cmp 	#$C0
		beq 	_OSSDExit
		dec 	rTemp0+1
_OSSDNoBorrow:
		dec 	rTemp0
		bra 	_OSSDLoop		
_OSSDExit:
		lda		#' '
		dey
		sta 	(rTemp0),y
		bne 	_OSSDExit
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

