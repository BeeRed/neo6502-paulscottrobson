; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		sgn.asm
;		Purpose:	Sign of number
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								Sign of number
;
; ************************************************************************************************

		.section code	

EXPUnarySgn: ;; [sgn(]
		jsr 	EXPEvalNumber 					; number to R0
		jsr 	ERRCheckRParen 					; )
		ldx 	#IFR1 							; copy to R1
		jsr 	IFloatCopyToRegister
		ldx 	#IFR0 							; R0 = 0
		jsr 	IFloatSetZero
		ldx 	#IFR1
		jsr 	IFloatCompare 					; compare R1 vs 0, this gives -1,0,1.
		rts

		.send code

;: [sgn(n)]\
; Returns the sign of the number n ; 0 if zero, -1 if negative, 1 if positive and not zero\
; { print sgn(-13) } prints -1

				
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

