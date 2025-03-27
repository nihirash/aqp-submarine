;; Console routines for Aquarius+ 80 column text mode
;; They're really fast but primitive in same time

CHARS_MODE        equ     VCTRL_TEXT_EN | VCTRL_REMAP | VCTRL_TEXT_HIRES
ATTRS_MODE        equ     VCTRL_TEXT_EN | VCTRL_REMAP | VCTRL_TEXT_HIRES | VCTRL_TEXT_PAGE
TEXT_BASE         equ     $3000

console_init:
    ld a, CHARS_MODE
    out (IO_VCTRL), a
    call console_clear

    ret

;; Clear entire screen
console_clear:
    ld a, CHARS_MODE
    out (IO_VCTRL), a

    ld a, ' '
    call console_fill

    ld a, ATTRS_MODE
    out (IO_VCTRL), a

    ld a, $70
    call console_fill

    ld a, CHARS_MODE
    out (IO_VCTRL), a
    
    ld hl, TEXT_BASE
    ld (console_pointer), hl

    ret

;; Fill all overlay with specified byte
console_fill:
    ld hl, TEXT_BASE
    ld de, TEXT_BASE + 1
    ld bc, $7ff
    ld (hl), a
    ldir
    ret

;; Sets coordinates on screen
console_gotoxy:
    ld a, e
    ld (console_position), a

    or a 
    sbc hl, hl
    ld l, d
    ld d, 0
    
    add  hl, hl ; * 2
    add  hl, hl ; * 4
    add  hl, hl ; * 8
    add  hl, hl ; * 16
    push hl
    add  hl, hl ; * 32
    add  hl, hl ; * 64
    pop bc
    add  hl, bc ; * 80
    ld bc, TEXT_BASE
    add  hl, bc

    add hl, de
    ld (console_pointer), hl
    ret

; A - attribute
; L - line
console_set_line:
    ld h, 0
    add  hl, hl ; * 2
    add  hl, hl ; * 4
    add  hl, hl ; * 8
    add  hl, hl ; * 16
    push hl
    add  hl, hl ; * 32
    add  hl, hl ; * 64
    pop bc
    add  hl, bc ; * 80
    ld bc, TEXT_BASE
    add  hl, bc
console_set_line_precalc:    
    ex af, af'
    ld a, ATTRS_MODE
    out (IO_VCTRL), a
    ex af, af'

    push hl
    pop de
    inc de

    ld bc, 79
    ld (hl), a
    ldir

    ld a, CHARS_MODE
    out (IO_VCTRL), a

    ret

console_putc:
    ld hl, (console_pointer)
    ld (hl), a
    inc hl
    ld (console_pointer), hl

    ld a, (console_position)
    inc a
    cp 80
    ret z
    ld (console_position), a
    ret

console_printz:
    ld a, (hl)
    and a
    ret z
    push hl
    call console_putc
    pop hl
    inc hl
    jr console_printz

console_newline:
    ld a, 83
    ex af, af'
    ld a, (console_position)
    ld b, a
    ex af, af'
    sub b
    push hl
    
    ld d, 0
    ld e, a

    ld hl, (console_pointer)
    add hl, de
    ld (console_pointer), hl
    ld a, 3
    ld (console_position), a
    pop hl
    ret

console_position:
    db  0

console_pointer:
    dw TEXT_BASE