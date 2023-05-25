static const char *_mnemonics[] = { "brk","ora (@1,x)","byte 02","byte 03","tsb @1","ora @1","asl @1","rmb0 @1","php","ora #@1","asl a","byte 0b","tsb @2","ora @2","asl @2","bbr0 @1,@r","bpl @r","ora (@1),y","ora (@1)","byte 13","trb @1","ora @1,x","asl @1,x","rmb1 @1","clc","ora @2,y","inc","byte 1b","trb @2","ora @2,x","asl @2,x","bbr1 @1,@r","jsr @2","and (@1,x)","byte 22","byte 23","bit @1","and @1","rol @1","rmb2 @1","plp","and #@1","rol a","byte 2b","bit @2","and @2","rol @2","bbr2 @1,@r","bmi @r","and (@1),y","and (@1)","byte 33","bit @1,x","and @1,x","rol @1,x","rmb3 @1","sec","and @2,y","dec","byte 3b","bit @2,x","and @2,x","rol @2,x","bbr3 @1,@r","rti","eor (@1,x)","byte 42","byte 43","byte 44","eor @1","lsr @1","rmb4 @1","pha","eor #@1","lsr a","byte 4b","jmp @2","eor @2","lsr @2","bbr4 @1,@r","bvc @r","eor (@1),y","eor (@1)","byte 53","byte 54","eor @1,x","lsr @1,x","rmb5 @1","cli","eor @2,y","phy","byte 5b","byte 5c","eor @2,x","lsr @2,x","bbr5 @1,@r","rts","adc (@1,x)","byte 62","byte 63","stz @1","adc @1","ror @1","rmb6 @1","pla","adc #@1","ror a","byte 6b","jmp (@2)","adc @2","ror @2","bbr6 @1,@r","bvs @r","adc (@1),y","adc (@1)","byte 73","stz @1,x","adc @1,x","ror @1,x","rmb7 @1","sei","adc @2,y","ply","byte 7b","jmp (@2,x)","adc @2,x","ror @2,x","bbr7 @1,@r","bra @r","sta (@1,x)","byte 82","byte 83","sty @1","sta @1","stx @1","smb0 @1","dey","bit #@1","txa","byte 8b","sty @2","sta @2","stx @2","bbs0 @1,@r","bcc @r","sta (@1),y","sta (@1)","byte 93","sty @1,x","sta @1,x","stx @1,y","smb1 @1","tya","sta @2,y","txs","byte 9b","stz @2","sta @2,x","stz @2,x","bbs1 @1,@r","ldy #@1","lda (@1,x)","ldx #@1","byte a3","ldy @1","lda @1","ldx @1","smb2 @1","tay","lda #@1","tax","byte ab","ldy @2","lda @2","ldx @2","bbs2 @1,@r","bcs @r","lda (@1),y","lda (@1)","byte b3","ldy @1,x","lda @1,x","ldx @1,y","smb3 @1","clv","lda @2,y","tsx","byte bb","ldy @2,x","lda @2,x","ldx @2,y","bbs3 @1,@r","cpy #@1","cmp (@1,x)","byte c2","byte c3","cpy @1","cmp @1","dec @1","smb4 @1","iny","cmp #@1","dex","byte cb","cpy @2","cmp @2","dec @2","bbs4 @1,@r","bne @r","cmp (@1),y","cmp (@1)","byte d3","byte d4","cmp @1,x","dec @1,x","smb5 @1","cld","cmp @2,y","phx","byte db","byte dc","cmp @2,x","dec @2,x","bbs5 @1,@r","cpx #@1","sbc (@1,x)","byte e2","byte e3","cpx @1","sbc @1","inc @1","smb6 @1","inx","sbc #@1","nop","byte eb","cpx @2","sbc @2","inc @2","bbs6 @1,@r","beq @r","sbc (@1),y","sbc (@1)","byte f3","byte f4","sbc @1,x","inc @1,x","smb7 @1","sed","sbc @2,y","plx","byte fb","dbg @2","sbc @2,x","inc @2,x","bbs7 @1,@r"};