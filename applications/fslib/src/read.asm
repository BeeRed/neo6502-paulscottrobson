; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		read.asm
;		Purpose:	Read a file
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Read File
;
;						   On entry, YX points to a file block.
;							On exit, CS if file not found.
;
; ************************************************************************************************

		.section code

OSReadFile:
		stx 	fsBlock 					; file block.
		sty 	fsBlock+1

		stz 	currentSector
		lda 	#$FF 						; set flag to $FF
		sta 	successFlag
		;
		;		Look for (F)irst 
		;
_OSReadLoop1:
		jsr 	FSReadNextHeader 			; read header ?
		bcs 	_OSReadExit 				; end of search.
		lda 	shFirstNext 				; is it the (F)irst record
		cmp 	#"F"
		bne 	_OSReadLoop1
		jsr 	FSCompareFileNames 			; is it F/N and matching.
		bcc 	_OSReadLoop1 				; no, try next sector
		stz 	successFlag 				; zero when found file.

_OSReadBlock:
		lda 	currentSector
		jsr 	FSReadData 					; read the data file in.
		lda 	shContinue 					; continuation ?
		cmp 	#"N" 						; exit if no.
		beq 	_OSReadExit
		;
_OSReadLoop2:		
		lda 	currentSector
		jsr 	FSReadNextHeader 			; read header ?
		bcs 	_OSReadExit 				; end of search.	
		lda 	shFirstNext 				; is it the (F)irst record
		cmp 	#"N"
		bne 	_OSReadLoop2
		jsr 	FSCompareFileNames 			; is it F/N and matching.
		bcc 	_OSReadLoop2 				; no, try next sector
		bra 	_OSReadBlock 				; read block in.

_OSReadExit:		
		asl 	successFlag					; shift success flag (0 if done) into carry
		rts

; ************************************************************************************************
;
;								Read current sector into memory
;
; ************************************************************************************************

FSReadData:
		lda 	currentSector
		jsr 	FSHOpenRead 				; open for read
		ldx 	#32 						; read past the header
_FSReadHLoop:
		jsr 	FSHRead
		dex
		bne 	_FSReadHLoop		
		;
_FSRDCopy:
		lda 	shDataSize 					; datasize count zero ?
		ora 	shDataSize+1
		beq 	_OSRDExit
		;
		lda 	shDataSize 					; decrement the data count.
		bne 	_OSRDNoBorrow
		dec 	shDataSize+1
_OSRDNoBorrow:
		dec 	shDataSize		
		;
		jsr 	FSIncrementSetLoad 			; load address to zTemp0 and increment it.
		jsr 	FSHRead 					; copy byte there
		sta 	(iTemp0)
		bra 	_FSRDCopy 					; go round again.

_OSRDExit:				
		jsr 	FSHEndCommand
		rts

; ************************************************************************************************
;
;						Copy load/save address to zTemp0, increment it.
;
; ************************************************************************************************

FSIncrementSetLoad:		
		clc
		ldy 	#2 							; increment load address
		lda 	(fsBlock),y  				; copying previous to zTemp0
		sta 	iTemp0
		adc 	#1
		sta 	(fsBlock),y
		iny
		lda 	(fsBlock),y  				
		sta 	iTemp0+1
		adc 	#0
		sta 	(fsBlock),y
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

