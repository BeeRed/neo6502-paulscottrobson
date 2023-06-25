; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		add.asm
;		Purpose:	Add two numbers
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Sub two numbers R0 = RX - R0
;
; ************************************************************************************************

IFloatSubtract:
		phx
		ldx 	#IFR0
		jsr 	IFloatNegate 				; negate R0 and fall through to add.
		plx

; ************************************************************************************************
;
;								Add two numbers R0 = RX + R0
;
; ************************************************************************************************

IFloatAdd:
		lda 	IExp,x 						; check if both exponents are zero.
		ora 	IFR0+IExp
		and 	#IFXMask 					; if not, then we have to do the 
		bne 	_IFloatAddDecimals 			; floating point version.
;
;		Add or Subtract the mantissae, adjusting the result accordingly.
;		If both exponents are zero we only do this bit.
;
_IFAddSubMantissa:
		lda 	IExp,x 						; are the signs different ?
		eor 	IFR0+IExp
		and 	#IFSign
		bne 	_IFloatSubMantissa			; if so, we do a subtract
		;
		;		Addition of the mantissae.
		;
		clc 								; do the actual addition
		.binop 	adc 						; the sign is that of R0 e.g. 4 + 5 = 9
		bpl 	_IFloatAddExit 				; if no carry through to bit 23, then exit.
		;
		ldx 	#IFR0						; shift R0 right, divide by 2
		jsr 	IFloatShiftRight 			; we are now in decimals mode.
		jsr 	IFloatIncExponent
		bne 	_IFloatAddExit
		sec 								; overflowed numerically.
		rts
		;
		;		Subtraction of the mantissae
		;
_IFloatSubMantissa:
		sec 								; do the subtraction R0-Rx
		.binop 	sbc 						; the sign is that of R0 e.g. 7-3 = 4
		bcs 	_IFloatAddExit 				; no borrow so we are done.
		;
		ldx 	#IFR0
		jsr 	IFloatMantissaNegate 		; 2's complement negate the mantissa
		jsr 	IFloatNegate 				; negate the result using sign bit.
_IFloatAddExit:
		clc
		rts

_IFloatZeroAdd:
		plx 								; return this value in R0
		jsr 	IFloatCopyFromRegister
		clc
		rts

_IFloatAddDecimals:		
		jsr		IFloatCheckZero 			; if RX = 0 then exit with R0
		beq 	_IFloatAddExit 				

		jsr 	IFloatNormalise 			; normalise RX
		phx 								; normalise R0
		ldx 	#IFR0
		jsr 	IFloatCheckZero
		beq 	_IFloatZeroAdd 				; normalised R0 is zero, return RX.
		jsr 	IFloatNormalise
		plx
		;
		;		Get exponents of R0 RX in testable format.
		;
		lda 	IFR0+IExp 					; get the exponent of R0
		and 	#IFXMask
		sec 	
		sbc 	#$20 						; map 20..3F..00..1F to 00..0F..E0..FF e.g. scaled unsigned
		sta 	iTemp0
		;
		lda 	IExp,x 						; repeat for exponent of Rx
		and 	#IFXMask
		sec
		sbc 	#$20
		cmp 	iTemp0 						; get the larger adjusted 
		bcs 	_IFloatHaveLarger
		lda 	iTemp0
_IFloatHaveLarger:		
		;
		;		Convert back to a real exponent and shift both to it.
		;
		clc 								; get the actual one back.
		adc 	#$20 						; shift both to that.
		jsr 	_IFShiftXToA
		phx
		ldx 	#IFR0		
		jsr 	_IFShiftXToA
		plx
		jmp 	_IFAddSubMantissa 			; do the adding bit.

; ************************************************************************************************
;
;									Shift Rx till the exponent is A
;
; ************************************************************************************************

_IFShiftXToA:
		sta 	IFTarget
		jsr 	IFloatCheckZero 			; check adding zero ?
		beq 	_IFSXExit
_IFSXLoop:
		lda 	IExp,x 	 					; shifted to the right level yet ?
		and 	#IFXMask
		cmp 	IFTarget
		beq 	_IFSXExit
		jsr 	IFloatShiftRight
		jsr 	IFloatIncExponent
		bra 	_IFSXLoop
_IFSXExit:
		rts		

		.send 	code

		.section storage
IFTarget:
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

