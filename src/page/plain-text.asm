render_text_page:
    call draw_ui
    call find_page_offset
    ld (page_addr), hl

    ld de, $0200
    call console_gotoxy

    ld hl, (page_addr)
    
    ld a, l
    or h
    ret z

    xor a
    ld (cur_line), a

    ld b, PER_PAGE
.loop:
    ld a, (hl)
    and a
    ret z

    push bc
    call print_line_pt
    call console_newline
    pop bc
    djnz .loop

    ld a, 1
    ld (cur_line), a
    ret

plain_text_loop:
    call inkey

    cp 'u'
    jp z, input_address

    cp 'U'
    jp z, input_address

    cp 'b'
    jp z, history_back

    cp 'B'
    jp z, history_back

    cp KEY_BACK
    jp z, history_back

    cp KEY_DN
    jr z, text_scroll_dn

    cp KEY_UP
    jr z, text_scroll_up

    cp 'h'
    jp z, home

    cp 'H'
    jp z, home

    jr plain_text_loop

text_scroll_dn:
    ld a, (cur_line)
    or a
    jr z, plain_text_loop

    ld de, PER_PAGE
    ld hl, (page_offset)
    add hl, de
    ld (page_offset), hl

    call render_text_page
    jr plain_text_loop

text_scroll_up:
    ld hl, (page_offset)
    ld a, l
    or h
    jr z, plain_text_loop

    ld de, PER_PAGE
    sbc hl, de
    ld (page_offset), hl

    call render_text_page
    jr plain_text_loop