;; Console routines for Aquarius+ 80 column text mode
;; They're really fast but primitive in same time

CHARS_MODE        equ     VCTRL_TEXT_EN | VCTRL_REMAP | VCTRL_TEXT_HIRES
ATTRS_MODE        equ     VCTRL_TEXT_EN | VCTRL_REMAP | VCTRL_TEXT_HIRES | VCTRL_TEXT_PAGE
TEXT_BASE         equ     $3000

SET_RAM macro
        push af
        ld a, BASE_RAM_PAGE
        out (IO_BANK0), a
        pop af
        endm

SET_VRAM macro  
        push af
        ld a, BASE_RAM_PAGE + BANK_OVERLAY
        out (IO_BANK0), a
        pop af
        endm

console_init:
    call console_clear
    ret

;; Clear entire screen
console_clear:
    SET_VRAM

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
    xor a
    ld (console_position), a

    SET_RAM
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
console_set_line_color:
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
    SET_VRAM
    
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

    SET_RAM
    ret

; A - attribute
; L - line
console_fill_line:
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

    push hl
    pop de
    inc de

    ld bc, 79
    SET_VRAM
    ld (hl), a
    ldir
    SET_RAM
    ret

console_putc:
    cp 13
    jr z, console_newline
    SET_VRAM

    ld hl, (console_pointer)
    ld (hl), a
    inc hl
    
    SET_RAM

    ld a, (console_position)
    inc a
    cp 80
    ret z
    ld (console_position), a
    ld (console_pointer), hl
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