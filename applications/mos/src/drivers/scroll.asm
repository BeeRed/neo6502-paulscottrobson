; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scroll.asm
;		Purpose:	Scroll screen up/down
;		Created:	25th May 2023
;		Reviewed: 	26th June 2023
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
		lda 	#$C0 						; scroll whole screen up.
		stz 	rTemp0
		sta 	rTemp0+1
		ldy 	OSYSize 					; line counts.
		dey
_OSSULoop1:	
		ldx 	OSXSize 					; number of bytes to copy
		phy
		ldy 	OSXSize 					; offset
_OSSULoop2:
		lda 	(rTemp0),y 					; copy up
		sta 	(rTemp0)
		inc 	rTemp0 						; adjust position.
		bne 	_OSSUCarry
		inc 	rTemp0+1
_OSSUCarry:
		dex 								; do the whole row
		bne 	_OSSULoop2
		ply
		dey 								; for n-1 rows
		bne 	_OSSULoop1
		ldy 	OSXSize 					; fill bottom row with spaces.
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
		ldx 	OSXSize 					; get address of (RHS, Bottom-1). 
		ldy 	OSYSize
		dex
		dey
		dey
		jsr 	OSGetAddressXY

		ldy 	OSXSize 					; copy one row.
_OSSDLoop:		
		lda 	(rTemp0) 					; copy it down
		sta 	(rTemp0),y
		lda 	rTemp0 						; decrement address
		bne 	_OSSDNoBorrow
		lda 	rTemp0+1 					; until we've shifted $C000 down.
		cmp 	#$C0 						 
		beq 	_OSSDExit
		dec 	rTemp0+1
_OSSDNoBorrow:
		dec 	rTemp0
		bra 	_OSSDLoop		
_OSSDExit:
		lda		#' ' 						; erase the top row.
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

