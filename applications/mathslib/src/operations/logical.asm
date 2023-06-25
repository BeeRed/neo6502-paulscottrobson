; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		logical.asm
;		Purpose:	Logical operators
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;									Bitwise AND R0 := R0 & Rx
;
; ************************************************************************************************

IFloatBitwiseAnd:
		phy
		jsr 	IFPreProcessBitwise 		; set up everything.
		bne 	_IFBAExit
_IFBALoop:
		lda 	IFR0+IM0,y
		and 	IM0,x
		sta 	IFR0+IM0,y
		inx
		iny
		cpy 	#3
		bne 	_IFBALoop
		clc
_IFBAExit:		
		ply
		rts

; ************************************************************************************************
;
;									Bitwise OR R0 := R0 | Rx
;
; ************************************************************************************************

IFloatBitwiseOr:
		phy
		jsr 	IFPreProcessBitwise 		; set up everything.
		bne 	_IFBAExit
_IFBALoop:
		lda 	IFR0+IM0,y
		ora 	IM0,x
		sta 	IFR0+IM0,y
		inx
		iny
		cpy 	#3
		bne 	_IFBALoop
		clc
_IFBAExit:		
		ply
		rts

; ************************************************************************************************
;
;									Bitwise XOR R0 := R0 ^ Rx
;
; ************************************************************************************************

IFloatBitwiseXor:
		phy
		jsr 	IFPreProcessBitwise 		; set up everything.
		bne 	_IFBAExit
_IFBALoop:
		lda 	IFR0+IM0,y
		eor 	IM0,x
		sta 	IFR0+IM0,y
		inx
		iny
		cpy 	#3
		bne 	_IFBALoop
		clc
_IFBAExit:		
		ply
		rts

; ************************************************************************************************
;
;									Common bitwise pre-process
;
; ************************************************************************************************

IFPreProcessBitwise:
		ldy 	#0 							; set index.
		lda 	IFR0+IExp 					; OR exponents
		ora 	IExp,x
		stz 	IExp,x 						; zero the result exponent anyway.
		and 	#IFXMask 					; NZ if error e.g. not integer
		sec 								; carry set just in cases.
		rts

		.send 	code

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
