; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		bootapple.asm
;		Purpose:	Boot Apple II
;		Created:	14th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										][ Command
;
; ************************************************************************************************

		.section code

Command_ABoot:	;; [][]
		lda 	#12
		jsr 	OSWriteScreen
		
		lda 	#_A2ROMName & $FF 			; set file address
		sta 	FSBBlock+0
		lda 	#_A2ROMName >> 8
		sta 	FSBBlock+1
		lda 	PGMBaseHigh 				; set load address
		sta 	FSBBlock+3
		stz 	FSBBlock+2
		stz 	FSBBlock+4
		stz 	FSBBlock+5
		ldx 	#FSBBlock & $FF 			; read the file.
		ldy 	#FSBBlock >> 8
		jsr 	OSReadFile

		lda 	#0 							; switch apple mode.
		jsr 	OSSetDisplayMode

		lda 	PGMBaseHigh 				; copy to ROM area (may not work for BASIC in ROM ?)
		sta 	zTemp0+1
		lda 	#$D0
		sta 	zTemp1+1
		stz 	zTemp0
		stz 	zTemp1
		ldy 	#0
_CACopyROM:
		lda 	(zTemp0),y
		sta 	(zTemp1),y
		iny
		bne 	_CACopyROM
		inc 	zTemp0+1
		inc 	zTemp1+1
		bne 	_CACopyROM


		jmp 	($FFFC)

_A2ROMName:
		.text 	_A2RNEnd-*-1,"apple.rom"
_A2RNEnd:		
		.send code

;:[][]\
; Boot the Apple 2

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

