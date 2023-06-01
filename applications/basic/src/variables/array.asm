; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		array.asm
;		Purpose:	Array lookup
;		Created:	1st June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						XA points to the array address. Follow the index
;
; ************************************************************************************************

		.section code

VARArrayLookup:

		sta 	zTemp0 						; save the array address pointer in zTemp0
		stx 	zTemp0+1

		lda 	(zTemp0)
		pha
		phy
		ldy 	#1
		lda 	(zTemp0),y
		ply
		pha

		jsr 	EXPEvalInteger16 			; R0 now contains the index

		pla 								; array address to zTemp0
		sta 	zTemp0+1
		pla
		sta 	zTemp0

		phy 								; save codePtr position.

		ldy 	#1 							; get 14-8 of size.
		lda 	(zTemp0),y
		pha 								; save bit 15 on stack.
		and 	#$7F
		sta 	zTemp1

		lda 	IFR0+IM0 					; check range of index
		cmp 	(zTemp0)
		lda 	IFR0+IM1
		sbc 	zTemp1
		bcs 	_VALIndex
		lda 	IFR0+IM1  					; sanity check
		cmp 	#$40
		bcs 	_VALIndex

		asl 	IFR0+IM0 					; index x 2 (has sub arrays) x 4 (is data)
		rol 	IFR0+IM1
		plx 								; get msb of size -> X
		bmi 	_VARNotX4 					; if bit 15 set its an array of pointers so x 2
		asl 	IFR0+IM0
		rol 	IFR0+IM1
_VARNotX4:

		clc 								; add the two for the size bytes
		lda 	IFR0+IM0
		adc 	#2
		sta 	IFR0+IM0
		bcc 	_VARNoCarry1
		inc 	IFR0+IM1
_VARNoCarry1:		

		clc 								; calculate the element address and push to stack.
		lda 	IFR0+IM0
		adc 	zTemp0 
		pha
		lda 	IFR0+IM1
		adc 	zTemp0+1

		cpx 	#0 							; do we have a sub level ?
		bmi 	_VARHasSubLevel

		tax 								; address in XA
		pla

		ply 								; restore Y and exit
		rts

_VARHasSubLevel:
		tax 								; get link address in XA
		pla
		ply 								; restore code position.

		pha
		jsr 	ERRCheckComma 				; comma required.
		pla
		jsr 	VARArrayLookup 				; call it recursively
		rts

_VALIndex:
		.error_index		

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

