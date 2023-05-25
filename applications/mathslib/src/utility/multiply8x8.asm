; ************************************************************************************************
; ************************************************************************************************
;
;	Name:		multiply8x8.asm
;	Purpose:	Fast 8x8 multiply r0 = r0.rx
;	Created:	25th May 2023
;	Reviewed: 	No
;	Author:		Paul Robson (paul@robsons.org.uk)
;                       Thwaite (https://www.nesdev.org/wiki/8-bit_Multiply)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					                  R0 = R0 * RX
;
; ************************************************************************************************

IFloatMultiply8BitRx:
        phy
        lda     IM0,x                       ; AY are the two values
        ldy     IFR0+IM0 
        ;
        ;     Factor 1 is stored in the lower bits of IFR0+IM0; the low byte of
        ;     the product is stored in the upper bits.
        ;
        lsr     a                           ; prime the carry bit for the loop
        sta     IFR0+IM0
        sty     IFR0+IM1
        lda     #0
        ldy     #8
_IFMLoop:
        ;       At the start of the loop, one bit of IFR0+IM0 has already been
        ;       shifted out into the carry.
        bcc     _IFMNoAdd
        clc
        adc     IFR0+IM1
_IFMNoAdd:
        ror     a
        ror     IFR0+IM0                    ; pull another bit out for the next iteration
        dey        
        bne     _IFMLoop
        sta     IFR0+IM1                    ; write MSB out
        ply
        rts 
		
	.send 	code


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

