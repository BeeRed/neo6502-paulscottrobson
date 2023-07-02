; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		delete.asm
;		Purpose:	Delete a file
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Delete File
;
;						   On entry, YX points to a file block.
;							On exit, CS if file not found.
;
; ************************************************************************************************

		.section code

OSDeleteFile:
		stx 	fsBlock 					; file block.
		sty 	fsBlock+1

		stz 	currentSector
		lda 	#$FF 						; set flag to $FF
		sta 	successFlag
_OSDeleteLoop:
		jsr 	FSReadNextHeader 			; read header ?
		bcs 	_OSDeleteExit 				; end of search.
		jsr 	FSCompareFileNames 			; is it F/N and matching.
		bcc 	_OSDeleteLoop 				; no, try next sector

		lda 	currentSector 				; yes, then erase this sector
		jsr 	FSHErase
		stz 	successFlag 				; zero if successful
		bra 	_OSDeleteLoop
_OSDeleteExit:		
		asl 	successFlag					; shift success flag (0 if done) into carry
		rts

; ************************************************************************************************
;
;			Check current header is (F)irst (N)ext and name matches that in iBlock
;										CS if match found
;
; ************************************************************************************************

FSCompareFileNames:
		lda 	shFirstNext 				; is it F/N type ?
		cmp 	#"F"
		beq 	_FSDeleteCheckName
		cmp 	#"N"
		bne 	_FSCompareFail 				; no, then compare fails.
_FSDeleteCheckName:
		ldy 	#1 							; copy filename to iTemp0
		lda 	(fsBlock)
		sta 	iTemp0
		lda 	(fsBlock),y
		sta 	iTemp0+1
		;
		lda 	(iTemp0) 					; compare n+1
		tay
_FSCompareName:
		lda 	shNameLength,y
		cmp 	(iTemp0),y
		bne 	_FSCompareFail
		dey
		bpl 	_FSCompareName
		.debug
		sec
		rts

_FSCompareFail:		
		clc
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

