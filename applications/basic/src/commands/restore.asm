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

