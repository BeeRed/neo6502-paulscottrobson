; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		setup.asm
;		Purpose:	Reset the BASIC stack
;		Created:	31st May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;			Reset the BASIC stack. Return in A the MSB of the bottom of stack space
;
; ************************************************************************************************

StackReset:
		pha 								; save top of memory
		dec 	a  							; end of stack = previous byte
		sta 	basicStack+1
		lda 	#$FF
		sta 	basicStack
		lda 	#$F0 						; impossible frame marker - cannot have one with 0 bytes.
		sta 	(basicStack) 				; puts a dummy marker at TOS which will never match things like NEXT/RETURN
											; any attempt to pop it will cause an error
		pla 								; allocate pages for stack.
		sec
		sbc 	#2											
		rts

		.send code

		.section zeropage
basicStack:
		.fill 	2
		.send zeropage
		
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
