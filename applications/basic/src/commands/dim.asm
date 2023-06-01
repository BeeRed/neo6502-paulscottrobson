; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dim.asm
;		Purpose:	Array dimensions
;		Created:	1st June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;											DIM Command
;
; ************************************************************************************************

		.section code

CommandDIM: ;; [dim]
		lda 	(codePtr),y 				; check identifier follows.
		and 	#$C0
		cmp 	#$40
		bne 	_CDSyntax
		;
		jsr 	VARGetInfo 					; get information
		lda 	VARType 					; check array.
		and 	#2
		beq 	_CDSyntax
		jsr 	VARFind 					; does it already exist
		bcs 	_CDExists		
		jsr 	VARCreate 					; create it - returns data ptr in XA

		phx 								; save target address
		pha 
		lda 	VARType 					; type ID.
		and 	#1 							; 0 = Number, 1 = String.
		jsr 	CreateArray 				; create array to XA

		sty 	zTemp1 						; save Y

		ply 								; restore target to zTemp0
		sty 	zTemp0
		ply
		sty 	zTemp0+1

		sta 	(zTemp0) 					; save new array
		ldy 	#1
		txa
		sta 	(zTemp0),y

		ldy 	zTemp1 						; restore zTemp1
		jsr 	ERRCheckRParen 				; check )
		;
		lda 	(codePtr),y 				; if a comma, consume and go round again.
		iny
		cpy 	#PR_COMMA
		beq 	CommandDIM
		dey
		rts

_CDSyntax:
		.error_syntax
_CDExists:
		.error_redefine

; ************************************************************************************************
;
;					Create an array, collecting array sizes from the code
;
; ************************************************************************************************

CreateArray:
		sta 	CAType						; save type
		jsr 	EXPEvalInteger16 			; get array dimension to R0
		lda 	(codePtr),y 				; does a comma follow, if so, 2 dimensions
		cmp 	#PR_COMMA
		beq 	_CATwoDimensions 
		jsr 	CreateSingleArray 			; create a lowest level array (e.g. data)
		rts
_CATwoDimensions:
		.debug

; ************************************************************************************************
;
;					Create and initialise lowest level array of size R0.
;
; ************************************************************************************************

CreateSingleArray:		
		phy
		;
		sec 								; allocate memory block all zeros.
		lda 	IFR0+IM0
		ldx 	IFR0+IM1
		jsr 	CSAAllocate
		;
		ldy 	CAType 						; if numbers, we don't need to initialise.
		beq 	_CSANoInit
		;
		;		If it is a string array we need to set all the type bits.
		;
		phx 								; save address of new array
		pha
		sta 	zTemp0 						; address in zTemp0
		stx 	zTemp0+1

		ldy 	#1 							; count in YX - cannot be zero.
		lda 	(zTemp0),y
		tay
		lda 	(zTemp0)
		tax
_CSAEraseString:
		phy
		ldy 	#5 							; 2 initial + 3 on
		lda 	#$80
		sta 	(zTemp0),y
		ply
		;
		clc 								; add 4 to next slot.
		lda 	zTemp0
		adc 	#4
		sta 	zTemp0
		bcc 	_CSAENoCarry
		inc 	zTemp0+1		
_CSAENoCarry:		
		;
		cpx 	#0
		bne 	_CSANoBorrow
		dey
_CSANoBorrow:
		dex
		bne 	_CSAEraseString
		cpy 	#0
		bne 	_CSAEraseString		

		pla
		plx
_CSANoInit:
		ply
		rts
		

; ************************************************************************************************
;
; 				Allocate a null block of memory size XA, CS = data, CC = pointers
;
; ************************************************************************************************

CSAAllocate:
		php 								; save type flag.

		inc 	a 							; add 1 because we store the size of the array block
		bne 	_CSAANoCarry 				; for A(10) this is 11 elements.
		inx
_CSAANoCarry:		
		cpx 	#$20 						; basic range check
		bcs 	_CSARange

		plp 								; restore type flag
		php 								; save it back again.

		phx 								; save size.		
		pha

		stx  	zTemp0+1 					; now in ztemp0+1:X 
		bcc 	_CSAATimes2 				; if flag on entry clear multiply by 2, otherwise by 4.
		asl 	a
		rol 	zTemp0+1
_CSAATimes2:		
		asl 	a
		rol 	zTemp0+1

		clc
		adc 	#2 							; add 2 bytes for size.
		bcc 	_CSAANoCarry2
		inc 	zTemp0+1
_CSAANoCarry2:
		ldx 	zTemp0+1 					; XA is the bytes required.
		jsr 	AllocateMemory 				; allocate memory to XA

		stx 	zTemp0+1 					; save pointers
		sta 	zTemp0		
		pla  								; write element count to first 2 bytes
		sta 	(zTemp0)

		pla 								; msb of element count
		plp 								; CC if pointer array
		bcs 	_CSAAIsData
		ora 	#$80 						; set bit 7 of MSB indicating has sub arrays.
_CSAAIsData:		
		ldy 	#1
		sta 	(zTemp0),y

		lda 	zTemp0 						; fix XA back up again
		rts
_CSARange:
		.error_range

		.send code

		.section storage
CAType:										; array type being created - 0 number, 1 string.
		.fill 	1
		.send storage

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
