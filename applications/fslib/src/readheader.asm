; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		readheader.asm
;		Purpose:	Read a sector header
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									    Read a header
;
; ************************************************************************************************

		.section code

FSReadNextHeader:
		lda 	currentSector 				; if at end at beginning loop back to #1
		cmp 	sectorCount
		bcc 	_FSRNHNotEnd
		stz 	currentSector
_FSRNHNotEnd:		
		inc 	currentSector 				; bump last sector and read next one.
		lda 	currentSector
		;
FSReadHeaderA:
		cmp 	#0 							; sector 0 always okay.
		beq 	_FSIsOk
		cmp 	sectorCount 				; check legitimate sector
		bcs 	_FSReadHFail
_FSIsOk:		
		phx
		sta 	currentSector 				; save as current
		ldx 	#sectorHeader & $FF 		; target address.
		stx 	iTemp0
		ldx 	#sectorHeader >> 8
		stx 	iTemp0+1
		ldx 	#0 							; subpage 0
		ldy 	#32 						; first 32 bytes only.
		jsr 	FSHRead 					; read the sector into memory
		plx

		lda 	shFileSize 					; copy file size - makes easily accessible
		sta 	shFileSizeCopy 				; for directory function.
		lda 	shFileSize+1
		sta 	shFileSizeCopy+1

		clc
		rts
_FSReadHFail:
		sec
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

