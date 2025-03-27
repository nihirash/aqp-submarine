PER_PAGE    equ 23

INFO_COLOR     equ $70
DOWNLOAD_COLOR equ $20
PAGE_COLOR     equ $50
PLAINTEXT_COL  equ $30
SEARCH_COL     equ $90
OTHER_COL      equ $0F

cursor_position:
    db 0
page_offset:
    dw 0
cur_line:
    db 0

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

    
    cp 13
    jr z, .next_line

    cp 10
    jr z, .next_line
        
    inc hl

    jr .find_eol
.next_line:
    dec de

    ld a, (hl)
    cp 10
    jr nz, .loop    
    inc hl
    
    jr .loop
.not_found:
    or a
    sbc hl, hl
    ret

render_page:
    call find_page_offset
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
    ret
.end_of_page:
    pop bc
    ld a, PER_PAGE
    sub b
    halt
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