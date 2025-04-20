KEY_UP    EQU $8f
KEY_DN    EQU $9f
KEY_LF    EQU $9e
KEY_RT    EQU $8e
KEY_ESC   EQU $03
KEY_RET   EQU $0d

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

_keyval: 
    db 0