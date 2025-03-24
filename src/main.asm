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
    
    ld hl, banner
    call console_printz
    

    ld a, $47
    ld l, 0
    call console_set_line
    ld de, $0303
    call console_gotoxy


    call esp_init

    ld c, FO_RDWR
    ld hl, test2
    call esp_open

    ld (fp), a

    ld hl, request
    ld de, 3
    call esp_write

down:
    ld a, (fp)
    ld hl, $ffff
    ld de, (page_ptr)
    or a
    sbc hl, de
    ex de, hl
    call esp_read
    jp m, down_done

    ld hl, (page_ptr)
    add hl, de
    ld (page_ptr), hl
    jr down

down_done:
    ld a, (fp)
    call esp_close


    ld hl, page_buffer
    ld b, 20
.loop:
    push bc
    call print_gopher
    pop bc
    djnz .loop

    di
    halt
    jr $

fp:
    db 0

banner:
    db "Submarine - The Deep Internet Browser for Aquarius+ (c) 2025 Aleksandr Sharikhin", 0



    include "basic.inc"
    include "aqplus.asm"
    include "console/index.asm"
    include "esp.inc"

request:
    db "/",13,10,0

test2:
    db "tcp://sdf.org:70", 0

page_ptr:
    dw page_buffer

page_buffer:
    incbin "example.gph"