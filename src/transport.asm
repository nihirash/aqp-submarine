;; HL - host
;; DE - request
load_buffer:
    call send_request

    ld hl, page_buffer
    ld (page_ptr), hl
.down:
    ld a, (transport_socket)
    ld hl, $ffff
    ld de, (page_ptr)
    or a
    sbc hl, de
    ex de, hl
    call esp_read
    jp m, .down_done

    ld hl, (page_ptr)
    add hl, de
    ld (page_ptr), hl
    jr .down
.down_done:
    ld hl, (page_ptr)
    inc hl
    xor a
    ld (hl), a

    ld a, (transport_socket)
    call esp_close 
    ret

network_error:
    ld hl, .header
    call show_box
    ld hl, .msg
    call print_line_t
    call inkey
    pop hl
    pop hl
    jp history_back
.header:
    db "ERROR!", 0
.msg:
    db "Cannot establish network connection with host!", 0

send_request:
    push de
    ld c, FO_RDWR
    call esp_open
    pop hl
    or a
    jp m, network_error
    ld (transport_socket), a

    ld de, 0
    push hl
.calc:
    ld a, (hl)
    and a
    jr z, .done
    inc de
    inc hl
    jr .calc
.done:
    pop hl

    ld a, (transport_socket)
    ld c, a
    call esp_write
    
    ld a, (transport_socket)
    ld c, a
    ld hl, crlf
    ld de, 3
    call esp_write
    ret

crlf:
    db 13, 10, 0

transport_socket:
    db 0

page_ptr:
    dw 0