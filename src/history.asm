HISTORY_STARTS equ $c000
HISTORY_SECOND equ $c100
HISTORY_ACTIVE equ $ff00
HISTORY_END    equ $ffff

history_init:
    di
    ld a, HISTORY_RAM_PAGE
    out (IO_BANK3), a

    ld hl, $c000
    ld de, $c001
    ld bc, $3fff
    xor a
    ld (hl), a
    ldir

    ld a, BASE_RAM_PAGE + 3
    out (IO_BANK3), a
    ei
    ret

history_push:
    ld a, (history_depth)
    cp 64
    ret z
    inc a
    ld (history_depth), a

    di
    ld a, HISTORY_RAM_PAGE
    out (IO_BANK3), a

    ld hl, HISTORY_SECOND
    ld de, HISTORY_STARTS
    ld bc, $3F00
    ldir
    
    ld hl, host_buffer
    ld de, HISTORY_ACTIVE
    ld bc, $ff
    ldir

    ld a, BASE_RAM_PAGE + 3
    out (IO_BANK3), a
    ei
    or a
    ret

history_back:
    ld a, (history_depth)
    and a 
    jp z, offset_changed

    cp $ff
    jp z, offset_changed

    dec a
    ld (history_depth), a
    
    di
    ld a, HISTORY_RAM_PAGE
    out (IO_BANK3), a

    ld hl, HISTORY_ACTIVE - 1
    ld de, HISTORY_END 
    ld bc, $3f00
    lddr

    ld hl, HISTORY_ACTIVE
    ld de, host_buffer
    ld bc, $ff
    ldir

    ld a, BASE_RAM_PAGE + 3
    out (IO_BANK3), a
    ei
    or a
    jp gopher_page_make_request

history_depth:
    db $ff

path:
    db "tcp://"
host_buffer:
    ds HOST_SIZE
req_buffer:
    ds REQUEST_BUFFER