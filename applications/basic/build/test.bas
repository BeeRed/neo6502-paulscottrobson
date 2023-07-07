for i = 0 to 1:p = &6000:opt 3
[
	ldx #10
.loop1:lda #42:jsr &FFF7
dex:bne loop1:rts
]:next