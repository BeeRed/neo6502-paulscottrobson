; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		multiply.asm
;		Purpose:	Multiply two numbers
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Multiply two numbers R0 = RX * R0
;
; ************************************************************************************************

IFloatMultiply:
		stx 	IFTarget 					; save the multiplier (RX) which is "adder"
		jsr 	IFCalculateNewSign
		;
		;		Check for fast multiply.
		;
		lda 	IExp,x 						; check two positive 8 bit integers
		ora 	IFR0+IExp
		and 	#IFXMask
		ora 	IM1,x
		ora 	IFR0+IM1
		ora 	IM2,x
		ora 	IFR0+IM2
		bne 	_IFMStandard
		jsr 	IFloatMultiply8BitRx
		lda 	IFNewSign
		sta 	IFR0+IExp
		clc
		rts

_IFMStandard:		
		;
		;		Add the two exponents, sign extended.
		;
		lda 	IExp,x 						; add the two exponents sign extended
		jsr 	IFMSignExtend
		sta 	IFNewExponent
		lda 	IFR0+IExp
		jsr 	IFMSignExtend
		clc
		adc 	IFNewExponent
		sta 	IFNewExponent

		ldx 	#IFRTemp 					; copy R0 to RTemp which is "shifter"
		jsr 	IFloatCopyToRegister

		ldx 	#IFR0 						; zero R0 (the result)
		jsr 	IFloatSetZero 				
		; --------------------------------------------------------------------------------
		;
		;								Multiplication loop
		;
		; --------------------------------------------------------------------------------
_IFMLoop:
		;
		;		Check if shifter (RTemp) has reached zero
		;
		ldx 	#IFRTemp 					
		jsr 	IFloatCheckZero
		beq 	_IFMExit
		;
		; 		Has adder overflown, if so we need to right shift everything
		;
		ldx 	IFTarget 					; look at adder MSB
		lda 	IM2,x 						; if it is set we need to shift everything
		bpl	 	_IFMTargetOkay
		jsr 	_IFMShiftAll
_IFMTargetOkay:
		;
		;		if bit 0 of shifter set, add Rx to R0.
		;
		lda 	IFRTemp+0 					; is bit 0 of the shifter (RTemp) set		
		and 	#1
		beq 	_IFMNoAdd
		ldx 	IFTarget 					; add adder
		clc
		.binop 	adc
_IFMNoAdd:
		;
		;		if the result in R0 has overflowed, then right shift everything
		;
		lda 	IFR0+IM2
		bpl 	_IFMResultOkay
		jsr 	_IFMShiftAll
_IFMResultOkay:
		;
		;		Shifter shift left, adder shift right.
		;
		ldx 	#IFRTemp
		jsr 	IFloatShiftRight
		ldx 	IFTarget
		jsr 	IFloatShiftLeft
		;
		bra 	_IFMLoop
		;
		; 		Exit - work out the new exponent and sign and exit with error on overflow, zero on underflow.
		;
_IFMExit:
		lda 	IFNewExponent 				; validate new exponent.
		cmp 	#$20 						; valid exponent 00-1F E0-FF
		bcc 	_IFMOkay		
		cmp 	#$E0
		bcs 	_IFMOkay
		;
		and 	#$80 						; if +ve exponent then error overflow.
		beq 	_IFMError
		ldx 	#IFR0 						; return zero underflow
		jsr 	IFloatSetZero
		clc
		rts
		;
		;		Value is A-Ok.
		;
_IFMOkay:
		and 	#IFXMask 					; work out exponent + sign and exit
		ora 	IFNewSign
		sta 	IFR0+IExp
		clc
		rts		

		jmp 	$FFFF

_IFMError:
		sec
		rts

;
;		Shift the whole calculation right : the adder, the result, and increment the new exponent to handle it.
;
_IFMShiftAll:
		ldx 	#IFR0
		jsr 	IFloatShiftRight
		ldx 	IFTarget
		jsr 	IFloatShiftRight
		inc 	IFNewExponent		
		rts

;
;		Mask out and sign extend the 
;
IFMSignExtend:
		and 	#IFXMask
		cmp 	#(IFXMask >> 1)
		bcc 	_IFMNoSXX
		ora 	#IFXMask ^ $FF
_IFMNoSXX:
		rts		

; ************************************************************************************************
;
;								Calculate the sign of the result
;
; ************************************************************************************************

IFCalculateNewSign:		
		lda 	IExp,x
		eor 	IFR0+IExp
		and 	#IFSign
		sta 	IFNewSign
		rts

		.send 	code

		.section storage
IFNewExponent:
		.fill 	1
IFNewSign:		
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

