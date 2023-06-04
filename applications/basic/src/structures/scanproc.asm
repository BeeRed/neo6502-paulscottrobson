; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scanproc.asm
;		Purpose:	Scan Procedures
;		Created:	4th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Scan code looking for procedures
;
; ************************************************************************************************

ScanProcedures:
		lda 	codePtr 					; push codePtr on the stack
		pha
		lda 	codePtr+1
		pha
		phy

		lda 	PGMBaseHigh 				; back to the program start
		sta 	codePtr+1
		stz 	codePtr		
		;
_SPLoop:
		lda 	(codePtr) 					; end of program
		beq 	_SPExit
		ldy 	#3 							; first token PROC
		lda 	(codePtr),y
		cmp 	#PR_PROC
		bne 	_SPNext
		jsr 	_SPSetupRecord
_SPNext:	
		clc 								; forward to next			
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_SPLoop
		inc 	codePtr+1
		bra 	_SPLoop
_SPExit:
		ply
		pla
		sta 	codePtr+1
		pla
		sta 	codePtr
		rts
		;
		;		Set up a new procedure record.
		;
_SPSetupRecord:
		iny 								; check identifier follows
		lda 	(codePtr),y
		and 	#$C0
		cmp 	#$40
		bne 	_SPSyntax
		;
		jsr 	VARGetInfo 					; get the information
		jsr 	ERRCheckRParen 				; check right bracket follows.
		jsr 	VARFind 					; already exists ?
		bcs 	_SPUsed 					; error !
		jsr 	VARCreate 					; create, XA points to the data.
		;
		sta 	zTemp0
		stx 	zTemp0+1
		;		
		phy 								; save Y pos on stack
		ldy 	#1
		lda 	codePtr 					; save codePtr/Y
		sta 	(zTemp0)
		lda 	codePtr+1
		sta 	(zTemp0),y
		iny
		pla
		sta 	(zTemp0),y
		iny
		lda 	#$FF 						; fill rest with $FF
		sta 	(zTemp0),y
		rts

_SPSyntax:		
		.error_syntax
_SPUsed:
		.error_dupproc
		.send code
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
