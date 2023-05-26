; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assert.asm
;		Purpose:	Asserts an expression
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										ASSERT Command
;
; ************************************************************************************************

		.section code

Command_ASSERT:	;; [assert]
		jsr 	EXPEvalNumber
		ldx 	#IFR0
		jsr 	IFloatCheckZero
		beq 	_CAFail
		rts
_CAFail:		
		.error_assert
		
		.send code

;:[ASSERT(expr)]\
; Assert asserts a contract and is useful for parameter validation and testing. It evaluates the
; provided expression, and providing it is non zero. If it is zero, an error occurs.\
; An example use might be assert {name$<>""} to check that a name has been provided to a routine.

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

