; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dtkidentifier.asm
;		Purpose:	Detokenise identifier
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Detokenise identifier
;
; ************************************************************************************************

TOKDIdentifier:
		clc 								; high byte variable address
		adc 	PGMBaseHigh
		sta 	zTemp0+1
		jsr 	TOKDGet
		sta 	zTemp0
		ldy 	#5 							; points to first character
		lda 	(zTemp0),y 					; check spacing
		and 	#$7F
		jsr 	TOKDSpacing
_TOKDILoop: 								; output identifier name.
		lda 	(zTemp0),y
		and 	#$7F
		jsr 	TOKToLower
		jsr 	TOKDOutput		
		lda 	(zTemp0),y
		asl  	a
		iny
		bcc 	_TOKDILoop
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

