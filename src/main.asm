    org $38E1
;;
;; This part cosplays basic program
;;

    ; Header and BASIC stub
    defb    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
    defb    "AQPLUS"
    defb    $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
    defb    $0E,$39,$0A,$00,$DA,"14608",':',$80,$00,$00,$00
    
    di
    ld a, $c
    out (IO_SYSCTRL), a
    jp start
;; For using all 64K as RAM moving actual application code into $4000 address
    ds $4000 - $
start:
    ld a, BASE_RAM_PAGE
    out (IO_BANK0), a
    
    ld hl, app_image_start
    ld de, 0
    ld bc, size
    ldir
    jp main

app_image_start:
    DISP $0
; RST 0
    jr $
    ds $38 - $
; RST $38
    jp int_handler
    ds 16
main:
;; Initializing stack, interrupts and basic memory map
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

;; ******************************************
;; * Useful code of application starts here *
;; ******************************************
    call console_clear
    call history_init

    jp home

    include "config.asm"
    include "../include/basic.inc"
    include "../include/regs.inc"
    include "../include/esp.inc"
    include "console/index.asm"
    include "history.asm"
    include "page/navigate.asm"
    include "page/gopher-page.asm"
    include "page/plain-text.asm"
    include "page/track-player.asm"
    include "page/url.asm"
    include "binary_processors/pt3.asm"
    include "transport.asm"
    include "input.asm"

int_handler:
    push af
    ld a, $ff
    out (IO_IRQSTAT), a
    pop af
    ei
    reti


homepage:
    incbin "../assets/home.gph"
size:
page_buffer:
    ENT
