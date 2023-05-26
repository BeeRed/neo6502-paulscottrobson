; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		exprutils.asm
;		Purpose:	Evaluate expression helpers.
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code	

; ************************************************************************************************
;
;								Evaluate a numeric expression
;
; ************************************************************************************************

EXPEvalNumber:
		jsr 	EXPTermValueR0
		bit 	IFR0+IExp
		bmi 	EVUType
		rts

EVUType:
		.error_type

; ************************************************************************************************
;
;								Evaluate an integer (various)
;
; ************************************************************************************************

EXPEvalInteger:
		jsr 	EXPEvalNumber 				; get number, coeerce to integer.
		jsr 	IFloatIntegerR0
		rts

EXPEvalInteger16:
		jsr 	EXPEvalInteger
		lda 	IFR0+IM2
		bne 	EVURange
		ldx 	IFR0+IM1
		lda 	IFR0+IM0
		rts

EXPEvalInteger8:
		jsr 	EXPEvalInteger
		lda 	IFR0+IM2
		ora 	IFR0+IM1
		bne 	EVURange
		lda 	IFR0+IM0
		rts

; ************************************************************************************************
;
;								Evaluate a string expression
;				(on exit XA & zTemp0 points to a 2 byte headered size prefixed string)
;
; ************************************************************************************************

EXPEvalString:
		jsr 	EXPTermValueR0
		bit 	IFR0+IExp
		bpl 	EVUType
		ldx 	IFR0+IM1
		stx 	zTemp0+1
		lda 	IFR0+IM0
		sta 	zTemp0
		rts

EVURange:
		.error_range

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

