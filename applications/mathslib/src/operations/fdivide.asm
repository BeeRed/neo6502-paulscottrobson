; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fdivide.asm
;		Purpose:	Divide two integers/float result
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Float Divide two numbers R0 = RX / R0
;
; ************************************************************************************************

IFloatDivideFloat:
		stx 	IFTarget  					; this is s1, s0 = R0
		jsr 	IFCalculateNewSign 			; calculate sign of result
		;
		;		Normalise and cheeck division by zero.
		;
		jsr 	IFloatNormalise 			; normalise RX

		ldx 	#IFR0 						; normalise R0
		jsr 	IFloatNormalise
		jsr 	IFloatCheckZero
		beq 	_IFDFDivZero 				; exit if this normalised to zero.
		;
		;		Calculate new exponent
		;
		lda 	IFR0+IExp 					; calculate s0.exponent
		jsr 	IFMSignExtend
		sta 	IFNewExponent

		ldx 	IFTarget 					; calculate s1.exponent
		lda 	IExp,x
		jsr 	IFMSignExtend
		sec
		sbc 	IFNewExponent 				; s1.exponent - s0.exponent - 23
		sec 	
		sbc 	#23
		sta 	IFNewExponent

		jsr 	IFloatDivideSupport 		; call the support routine (see maths.py)

		lda 	IFRTemp+IM2 				; result has overflowed ?
		bpl 	_IFDFNoShiftResult

		ldx 	#IFRTemp 					; if so, fix it up.
		jsr 	IFloatShiftRight
		inc 	IFNewExponent
_IFDFNoShiftResult:		

		lda 	IFNewExponent 				; underflow/overflow check.
		bmi 	_IFDFCheckUnderflow
		cmp 	#$20 						; overflow in division
		bcs 	_IFDFDivZero
		bra		_IFDFExit

_IFDFCheckUnderflow:
		lda 	IFNewExponent 				; shift into a legal exponent.
		cmp 	#$E0 						; if exponent < -32.
		bcs 	_IFDFExit		
		inc 	IFNewExponent
		ldx 	#IFRTemp
		jsr 	IFloatShiftRight
		bra 	_IFDFCheckUnderflow

_IFDFExit:
		lda 	IFNewExponent 				; combine exponent and sign.
		and 	#IFXMask
		ora 	IFNewSign
		sta 	IFRTemp+IExp
		;
		ldx 	#IFRTemp 					; copy RTemp to R0.
		jsr 	IFloatCopyFromRegister
		clc
		rts
_IFDFDivZero:
		sec
		rts		

; ************************************************************************************************
;
;							Helper function for float division.
;
; ************************************************************************************************

IFloatDivideSupport:
		ldx 	#IFRTemp 					; zero RTemp
		jsr 	IFloatSetZero

		phy 								; main division loop x 23
		ldy 	#23
_IFDSLoop:
		jsr 	IFDTrySubtract 				; do if s0 >= sx subtract code.
		jsr 	IFDShiftSTempS1Left 		; shift the 64 bit value sTemp,s1 left one bit.
		dey
		bne 	_IFDSLoop 					; do it 24 times
		ply
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

