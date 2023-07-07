; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokconstant.asm
;		Purpose:	Output integer
;		Created:	28th May 2023
;		Reviewed: 	7th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;							Output token data for constant in R0
;
; ************************************************************************************************

TOKTokeniseConstant:
		lda 	IFR0+IM0 					; check > 64
		pha 								; save LSB on stack
		and 	#$C0
		ora 	IFR0+IM1
		ora 	IFR0+IM2
		beq 	_TTCLess
		;
		;		If >= 64 then shift 6 right and call recursively.
		;
		phx
		ldx 	#6 							; divide by 64
_TTCShiftRight:		
		lsr 	IFR0+IM2
		ror 	IFR0+IM1
		ror 	IFR0+IM0
		dex
		bne 	_TTCShiftRight
		plx
		jsr 	TOKTokeniseConstant
_TTCLess:
		;
		;		0-63 write token out.
		;
		pla
		and 	#$3F 						; lower 6 bits
		jsr 	TOKWriteA
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

