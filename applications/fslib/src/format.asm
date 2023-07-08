; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		format.asm
;		Purpose:	Format the flash drive
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Format drive
;
; 			    		   On entry, YX is the sector count
;
; ************************************************************************************************

		.section code

OSFormatFlash:
		phx 								; save sector count

		phy	 								; savce sector count as well.
		phx
		;
		;		Erase the information sector which doesn't care about sector sizes etc.
		;
		lda 	#0 							; erase sector zero
		jsr 	FSHErase
		;
		;		Write 'I',1,Count.Lo,Count.Hi,2^Size
		;
		lda 	#'I' 						; sector type (information)
		sta 	sectorHeader+0
		lda 	#'1'						; format 1
		sta 	sectorHeader+1

		pla 								; write the sector count.
		sta 	sectorHeader+2
		pla
		sta 	sectorHeader+3

		ldx 	#sectorHeader & $FF 		; source address.
		stx 	iTemp0
		ldx 	#sectorHeader >> 8
		stx 	iTemp0+1

		lda 	#0 							; sector and sub page zero
		tax

		jsr 	FSHWrite 					; write out
		;
		;		Re-initialise and erase other sectors
		;
		jsr 	FSInitialise 				; re-initialise the file system.

		pla 								; count of sectors.
_OSFFErase:
		dec 	a 							; last sector and backwards
		pha 								; erase it saving A
		jsr 	FSHErase
		pla
		cmp 	#1 							; don't erase sector 0
		bne 	_OSFFErase		
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

