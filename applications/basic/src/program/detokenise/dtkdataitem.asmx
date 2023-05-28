; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dtkdataitem.asm
;		Purpose:	Detokenise data item
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Detokenise data item
;
; ************************************************************************************************

TOKDDataItem:
		tay 								; type in Y
		lda 	#'"'						; start with " or .
		cpy 	#PR_STRING
		beq 	_TOKDDIsString
		lda 	#'.'
_TOKDDIsString:
		jsr 	TOKDOutput 					; dump it
		jsr 	TOKDGet 					; get length into X
		tax 
_TOKDDOutput:
		dex 								; are we complete
		bmi 	_TOKDDEnd
		jsr 	TOKDGet 					; get character and output it
		jsr 	TOKDOutput
		bra 	_TOKDDOutput
_TOKDDEnd:
		cpy 	#PR_STRING 					; if string, do closing quote
		bne 	_TOKDDNotString
		lda 	#'"'
		jsr 	TOKDOutput
_TOKDDNotString:
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

