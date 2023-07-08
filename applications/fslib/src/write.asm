; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		read.asm
;		Purpose:	Read a file
;		Created:	3rd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Write File
;
;						   On entry, YX points to a file block.
;					  On exit, CS if failed (most likely no space)
;
; ************************************************************************************************

		.section code

OSWriteFile:
		.debug
		stx 	fsBlock 					; file block.
		sty 	fsBlock+1
		jsr 	OSDeleteFile 				; delete file if it already exists
		.
		stz 	currentSector
		stz 	notFirstSector 				; clear "not first sector" (e.g. is first sector)
		;
		ldy 	#4 							; copy the size of the data to write to 
		lda 	(fsBlock),y 				; the "remaining size" variable.
		sta 	fileRemainingSize
		iny
		lda 	(fsBlock),y
		sta 	fileRemainingSize+1
		;
		;		Main write loop. First find an empty slot.
		;
_OSWriteLoop:
		lda 	sectorCount  				; so we count incase we are full.
		sta 	iTemp0		
		;
_OSFindUnused:		
		dec 	iTemp0 						; done a full lap, no empty slots
		beq 	_OSWriteFail
		jsr 	FSReadNextHeader 			; read next header
		lda 	shFirstNext 				; check F, N , I
		cmp 	#"I"
		beq 	_OSFindUnused
		cmp 	#"N"
		beq 	_OSFindUnused
		cmp 	#"F"
		beq 	_OSFindUnused
		;
		;		Found on empty slot.
		;
		lda 	currentSector 				; erase sector
		jsr 	FSHErase
		lda 	currentSector 				; open for write.
		;
		;		Write the header to the first page.
		;
		jsr 	FSCreateHeader 				; create header

		ldx 	#sectorHeader & $FF 		; source address.
		stx 	iTemp0
		ldx 	#sectorHeader >> 8
		stx 	iTemp0+1
		;
		lda 	currentSector 				; write the sector out.
		ldx 	#0
		jsr 	FSHWrite
		;
		dec 	notFirstSector 				; set "not first sector" state.
		;
		;jsr 	FSWriteSendData 			; write the body out.
		;
		sec
		lda 	fileRemainingSize 			; subtract data sent from file remaining.
		sbc 	shDataSize
		sta 	fileRemainingSize
		lda 	fileRemainingSize+1
		sbc 	shDataSize+1
		sta 	fileRemainingSize+1
		;
		lda 	fileRemainingSize 			; check there is more to save, if not then exit.
		ora 	fileRemainingSize+1		
		bne		_OSWriteLoop
		clc
		rts
		;
		;		Come here on failure (probably out of space)
		;
_OSWriteFail:
		jsr 	OSDeleteFile 				; delete any parts of the file.				
		sec 								; return error
		rts

; ************************************************************************************************
;
;										Create the 32 byte header 
;
; ************************************************************************************************

FSCreateHeader:
		;
		;		First or Next flag
		;
		lda 	#"N"						; first or next ?
		ldx 	notFirstSector
		bne 	_FSWCNotNext
		lda 	#"F"
_FSWCNotNext:		
		sta 	shFirstNext		
		;
		;		Work out the number of bytes going out into YX
		;
		ldx 	fileRemainingSize 			; XY is the number of bytes.
		ldy 	fileRemainingSize+1
		lda 	#"N" 						
		;
		cpy 	#(4096-256) >> 8 			; if less than a full sector
		bcc 	_FSNotFull

		ldy 	#(4096-256) >> 8 			; number of bytes to write
		ldx 	#0
		lda 	#"Y" 						; and there are more bytes.
_FSNotFull:		
		;
		;		Set continue, data size, and file size.
		;	
		sta 	shContinue 					; write out the continue
		;
		stx 	shDataSize 					; write out the size of data in this file.
		sty 	shDataSize+1
		;
		ldy 	#4
		lda 	(fsBlock),y
		sta 	shFileSize
		iny
		lda 	(fsBlock),y
		sta 	shFileSize+1
		;
		;		Copy name - iTemp0 points to string then copy it out.
		;
		ldy 	#1
		lda 	(fsBlock),y
		sta 	iTemp0+1
		lda 	(fsBlock)
		sta 	iTemp0
		;
		lda 	(iTemp0) 					; copy length.
		tax 								; length in X
		ldy 	#0
_FSOutName: 								; copy name.
		lda 	(iTemp0),y
		sta 	shNameLength,y
		iny		
		dex
		bmi 	_FSOutName

_FSNameDone:				 				
		rts

; ************************************************************************************************
;
;										Output the body
;
; ************************************************************************************************

FSWriteSendData:
;		lda 	bytesToWrite 				; complete
;		ora 	bytesToWrite+1
;		beq 	_FSWSDExit
;		jsr 	FSIncrementSetLoad 			; bump address, copy original to iTemp0
		lda 	(iTemp0)
;;		jsr 	FSHWrite
		;
;		lda 	bytesToWrite 				; decrement bytes to write counter
;		bne 	_FSWSDNoBorrow
;		dec 	bytesToWrite+1
;_FSWSDNoBorrow:		
;		dec 	bytesToWrite
;
;		lda 	fileRemainingSize 			; decrement remaining size.
;		bne 	_FSWSDNoBorrow2
;		dec 	fileRemainingSize+1
;_FSWSDNoBorrow2:
;		dec 	fileRemainingSize		
;		bra 	FSWriteSendData
;
_FSWSDExit:		
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

