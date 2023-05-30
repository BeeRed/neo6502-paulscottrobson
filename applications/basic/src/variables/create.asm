; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		create.asm
;		Purpose:	Create variable specificied in information
;		Created:	29th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						Using collected information, create a new variable.
;
; ************************************************************************************************

		.section code

VARCreate:
		;
		;		Allocate memory
		;
		lda 	#9 							; create 9 bytes of space
		ldx 	#0
		jsr 	AllocateMemory
		sta 	zTemp1 						; save new address in zTemp1
		stx 	zTemp1+1
		;
		;		Fill in hash and reference to variable name
		;
		ldy 	#2 							; put hash into +2
		lda 	VARHash
		sta 	(zTemp1),y
		;
		iny 								; put address of name into +3,+4
		lda 	VARNameAddress
		sta 	(zTemp1),y
		iny
		lda 	VARNameAddress+1
		sta 	(zTemp1),y
		;
		;		Link into hash table - old head becomes link on new record
		;		(inserted into front)
		;
		lda 	VARHashEntry 				; hash table ptr -> zTemp0
		sta 	zTemp0
		lda 	VARHashEntry+1
		sta 	zTemp0+1
		;
		ldy 	#1 							; put current head into link.
		lda 	(zTemp0)
		sta 	(zTemp1)
		lda 	(zTemp0),y
		sta 	(zTemp1),y
		;
		;		New Record is the new head
		;
		lda 	zTemp1 						; address of the new record into head
		sta 	(zTemp1)
		lda 	zTemp1+1
		sta 	(zTemp1),y
		;
		;		Make XA point to the data part of the variable (e.g. offset 5)
		;
		lda 	zTemp1 						; new record to XA
		ldx 	zTemp1+1
		clc 								; add 5 to point to the data.
		adc 	#5
		bcc 	_VCNoCarry
		inx
_VCNoCarry:		
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

