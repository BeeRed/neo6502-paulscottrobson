; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		find.asm
;		Purpose:	Check for existence of variable as stored
;		Created:	29th May 2023
;		Reviewed: 	9th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						Using stored information, search for variable
;					 CS = found with XA the data address, CC = not found
;
; ************************************************************************************************

		.section code

VARFind:	
		phy
		ldy 	#1 							; get first link -> zTemp1
		lda 	(zTemp0),y
		sta 	zTemp1+1
		beq 	_VFExitFail 				; first link is 00xx, so nothing in that list.
		lda 	(zTemp0) 					; complete the link.
		sta 	zTemp1
		;
		;		Variable find loop
		;
_VFLoop:
		ldy 	#2 							; check hashes match
		lda 	(zTemp1),y
		cmp 	VARHash
		beq 	_VFHashesMatch 				; if so, check the name.
		;
		;		Hashes don't match, go to next.
		;
_VFNext:	
		lda 	(zTemp1) 					; next link to AX
		tax
		ldy 	#1
		lda 	(zTemp1),y		
		sta 	zTemp1+1
		stx 	zTemp1
		cmp 	#0 							; if msb non zero, try again
		bne 	_VFLoop
		;
		;		Not found
		;
_VFExitFail:
		ply
		clc
		rts
		;
		;		Hashes match so compare the actual text
		;
_VFHashesMatch:								; hashes match, so compare the names.
		ldy 	#3 							; get address of name -> zTemp2
		lda 	(zTemp1),y
		sta 	zTemp2
		iny		
		lda 	(zTemp1),y
		sta 	zTemp2+1
		;
		ldy 	#$FF 						; now compare
_VFNameCompLoop:
		iny 								; char at a time
		lda 	VARBuffer,y
		cmp 	(zTemp2),y
		bne 	_VFNext						; next entry if different.
		cmp 	#$7C
		bcc 	_VFNameCompLoop 			; until done the whole lot.
		;
		;		Found
		;
		clc 								; +5 is the offset of the actual data
		lda 	zTemp1 						; word:link byte:hash word:name pointer
		ldx 	zTemp1+1
		adc 	#5
		bcc 	_VFNNoCarry
		inx
_VFNNoCarry:
		ply
		sec
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

