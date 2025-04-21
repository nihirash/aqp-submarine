;; HL - URL
parse_url:
    ld de, host_buffer
    ld b, 64
.domain_loop:
    ld a, (hl)
    ld (de), a
    and a
    jr z, .fill_defaults
    
    inc hl

    cp ':'
    jr z, .copy_port

    cp '/'
    jr z, .fill_default_port
    inc de

    dec b
    jr z, .on_error
    jr .domain_loop
.copy_port:
    inc de
.copy_port_loop:
    ld a, (hl)
    ld (de), a
    and a
    jr z, .fill_default_path
        
    inc hl

    cp '/'
    jr z, .copy_path

    inc de
    jr .copy_port_loop
.fill_default_port:
    ld a, ':'
    ld (de), a
    inc de
    push hl
    ld hl, .default_port
    ldi
    ldi
    ldi
    pop hl
.copy_path:
    ld de, req_buffer
.copy_path_loop:
    ld a, (hl)
    ld (de), a
    and a
    ret z

    inc hl
    inc de
    jr .copy_path_loop
.fill_defaults:
    ld a, ':'
    ld (de), a
    inc de
    ld hl, .default_port
    ldi
    ldi
    ldi
.fill_default_path:
    ld de, req_buffer
    ld hl, .default_path
    ldi
    ldi
    ret


.on_error:
    halt


.default_port:
    db "70",0
.default_path:
    db "/", 0