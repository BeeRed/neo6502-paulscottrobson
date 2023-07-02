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
		inc 	currentSector 				; bump last sector and read next one.
		lda 	currentSector
FSReadHeaderA:
		cmp 	#0 							; sector 0 always okay.
		beq 	_FSIsOk
		cmp 	sectorCount 				; check legitimate sector
		bcs 	_FSReadHFail
_FSIsOk:		
		phx
		sta 	currentSector 				; save as current
		jsr 	FSHOpenRead 				; open for read
		ldx 	#0 							; read in.
_FSReadHLoop:
		jsr 	FSHRead
		sta 	sectorHeader,x
		inx
		cpx 	#32
		bne 	_FSReadHLoop		
		jsr 	FSHEndCommand				; end read.
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

