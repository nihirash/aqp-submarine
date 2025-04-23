track_play:
    ld hl, path
    ld de, req_buffer
    call load_buffer

    ld hl, .header
    call show_box

    ld hl, .msg
    call console_printz 

    ld hl, page_buffer
    call INIT
    xor a 
    ld (_keyval), a
.loop:
    call const
    and a
    jr nz, .stop

    call PLAY
    halt
    jr .loop
.stop:
    call MUTE
    jp history_back
.header:
    db "Track playing...", 0
.msg:
    db "Press any key for stopping playback!", 0