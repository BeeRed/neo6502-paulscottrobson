; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokconstant.asm
;		Purpose:	Output integer
;		Created:	28th May 2023
;		Reviewed: 	No
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
		lda 	IFR0+IM2 					; 010000..FFFFFF 3 byte
		bne 	_TTC3Byte
		lda 	IFR0+IM1 					; 00C000..00FFFF 3 byte
		and 	#$C0
		bne 	_TTC3Byte
		;
		lda 	IFR0+IM1 					; 000100..00BFFF 2 byte					
		bne 	_TTC2Byte
		lda 	IFR0+IM0 					; 000020..0000FF 1 byte
		cmp 	#$20
		bcc 	_TTC1Byte
		;
_TTC2Byte: 										
		lda 	IFR0+IM1
		and 	#$3F
		clc
		adc 	#$20
		jsr 	TOKWriteA
		lda 	IFR0+IM0		
		jsr 	TOKWriteA 					
		rts
_TTC1Byte:
		lda 	IFR0+IM0		
		ora 	#$60
		jsr 	TOKWriteA 					; 000000..00001F 
		rts
		;
_TTC3Byte:
		lda 	#PR_INTEGER	 				; [[INT]] B0 B1 B2
		jsr 	TOKWriteA
		lda 	IFR0+IM0
		jsr 	TOKWriteA
		lda 	IFR0+IM1
		jsr 	TOKWriteA
		lda 	IFR0+IM2
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

