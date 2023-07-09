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

		stz 	currentSector 				; start from the beginning.

		lda 	#$FF 						; set flag to $FF
		sta 	successFlag
		;
		;		Look for (F)irst 
		;
_OSReadLoop1:
		jsr 	FSReadNextHeader 			; read header ?
		bcs 	_OSReadExit 				; end of search, not found.
		lda 	shFirstNext 				; is it the (F)irst record
		cmp 	#"F"
		bne 	_OSReadLoop1
		jsr 	FSCompareFileNames 			; is it F and matching.
		bcc 	_OSReadLoop1 				; no, try next sector
		stz 	successFlag 				; zero when found file.
		;
		;		Read the block in.
		;
_OSReadBlock:
		jsr 	FSReadData 					; read the data file in.
		lda 	shContinue 					; continuation ?
		cmp 	#"N" 						; exit if no.
		beq 	_OSReadExit
		stz 	checkLoopRound
		;
		;		Find the next block
		;
_OSReadLoop2:	
		dec 	checkLoopRound				; this shouldn't happen.
		beq 	_OSFileCorrupt 				; the file system is corrupt, F without N
		jsr 	FSReadNextHeader 			; read header ?
		lda 	shFirstNext 				; is it the (F)irst record
		cmp 	#"N"
		bne 	_OSReadLoop2
		jsr 	FSCompareFileNames 			; is it F/N and matching.
		bcc 	_OSReadLoop2 				; no, try next sector
		bra 	_OSReadBlock 				; read block in.

_OSFileCorrupt:
		sec
		rts

_OSReadExit:		
		asl 	successFlag					; shift success flag (0 if done) into carry
		rts

; ************************************************************************************************
;
;								Read current sector into memory
;
; ************************************************************************************************

FSReadData:
		ldx  	#1 							; current subpage in sector
_FSReadLoop:
		lda 	shDataSize 					; datasize count zero, exit ?
		ora 	shDataSize+1
		beq 	_OSRDExit

		jsr 	FSIncrementSetLoad 			; copy load address and bump by one page.

		ldy 	shDataSize 					; number of bytes to read
		lda 	shDataSize+1 				; if 00xx then it is xx
		beq 	_FSPartPage
		ldy 	#0 							; otherwise it's zero (e.g. 256)
_FSPartPage:		
		lda 	currentSector 				; A = sector, X = subpage, Y = bytes to read
		phx
		jsr 	FSHRead 					; write out the sub page.
		plx
		inx  								; next sub page.

		lda 	shDataSize+1 				; if < 1 whole page we are done
		beq 	_OSRDExit

		dec 	shDataSize+1 				; done one.
		bra 	_FSReadLoop
_OSRDExit:				
		rts

; ************************************************************************************************
;
;					Copy load/save address to iTemp0, increment it by 256
;
; ************************************************************************************************

FSIncrementSetLoad:		
		phy
		clc
		ldy 	#2
		lda 	(fsBlock),y  				; copying previous to iTemp0
		sta 	iTemp0
		iny
		lda 	(fsBlock),y  				
		sta 	iTemp0+1
		inc 	a 							; move one page on.
		sta 	(fsBlock),y
		ply
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

