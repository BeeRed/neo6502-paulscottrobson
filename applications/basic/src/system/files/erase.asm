; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		erase.asm
;		Purpose:	Delete file
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										ERASE Command
;
; ************************************************************************************************

		.section code

Command_ERASE:	;; [erase]
		jsr 	FileSetupBlock 				; set up file i/o block with filename.
		phy
		ldx 	#FSBBlock & $FF
		ldy 	#FSBBlock >> 8
		jsr 	OSDeleteFile
		ply
		bcs 	_CEFail
		rts		
_CEFail:	
		.error_fnf

; ************************************************************************************************
;
;							Set up FSBBlock with a file name string
;
; ************************************************************************************************

FileSetupBlock:				
		jsr 	EXPEvalString 					; string to R0, zTemp0		
		lda 	zTemp0 							; address to name 
		sta 	FSBBlock
		lda 	zTemp0+1
		sta 	FSBBlock+1 						; zero the rest.
		stz 	FSBBlock+2
		stz 	FSBBlock+3
		stz 	FSBBlock+4
		stz 	FSBBlock+5
		rts

		.send code

		.section storage
FSBBlock:
		.fill 	6
		.send storage

;:[ERASE <file>]\
; Deletes a file on the current storage media.

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

