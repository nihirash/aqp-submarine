PER_PAGE    equ 23

INFO_COLOR     equ $70
DOWNLOAD_COLOR equ $20
PAGE_COLOR     equ $50
PLAINTEXT_COL  equ $30
SEARCH_COL     equ $90
OTHER_COL      equ $F0


find_page_offset:
    ld hl, page_buffer

    ld de, (page_offset)
.loop:
    ld a, d
    or e
    ret z
.find_eol:
    ld a, (hl)
    or a 
    jr z, .not_found ; End of buffer possibly?!

    inc hl

    cp 13
    jr z, .next_line

    cp 10
    jr z, .next_line
        

    jr .find_eol
.next_line:
    dec de

    ld a, (hl)
    cp 10
    jr nz, .loop    
    inc hl
    
    jr .loop
.not_found:
    ld hl, 0
    ret

render_page:
    call draw_ui
    call find_page_offset
    ld (page_addr), hl
render_page_skip_loopup:
    ld de, $0203
    call console_gotoxy

    ld hl, (page_addr)
    
    ld a, l
    or h
    ret z

    xor a
    ld (cur_line), a

    ld b, PER_PAGE
.loop:
    push bc
    ld a, (hl)
    and a
    jr z, .end_of_page
    call get_row_color
    ld c, 0
    ex af, af'
    
    ld a, (cur_line)
    ld b, a
    ld a, (cursor_position)
    cp b
    jr nz, .no_cursor

    ld (cursor_ptr), hl
    ld c, 11
.no_cursor:
    ex af, af'
    or c
    call coloroize_line

    call print_gopher
    pop bc
    ex de, hl
    ld hl, cur_line
    inc (hl)
    ex de, hl
    djnz .loop

    ld a, $ff
    ld (cur_line), a
    ret
.end_of_page:
    pop bc
    ld a, PER_PAGE
    sub b
    ld (cur_line), a
    ret

get_row_color:
    ld a, (hl)
    cp 'i'
    jr z, .info
    cp '9'
    jr z, .down
    cp '1'
    jr z, .page
    cp '0'
    jr z, .text
    cp '7'
    jr z, .input

    ld a, OTHER_COL
    ret
.info:
    ld a, INFO_COLOR
    ret
.down:
    ld a, DOWNLOAD_COLOR
    ret
.page:
    ld a, PAGE_COLOR
    ret
.text:
    ld a, PLAINTEXT_COL
    ret
.input:
    ld a, SEARCH_COL
    ret

coloroize_line:
    push hl
    ld hl, (console_pointer)
    
    dec hl
    dec hl
    dec hl

    call console_set_line_precalc
    pop hl
    ret

gopher_page_loop:
    call inkey

    cp KEY_DN
    jr z, gopher_cur_down

    cp KEY_UP
    jr z, gopher_cur_up

    cp KEY_RET
    jr z, gopher_navigate

    cp 'u'
    jp z, input_address

    jr gopher_page_loop

gopher_cur_down:
    ld a, (cursor_position)
    inc a

    cp PER_PAGE
    jr z, .scroll
    
    ld hl, cur_line
    cp (hl)
    jr z, .done
    
    ld (cursor_position), a
.done
    call render_page_skip_loopup

    jr gopher_page_loop
.scroll
    ld hl, (page_offset)
    ld bc, PER_PAGE
    add hl, bc
    ld (page_offset), hl

    call find_page_offset
    ld a, l
    or h 
    jr z, rollback_scroll
    
    ld a, (hl)
    or a
    jr z, rollback_scroll

    xor a
    ld (cursor_position), a

offset_changed:
    call render_page
    jr gopher_page_loop
rollback_scroll:
    ld hl, (page_offset)
    ld bc, PER_PAGE
    or a
    sbc hl, bc
    ld (page_offset), hl

    jr offset_changed

gopher_cur_up:
    ld a, (cursor_position)
    or a
    jr z, .scroll
    dec a
    ld (cursor_position), a
    call render_page_skip_loopup
    jr gopher_page_loop
.scroll:
    ld hl, (page_offset)
    
    ld a, l
    or h
    jr z, gopher_page_loop

    ld bc, PER_PAGE
    or a
    sbc hl, bc
    ld (page_offset), hl
    ld a, PER_PAGE - 1
    ld (cursor_position), a
    jr offset_changed

gopher_navigate:
    ld hl, (cursor_ptr)
    call get_row_color

    cp PAGE_COLOR
    jr z, gopher_page_navigate

    jp offset_changed
gopher_page_navigate:
    call extract_row
    jr z, offset_changed
gopher_page_make_request:
    ld hl, path
    ld de, req_buffer
    call load_buffer
    call init_vars
    call render_page
    jp gopher_page_loop

extract_row:
    call is_valid_row
    jr c, .page_copy
    xor a
    ret
.page_copy:
    ld hl, (host_ptr)
    ld de, host_buffer
.copy_host:
    ld a, (hl)
    cp 9
    jr z, .copy_port
    ldi
    jr .copy_host
.copy_port:
    ld a, ':'
    ld (de), a
    inc de
    ld hl, (port_ptr)
.copy_port_loop:
    ld a, (hl)
    
    and a
    jr z, .copy_req

    cp 9
    jr z, .copy_req
    
    cp 13
    jr z, .copy_req

    cp 10
    jr z, .copy_req
    
    ldi
    jr .copy_port_loop
.copy_req:
    xor a
    ld (de), a

    ld hl, (addr_ptr)
    ld de, req_buffer
.req_copy_loop:
    ld a, (hl)
    
    cp 9
    jr z, .done_copy

    ldi
    jr .req_copy_loop
.done_copy
    xor a
    ld (de), a
    or $ff
    ret

is_valid_row:

    ld a, (hl)
    and a
    jr z, .not
    
    inc hl

    cp 13 
    jr z, .not

    cp 9
    ld (addr_ptr), hl
    jr z, .path
    jr is_valid_row
.path:
    ld a, (hl)
    and a
    jr z, .not
    inc hl

    ld iy, 3
    cp 13
    jr z, .not
    cp 9 
    jr nz, .path
    ld (host_ptr), hl
.host:
    ld a, (hl)
    and a
    jr z, .not
    inc hl
    cp 13 
    jr z, .not
    cp 9
    jr z, .is
    jr .host
.is:
    ld (port_ptr), hl
    scf
    ret
.not:
    xor a
    ret

init_vars:
    xor a
    sbc hl, hl
    ld (cursor_position), a
    ld (page_offset), hl
    ld (cur_line), a
    ret

input_address:
    ld hl, page_addr_prompt
    call clean_line_editor
    ld hl, line_buffer
    call parse_url
    jp gopher_page_make_request
page_addr_prompt:
    db "Enter gopher address:", 0

host_ptr:
    dw 0
port_ptr:
    dw 0
addr_ptr:
    dw 0

cursor_position:
    db 0
page_offset:
    dw 0
cur_line:
    db 0

page_addr:
    dw 0
cursor_ptr:
    dw 0

path:
    db "tcp://"
host_buffer:
    ds 70

req_buffer:
    ds 255