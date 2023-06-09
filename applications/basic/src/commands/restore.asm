S; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		restore.asm
;		Purpose:	Restore Data Pointer to start
;		Created:	9th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										RESTORE Command
;
; ************************************************************************************************

		.section code

Command_RESTORE:	;; [restore]
		lda 	PGMBaseHigh 				; back to the program start
		sta 	dataPtr+1
		stz 	dataPtr
		lda 	#3 							; position start of line
		sta 	dataPos
		stz 	dataInStatement 			; not in statement
		rts
		
		.send code

;:[RESTORE]\
; Reset the READ/DATA position to the start.

; ************************************************************************************************
;
;										Swap Code and Data
;
; ************************************************************************************************

SwapCodeDataPointers:
		lda 	dataPtr 					; swap LSB of code/data
		ldx 	codePtr
		sta 	codePtr
		stx 	dataPtr

		lda 	dataPtr+1 					; swap MSB of code/data
		ldx 	codePtr+1
		sta 	codePtr+1
		stx 	dataPtr+1

		lda 	dataPos 					; swap dataPos and Y
		sty 	dataPos
		tay
		rts
		
		.section storage
dataPtr: 									; Data equivalent of CodePtr
		.fill 	2		
dataPos: 									; Data position of Y
		.fill 	2		
dataInStatement: 							; Non zero if currently in data statement
		.fill 	1		 					; (should be pointing at , : or EOL)
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

