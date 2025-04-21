gopher_navigate:
    ld hl, (cursor_ptr)
    call get_row_color

    cp PAGE_COLOR
    jp z, gopher_page_navigate

    cp SEARCH_COL
    jr z, gopher_search_navigate

    jp offset_changed
gopher_search_navigate:
    call extract_row
    jp z, offset_changed
    
    call clean_line_editor

    ld hl, req_buffer
    ld bc, $ff
    xor a
    cpir
    dec hl
    ld a, 9
    ld (hl), a
    inc hl

    ld de, line_buffer
    ex de, hl
.copy:
    ld a, (hl)
    ld (de), a
    and a
    jr z, gopher_page_make_request
    inc hl
    inc de
    jr .copy

.msg:
    db "User input: ", 0

gopher_page_navigate:
    call extract_row
    jp z, offset_changed
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