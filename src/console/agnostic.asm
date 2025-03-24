; HL pointer to gopher-line
print_gopher:
    ld b, 70
; Data type
    inc hl
.loop:
    ld a, (hl)
    and a
    jr z, .end
    
    cp 9        ; Tabulation
    jr z, .look_for_end

    cp 13       
    jr z, .look_for_end

    cp 10 
    jr z, .look_for_end

    push hl
    push bc
    call console_putc
    pop bc
    pop hl

    inc hl
    djnz .loop
.look_for_end:
    ld a, (hl)
    and a
    jp z, console_newline

    cp 13
    jr nz, .continue
    inc hl
    ld a, (hl)
    cp 10
    inc hl
    jp z, console_newline
    dec hl
.end:
    jp console_newline
.continue:
    inc hl
    jr .look_for_end