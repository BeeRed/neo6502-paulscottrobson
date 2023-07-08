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
;		lda 	sectorSize 					; (sector size - 32)
		sbc 	#32
		sta 	sectorCapacity
;		lda 	sectorSize+1
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
		lda 	currentSector 				; erase sector
		jsr 	FSHErase
		lda 	currentSector 				; open for write.
;		jsr 	FSHOpenWrite
		jsr 	FSWriteCreateHeader 		; create header
		jsr 	FSWriteSendData 			; send the data
;		jsr 	FSHEndCommand 				; and we're done this block.		
		;
		dec 	notFirstSector 				; set not first sector state.
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

FSWriteCreateHeader:
		;
		;		First or Next flag
		;
		lda 	#"N"						; first or next ?
		ldx 	notFirstSector
		bne 	_FSWCNotNext
		lda 	#"F"
_FSWCNotNext:		
;		jsr 	FSHWrite 					; +0 (first or next)
		;
		;		Work out the number of bytes going out into YX
		;
		ldx 	fileRemainingSize 			; XY is the number of bytes.
		ldy 	fileRemainingSize+1
		;
		cpx 	sectorCapacity 				; compare fileRemaining vs sectorCapacity
		tya
		sbc 	sectorCapacity+1
		bcc 	_FSNotFull
		ldx 	sectorCapacity 				; if remaining >= capacity ... use capacity
		ldy 	sectorCapacity+1		
_FSNotFull:		
		stx 	bytesToWrite
		sty 	bytesToWrite+1
		;
		;		More records ? (YX = file Remaining size)
		;
		lda 	#"Y"
		cpx 	fileRemainingSize
		bne 	_FSNotAll
		cpy 	fileRemainingSize+1
		bne 	_FSNotAll
		lda 	#"N"
_FSNotAll:		
;		jsr 	FSHWrite 					; +1 (has more data)
		;
		;		Output data size and file size.
		;
		txa 								; +2,+3 (data to send out) 	
;		jsr 	FSHWrite
		tya 	
;		jsr 	FSHWrite
		;
		ldy 	#4
		lda 	(fsBlock),y
		jsr 	FSHWrite
		iny
		lda 	(fsBlock),y
;		jsr 	FSHWrite
		;
		;		Output 10 char gap which is reserved.
		;
		ldx		#10 						; output 10 blanks
_FSWCBlanks:
		lda 	#$FF
;		jsr 	FSHWrite
		dex
		bne 	_FSWCBlanks
		;
		;		Output name
		;
		ldy 	#1
		lda 	(fsBlock),y
		sta 	iTemp0+1
		lda 	(fsBlock)
		sta 	iTemp0
		;
		lda 	(iTemp0) 					; output length, also => X
		tax
		jsr 	FSHWrite
_FSOutName: 								; output name
		dex
		bmi 	_FSNameDone
		lda 	(iTemp0),y
		iny
		jsr 	FSHWrite
		bra 	_FSOutName
_FSNameDone:				 				; pad out to 32 byte header.
		lda 	#$FF
		jsr 	FSHWrite
		iny
		cpy 	#16
		bne 	_FSNameDone
		rts

; ************************************************************************************************
;
;										Output the body
;
; ************************************************************************************************

FSWriteSendData:
		lda 	bytesToWrite 				; complete
		ora 	bytesToWrite+1
		beq 	_FSWSDExit
		jsr 	FSIncrementSetLoad 			; bump address, copy original to iTemp0
		lda 	(iTemp0)
;		jsr 	FSHWrite
		;
		lda 	bytesToWrite 				; decrement bytes to write counter
		bne 	_FSWSDNoBorrow
		dec 	bytesToWrite+1
_FSWSDNoBorrow:		
		dec 	bytesToWrite

		lda 	fileRemainingSize 			; decrement remaining size.
		bne 	_FSWSDNoBorrow2
		dec 	fileRemainingSize+1
_FSWSDNoBorrow2:
		dec 	fileRemainingSize		
		bra 	FSWriteSendData

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

