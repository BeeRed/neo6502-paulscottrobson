; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		idivide.asm
;		Purpose:	Divide two integers
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Integer Divide/Modulus two integers R0 = RX / R0
;
; ************************************************************************************************

IFloatDivideInteger:
		jsr 	IFloatDivideIntegerCommon 	; do the common code.
		bcs 	_IFDIExit
		ldx 	#IFRTemp 					; copy result from register.
		jsr 	IFloatCopyFromRegister
		clc
_IFDIExit:		
		rts

IFloatModulusInteger:
		jsr 	IFloatDivideIntegerCommon
		bcs 	_IFMIExit
		ldx 	IFTarget
		jsr 	IFloatCopyFromRegister
		clc
_IFMIExit:		
		rts

; ************************************************************************************************
;
;										Common integer code.
;
; ************************************************************************************************

IFloatDivideIntegerCommon:
		stx 	IFTarget  					; this is s1, s0 = R0
		jsr 	IFCalculateNewSign 			; calculate sign of result

		jsr 	IFDCopyRXToRTemp 			; copy S1 to RTemp

		ldx 	#IFR0 						; check divide by zero
		jsr 	IFloatCheckZero
		beq 	_IFDIDivZero

		ldx 	IFTarget 					; zero Rx (S1)
		jsr 	IFloatSetZero

		phy
		ldy 	#24
_IFDILoop: 									
		jsr 	IFDShiftSTempS1Left 		; shift the 64 bit value sTemp,s1 left one bit.
		jsr 	IFDTrySubtract 				; do if s0 >= sx subtract code.
		dey
		bne 	_IFDILoop 					; do it 24 times
		ply

		lda 	IFNewSign 					; set sign of result.
		and 	#IFSign
		sta 	IFRTemp+IExp
		clc 								; is okay.
		rts

_IFDIDivZero:
		sec
		rts

; ************************************************************************************************
;
;							Support routine : Copy RX to RTemp
;
; ************************************************************************************************

IFDCopyRXToRTemp:
		lda 	IM0,x
		sta 	IFRTemp+IM0
		lda 	IM1,x
		sta 	IFRTemp+IM1
		lda 	IM2,x
		sta 	IFRTemp+IM2
		lda 	IExp,x
		sta 	IFRTemp+IExp
		rts

; ************************************************************************************************
;
;						Support routine : shift RTemp:R0 left one bit
;
; ************************************************************************************************

IFDShiftSTempS1Left:
		ldx 	#IFRTemp
		jsr 	IFloatShiftLeft
		ldx 	IFTarget
		jsr 	IFloatRotateLeft
		rts

; ************************************************************************************************
;
;		Support routine - subtract s0.mantissa from s1.mantissa if possible, if subtracted
;		increment STemp.mantissa
;
; ************************************************************************************************

IFDTrySubtract:
		ldx 	IFTarget 					; s1 = Rx
		;
		sec 								; subtract, saving the results on the stack.
		lda 	IM0,x
		sbc 	IFR0+IM0
		pha

		lda 	IM1,x
		sbc 	IFR0+IM1
		pha

		lda 	IM2,x
		sbc 	IFR0+IM2
		bcs 	_IFDCanSubtract

		pla 								; cannot subtract, so pop intermediate and exit.
		pla
		rts

_IFDCanSubtract:
		sta 	IM2,x 						; write back to S1.Mantissa
		pla
		sta 	IM1,x
		pla
		sta 	IM0,x
		;
		inc 	IFRTemp+IM0 				; increment temp
		bne 	_IFDCSExit
		inc 	IFRTemp+IM1		
		bne 	_IFDCSExit
		inc 	IFRTemp+IM2
_IFDCSExit:
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

