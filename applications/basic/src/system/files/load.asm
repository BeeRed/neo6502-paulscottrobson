; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		load.asm
;		Purpose:	Load file
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										LOAD Command
;
; ************************************************************************************************

		.section code

Command_LOAD:	;; [load]
		jsr 	FileSetupBlock 				; set up file i/o block with filename.

		lda 	PGMBaseHigh 				; set load address
		sta 	FSBBlock+3
		stz 	FSBBlock+2

		lda 	(codePtr),y 				; what follows ?
		pha
		jsr	 	FileCheckSecondParam
		phy
		ldx 	#FSBBlock & $FF
		ldy 	#FSBBlock >> 8
		jsr 	OSReadFile
		ply
		bcs 	_CLFail
		;
		pla 								; load program
		cmp 	#PR_COMMA
		beq 	_CLNoClear
		jsr 	ClearCode 					; run CLEAR code, loaded a new program in.
		jmp 	WarmStart 					; and warm start

_CLNoClear:		
		rts		
_CLFail:	
		.error_fnf

;:[LOAD <file>,<address>]\
; Loads a program file to the given address, if no address is provided it is assumed
; to be a BASIC program.

; ************************************************************************************************
;
;							Check second parameter (LOAD address)
;
; ************************************************************************************************

FileCheckSecondParam:
		lda 	(codePtr),y 				; , follows
		cmp 	#PR_COMMA
		bne 	_FCSPExit
		;
		iny 								; consume
		jsr 	EXPEvalInteger16 			; get address
		lda 	IFR0+IM0	 				; copy it
		sta 	FSBBlock+2
		lda 	IFR0+IM1
		sta 	FSBBlock+3
_FCSPExit:
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

