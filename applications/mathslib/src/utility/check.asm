; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		check.asm
;		Purpose:	Check |R0| is <= R1
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (psaul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							  	Check Abs(R0) < R1 (TESTING ONLY)
;
; ************************************************************************************************

IFloatCheckRange:
		lda 	IFR0+IExp					; force it negative e.g. -|R0|
		ora 	#IFSign
		sta 	IFR0+IExp
		ldx 	#IFR1 						; add R1.
		jsr 	IFloatAdd 					; add allowed to error.
		ldx 	#IFR0 					
		jsr 	IFloatCheckZero 			; error if < 0
		beq 	_IFAOkay
		lda 	IFR0+IExp
		and 	#IFSign
		bne 	_IFAFail
_IFAOkay:
		rts		

_IFAFail:
		sec
		pla 								; get address - 2
		sbc 	#2
		tax
		pla
		sbc 	#0
		tay
		lda 	#$AA 						; sign assert
_IFAStop:		 		
		.byte 	$DB 						; display an error AA ADR ADR
		bra 	_IFAStop
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

