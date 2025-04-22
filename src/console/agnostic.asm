;; Initing screen with basic UI 
draw_ui:
    call console_clear
    ld hl, banner
    call console_printz

    ld hl, path
    call console_printz

    ld hl, req_buffer
    call print_line_t

    ld a, $47
    ld l, 0
    call console_set_line_color

    ld a, $3f
    ld l, 1
    call console_set_line_color
    ret
    
banner:
    db "Submarine - The Deep Internet Browser for Aquarius+ (c) 2025 Aleksandr Sharikhin", 13
    db "URL: "
    db 0

;; Print line that ends with zero-byte or with tabulation
print_line_t:
    ld b, 70
.loop:
    ld a, (hl)
    and a
    ret z

    cp 9
    ret z

    push hl
    push bc
    call console_putc
    pop bc
    pop hl
    inc hl
    djnz .loop
    ret

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

;; Show box for user input and/or message box 
show_box:
    push hl
    ld l, 10
    ld a, ' '
    call console_fill_line
    
    ld l, 11
    ld a, ' '
    call console_fill_line

    ld l, 12
    call console_fill_line

    ld l, 10
    ld a, $74
    call console_set_line_color
    ld l, 11
    ld a, $75
    call console_set_line_color
    ld l, 12
    ld a, $74
    call console_set_line_color
    
    ld de, $0a05
    call console_gotoxy
    pop hl
    call print_line_t

    ld de, $0b02
    call console_gotoxy
    ret

error_header:
    db "ERROR!", 0