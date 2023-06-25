; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		stack.asm
;		Purpose:	Push/Pull register
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Push R:X on the stack
;
; ************************************************************************************************

IFloatPushRx:
		phy
		ldy 	IFStackIndex 				; push IM0,1,2,Exp on the stack
		lda 	IM0,x
		sta 	IFStack,y
		lda 	IM1,x
		sta 	IFStack+1,y
		lda 	IM2,x
		sta 	IFStack+2,y
		lda 	IExp,x
		sta 	IFStack+3,y
		iny
		iny
		iny
		iny
		sty 	IFStackIndex 				; update SP
		ply
		rts

; ************************************************************************************************
;
;									Pull R:X off the stack
;
; ************************************************************************************************

IFloatPullRx:
		phy
		ldy 	IFStackIndex	 			; decrement SP
		dey
		dey
		dey
		dey

		lda 	IFStack,y 					; pop IM0,1,2,Exp off stack
		sta 	IM0,x
		lda 	IFStack+1,y
		sta 	IM1,x
		lda 	IFStack+2,y
		sta 	IM2,x
		lda 	IFStack+3,y
		sta 	IExp,x

		sty 	IFStackIndex 				; update SP
		ply
		rts

		.send 	code

		.section storage
IFStackIndex:
		.fill 	1
IFStack:
		.fill 	16*4
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

