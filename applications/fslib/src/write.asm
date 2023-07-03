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
		stx 	fsBlock 					; file block.
		sty 	fsBlock+1
		jsr 	OSDeleteFile 				; delete file if it already exists.
		stz 	currentSector
		stz 	notFirstSector 				; clear "not first sector" (e.g. is first sector)
		;
		sec 								; work out bytes per sector available.
		lda 	sectorSize 					; (sector size - 32)
		sbc 	#32
		sta 	sectorCapacity
		lda 	sectorSize+1
		sbc 	#0
		sta 	sectorCapacity+1
		;
		ldy 	#4 							; copy the size of the data to write to 
		lda 	(fsBlock),y 				; the remaining size variable.
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
		.debug
		;
		lda 	currentSector 				; erase sector
		jsr 	FSHErase
		lda 	currentSector 				; open for write.
		jsr 	FSHOpenWrite
		jsr 	FSWriteCreateHeader 		; create header
		jsr 	FSWriteSendData 			; send the data
		jsr 	FSHEndCommand 				; and we're done this block.		
		;
		dec 	notFirstSector 				; set not first sector state.
		;
		lda 	fileRemainingSize 			; check there is more to save, if not then exit.
		ora 	fileRemainingSize+1		
		bne		_OSWriteLoop
		;
		;		Come here on failure (probably out of space)
		;
_OSWriteFail:
		jsr 	OSDeleteFile 				; delete any parts of the file.				
		sec 								; return error
		rts

FSWriteCreateHeader:
		rts

FSWriteSendData:
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

