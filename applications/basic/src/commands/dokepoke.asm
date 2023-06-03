; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dokepoke.asm
;		Purpose:	Doke/Poke word/bytes
;		Created:	3rd June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										ASSERT Command
;
; ************************************************************************************************

		.section code

Command_Doke:	;; [doke]
		sec
		bra 	DPCommon

;: [doke a,n]\
; Writes the word a at address n
; { doke $0FF0,32766 }

Command_Poke: 	;; [poke]		
		clc 

;: [poke a,n]\
; Writes the byte a at address n
; { poke $0FF4,42 }

DPCommon:
		php 								; CS if DOKE		
		jsr 	EXPEvalInteger16 			; address
		lda 	IFR0+IM0 					; push on stack
		pha
		lda 	IFR0+IM1
		pha
		
		jsr 	ERRCheckComma 				; [dp]oke address,data
		jsr 	EXPEvalInteger16

		pla 								; get address back
		sta 	zTemp0+1
		pla
		sta 	zTemp0

		lda 	IFR0+IM0
		sta 	(zTemp0)

		plp
		bcc 	_DPExit

		phy
		lda 	IFR0+IM1
		ldy 	#1
		sta 	(zTemp0),y
		ply

_DPExit:
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

