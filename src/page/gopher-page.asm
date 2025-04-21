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
    jp z, gopher_navigate

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
    ds HOST_SIZE
req_buffer:
    ds REQUEST_BUFFER