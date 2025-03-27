    org $38E1
    include "regs.inc"

    ; Header and BASIC stub
    defb    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
    defb    "AQPLUS"
    defb    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
    defb    $0E,$39,$0A,$00,$DA,"14608",':',$80,$00,$00,$00
    push hl
    call main
    pop hl
    ret
    
    ds 32
stack:

main:
    di
    ld sp, stack

    call hw_init
    call console_init
    call esp_init

    call draw_ui

    ld hl, test2
    ld de, request
    call load_buffer

    call render_page
    jr $

fp:
    db 0

    include "basic.inc"
    include "aqplus.asm"
    include "console/index.asm"
    include "page/gopher-page.asm"
    include "transport.asm"
    include "esp.inc"

request:
    db "/",0

test2:
    db "tcp://i-logout.cz:70", 0

page_buffer: