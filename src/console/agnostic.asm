draw_ui:
    call console_clear
    ld hl, banner
    call console_printz
    
    ld a, $47
    ld l, 0
    call console_set_line

    ld a, $3f
    ld l, 1
    call console_set_line

    ld de, $0203
    jp console_gotoxy
    
banner:
    db "Submarine - The Deep Internet Browser for Aquarius+ (c) 2025 Aleksandr Sharikhin"
    db "URL: "
    db 0

; HL pointer to gopher-line
print_gopher:
    ld b, 70
; Data type
    inc hl
.loop:
    ld a, (hl)
    and a
    jp z, console_newline
    
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
    
    inc hl

    cp 13
    jr z, .check

    cp 10
    jp z, console_newline

    inc hl
    jr .look_for_end
.check:
    ld a, (hl)
    cp 10
    jp nz, console_newline
    inc hl
    jp console_newline