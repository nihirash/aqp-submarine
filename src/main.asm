    org $38E1
    include "regs.inc"

    ; Header and BASIC stub
    defb    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
    defb    "AQPLUS"
    defb    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
    defb    $0E,$39,$0A,$00,$DA,"14608",':',$80,$00,$00,$00
    
    di
    ld a, $c
    out (IO_SYSCTRL), a
    jp start

    org $4000
start:
    ld a, BASE_RAM_PAGE
    out (IO_BANK0), a
    
    ld hl, app_image_start
    ld de, 0
    ld bc, size
    ldir
    jp main

app_image_start:
    phase $0
; RST 0
    jr $
    ds $38 - $
; RST $38
    jp int_handler
    ds 8
main:
    ld sp, stack
    ld a, 1
    out (IO_IRQMASK), a
    
    ld a, BASE_RAM_PAGE + 1
    out (IO_BANK1), a
    inc a
    out (IO_BANK2), a
    inc a
    out (IO_BANK3), a
    ei
    halt
    ;; All code before doesn't required after start
stack:

    call console_init
    call history_init

    call draw_ui
    jp input_address

    include "config.asm"
    include "basic.inc"
    include "regs.inc"
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

int_handler:
    push af
    ld a, $ff
    out (IO_IRQSTAT), a
    pop af
    ei
    reti

size:
page_buffer:
    dephase