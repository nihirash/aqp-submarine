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
    call input_address

    include "basic.inc"
    include "regs.inc"
    include "aqplus.asm"
    include "console/index.asm"
    include "history.asm"
    include "page/navigate.asm"
    include "page/gopher-page.asm"
    include "page/url.asm"
    include "transport.asm"
    include "input.asm"
    include "esp.inc"



homepage:
    db "i",9,"/",9,"nihirash.net",9,"70",13    

page_buffer: