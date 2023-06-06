; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		errorhandler.asm
;		Purpose:	Handle errors
;		Created:	6th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Handle Errors
;
; ************************************************************************************************

ErrorHandler:			
		plx 								; get address of msg
		ply
		inx 								; bump past RTS
		bne 	_EHNoInc
		iny
_EHNoInc:		
		jsr	 	OSWriteString 				; print it.
		lda 	ERRLine 					; direct command ?
		ora 	ERRLine+1
		beq 	_EHNoNumber
		;
		;		Not direct so print number.
		;
		ldx 	#_EHAtMsg & $FF
		ldy 	#_EHAtMsg >> 8
		jsr 	OSWriteStringZ

		lda 	ERRLine 					; line number -> R0
		ldx 	#IFR0
		jsr 	IFloatSetByte
		lda 	ERRLine+1
		sta 	IFR0+IM1
		lda 	#10 						; decimal
		jsr 	IFloatIntegerToStringR0	 	; convert
		jsr 	OSWriteStringZ 				; print

_EHNoNumber:		
		jmp 	WarmStartNewLine

_EHAtMsg:
		.text 	" at ",0

NotImplemented:
		.error_unimplemented

		.send code
		
		.section storage
ERRLine:
		.fill 	2
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

