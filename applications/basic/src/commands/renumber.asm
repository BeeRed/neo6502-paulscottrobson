; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		renumber.asm
;		Purpose:	Limited renumberer
;		Created:	5th July 2023
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

Command_RENUMBER:	;; [renumber]
		lda 	#1000 & $FF 				; default REN star
		sta 	IM0+IFR0
		lda 	#1000 >> 8
		sta 	IM1+IFR0
		;
		lda 	(codePtr),y 				; what follows.
		cmp 	#PR_COLON
		beq 	_CRIsDefault
		cmp 	#PR_LSQLSQENDRSQRSQ
		beq 	_CRIsDefault
		jsr 	EXPEvalInteger16 			; get other start 
_CRIsDefault:
		phy
		stz 	zTemp0						; copy base address to zTemp0
		lda 	PGMBaseHigh
		sta 	zTemp0+1
_CRRenumberLoop:
		lda 	(zTemp0)					; check end
		beq 	_CRExit
		;
		clc
		ldy 	#1 							; copy line # in bumping as you go.
		lda 	IFR0+IM0		
		sta 	(zTemp0),y
		adc 	#10
		sta 	IFR0+IM0
		iny
		lda 	IFR0+IM1
		sta 	(zTemp0),y
		adc 	#0
		sta 	IFR0+IM1
		;
		clc 								; next line.	
		lda 	(zTemp0)
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_CRRenumberLoop
		inc 	zTemp0+1
		bra 	_CRRenumberLoop
_CRExit:
		ply
		rts								
		.send code

;:[RENUMBER <start>]\
; Simple renumberer. Does *not* handle GOTO or GOSUB, so don't use it if you use
; these commands, which should only be for already existing type ins.
; The start is optional, and defaults to 1000.

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

