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
		jsr 	OSReadData 					; read the data file in.
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

OSReadData:
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

