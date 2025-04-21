KEY_UP    EQU $8f
KEY_DN    EQU $9f
KEY_LF    EQU $9e
KEY_RT    EQU $8e
KEY_ESC   EQU $03
KEY_RET   EQU $0d
KEY_BACK  EQU $08

CURSOR_CHARACTER EQU $88

const:
    ld a, (_keyval)
    or a
    jr nz, .has

    in a, (IO_KEYBUF)
    or a
    ret z

    ld (_keyval), a
.has
    ld a, $ff
    ret

inkey:
    call const
    jr z, inkey
    ld a, (_keyval)
    ld b, a
    xor a
    ld (_keyval), a
    ld a, b 
    ret

;; HL - prompt
clean_line_editor:
    xor a
    ld (line_buffer), a
line_editor:
    push hl
    ld l, 10
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
    call print_line
.render_str:
    ld l, 11
    ld a, ' '
    call console_fill_line

    ld de, $0b00
    call console_gotoxy

    ld a, $8e
    call console_putc

    ld hl, line_buffer
    call print_line
    ld (.ptr), hl
    ld a, CURSOR_CHARACTER
    call console_putc
    
    call inkey

    cp KEY_RET
    ret z

    cp KEY_BACK
    jr z, .backspace

    cp KEY_LF
    jr z, .backspace

    cp ' '
    jr c, .render_str

    cp '~' + 1
    jr nc, .render_str

    ld hl, (.ptr)
    ld (hl), a
    inc hl
    ld (hl), 0

    jr .render_str
.backspace:
    ld hl, (.ptr)
    dec hl
    xor a
    ld (hl), a
    jr .render_str
.ptr:
    dw 0

line_buffer: 
    ds 70

_keyval: 
    db 0