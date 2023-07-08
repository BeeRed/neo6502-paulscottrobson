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
; 			    On entry, YX is the sector count, A the 2 power (normally 12)
;
; ************************************************************************************************

		.section code

OSFormatFlash:
		phx 								; save sector count

		pha									; save parameters.
		phy
		phx
		;
		;		Erase the information sector which doesn't care about sector sizes etc.
		;
		lda 	#0 							; erase sector zero
		jsr 	FSHErase
		;
		;		Write 'I',1,Count.Lo,Count.Hi,2^Size
		;
;		lda 	#0 							; open sector zero for writing.
;		jsr 	FSHOpenWrite
;
;		lda 	#'I' 						; sector type (information)
;		jsr 	FSHWrite
;		lda 	#1 							; format 1
;		jsr 	FSHWrite
;
;		pla 								; write the sector count.
;		jsr 	FSHWrite
;		pla
;		jsr 	FSHWrite
;
;		pla 								; write the sector size power.
;		jsr 	FSHWrite
;		jsr 	FSHEndCommand 				; end command
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

