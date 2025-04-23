clean_buffer:
    ; Clean up buffer
    ld hl, page_buffer
    ld de, page_buffer + 1
    ld bc, $ffff - page_buffer - 1
    xor a 
    ld (hl), a
    ldir
    ret

home:
    call clean_buffer
    
    ld hl, homepage
    ld de, page_buffer
    ld bc, page_buffer - homepage
    ldir

    call init_vars
    call render_page
    jp gopher_page_loop

;; HL - host
;; DE - request
load_buffer:
    call send_request
    call clean_buffer

    ld hl, msg_wait
    call show_box
    ld hl, .msg_process
    call console_printz

    ld hl, page_buffer
    ld (page_ptr), hl
.down:
    ld hl, $ffff
    ld de, (page_ptr)
    or a
    sbc hl, de

    ; Memory ends
    ld a, l
    or h
    jp z, .memory_ends

    ld a, (transport_socket)

    ex de, hl
    call esp_read
    jp m, .down_done

    ld hl, (page_ptr)
    add hl, de
    ld (page_ptr), hl
    jr .down
.down_done:
    ld a, (transport_socket)
    call esp_close 
    ret
.memory_ends:
    ld hl, error_header
    call show_box
    ld hl, .msg
    call print_line_t
    call inkey

    jr .down_done
.msg:
    db "Page buffer overflow! Possibly page will be truncated!", 0
.msg_process:
    db "Fetching from network!", 0
msg_wait:
    db "Please wait!", 0

network_error:
    ld hl, error_header
    call show_box
    ld hl, .msg
    call print_line_t
    call inkey
    pop hl
    pop hl
    jp history_back
.msg:
    db "Cannot establish network connection with host!", 0

download:
    ld hl, path
    ld de, req_buffer
    call send_request

    call line_editor

    ld c, FO_WRONLY + FO_CREATE
    ld hl, line_buffer
    call esp_open
    
    or a
    jp m, .error_open
    ld (.fp), a

    ld hl, msg_wait
    call show_box
    ld hl, load_buffer.msg_process
    call console_printz

.down:
    ld a, (transport_socket)
    ld hl, page_buffer
    ld de, $200
    call esp_read
    jp m, .done

    ld a, (.fp)
    ld hl, page_buffer
    call esp_write
    jr .down
.done:
    call esp_closeall
    jp history_back
.fp:
    db 0
.error_open:
    call esp_closeall
    ld hl, error_header
    call show_box
    ld hl, .create_err
    call console_printz
    xor a
    ld (_keyval), a
    call inkey

    jp history_back
.create_err:
    db "Cannot create output file!", 0

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