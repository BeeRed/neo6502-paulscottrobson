; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		save.asm
;		Purpose:	Save file
;		Created:	3rd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										SAVE Command
;
; ************************************************************************************************

		.section code

Command_SAVE:	;; [save]
		jsr 	FileSetupBlock 				; set up file i/o block with filename.

		lda 	(codePtr),y 				; what follows ?
		cmp 	#PR_COMMA 					; comma ?
		beq 	_CLSaveBlock 				; save "Name",from,size
		lda 	PGMBaseHigh 				; set load address
		sta 	FSBBlock+3
		stz 	FSBBlock+2

		jsr		PGMEndProgram 				; end of program -> zTemp0
		inc 	zTemp0 						; bump past end NULL
		bne 	_CLNoCarry
		inc 	zTemp0+1
_CLNoCarry:

		lda 	zTemp0
		sta 	FSBBlock+4

		sec
		lda 	zTemp0+1
		sbc 	FSBBlock+3
		sta 	FSBBlock+5		
		bra 	_CSSave

_CLSaveBlock:
		jsr 	FileCheckSecondParam 		; the address to save from.
		jsr 	ERRCheckComma
		jsr 	EXPEvalInteger16 			; get size
		lda 	IFR0+IM0	 				; copy it
		sta 	FSBBlock+4
		lda 	IFR0+IM1
		sta 	FSBBlock+5
		.debug

_CSSave:		
		phy
		ldx 	#FSBBlock & $FF
		ldy 	#FSBBlock >> 8
		jsr 	OSWriteFile
		ply
		bcs 	_CSFail
		rts		
_CSFail:	
		.error_full

;:[SAVE <file>,<address>,<size>]\
; Saves a block of memory, the default is the BASIC program

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

