; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		shift.asm
;		Purpose:	Shift binary operators
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code	

; ************************************************************************************************
;
;								Shift Left/Right (uses common code)
;
; ************************************************************************************************

EXPBinLeft:		;; [<<]
		lda 	#$FF
		sta 	EXPShiftLeftFlag
		jmp 	EXPShiftCommon

;:[<<]\
; A binary operator, shifts the left side left by the value in the right side.
; This is the same as multiplying by a power of 2 but it's much quicker\		
; {print 16 << 3} would print 128 

EXPBinRight:	;; [>>]
		stz 	EXPShiftLeftFlag

;:[>>]\
; A binary operator, shifts the left side rightt by the value in the right side.
; This is the same as divding by a power of 2 but it's much quicker\		
; {print 16 >> 3} would print 2

EXPShiftCommon:		
		;
		lda 	IFR0+IExp 					; check both integers
		ora 	IFR1+IExp
		and 	#$7F
		bne 	_EXPSRange
		;
		lda 	IFR0+IM0					; check shift >= 32
		and 	#$E0
		ora 	IFR0+IM1
		ora 	IFR0+IM2
		bne 	_EXPSShiftZero 				; if so return zero as would be shifted out.

		phy
		lda 	IFR0+IM0 					; get shift
		and 	#$1F
		beq 	_EXPSExit 					; exit if zero
		tay
_EXPSLoop:
		ldx 	#IFR1 						; get direction
		bit 	EXPShiftLeftFlag
		bmi 	_EXPSShiftLeft 				; shift left/right accordingly.
		jsr 	IFloatShiftRight
		bra 	_EXPSContinue
_EXPSShiftLeft:
		jsr 	IFloatShiftLeft		
		bit 	IFR0+IM2 					; too many shifts (24th bit set)
		bmi 	_EXPSRange
_EXPSContinue:
		dey 								; do it Y times
		bne 	_EXPSLoop				
_EXPSExit:
		ldx 	#IFR1 						; R0 = R1 <shift> R0
		jsr 	IFloatCopyFromRegister
		ply
		rts

_EXPSShiftZero: 							; come here if shifted too far
		ldx 	#IFR0
		jsr 	IFloatSetZero
		rts

_EXPSRange: 								; overflow shifting left.
		.error_range
		.send code

				
		.section storage
EXPShiftLeftFlag:
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

