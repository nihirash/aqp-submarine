;; ESP IO driver
esp_init:

esp_closeall:
    ld a, ESPCMD_CLOSEALL
    call esp_cmd
    call esp_get_byte
    ret

; Params:
;  C - filemode
;  HL - Path
; Returns:
;  A - file descriptor(or error if negative)
esp_open:
    ld a, ESPCMD_OPEN
    call esp_cmd

    ld a, c
    call esp_send_byte
    call esp_send_string
    jp esp_get_byte

; A - file descriptor
; HL - buffer
; DE - count 
esp_write:
    ld c, a 
    ld a, ESPCMD_WRITE
    call esp_cmd

    ld a, c
    call esp_send_byte

    ld a, e
    call esp_send_byte
    ld a, d
    call esp_send_byte
.loop:
    ld a, d
    or e
    jr z, .done

    ld a, (hl)
    call esp_send_byte
    inc hl
    dec de
    jr .loop
.done:
    call esp_get_byte
    or a
; On error
    ret m   

; Actually written
    call esp_get_byte
    ld c, a
    call esp_get_byte
    ld b, a

    ret

; Params:
;  A - file descriptor
;  HL - buffer
;  DE - count 
; Returns:
;   A - negative in case of error
;   DE - actually read bytes
esp_read:
    ld c, a
    ld a, ESPCMD_READ
    call esp_cmd
    ; File descriptor
    ld a, c
    call esp_send_byte

    ; Sending excepted size
    ld a, e
    call esp_send_byte
    ld a, d
    call esp_send_byte
    ; Getting result
    call esp_get_byte
    or a
    ; On error
    ret m

    call esp_get_byte
    ld e, a
    call esp_get_byte
    ld d, a
    push de
.loop:
    ld a, d
    or e
    jr z, .done
    
    call esp_get_byte
    ld (hl), a
    inc hl
    dec de
    jr .loop
.done:
    pop de
    ret

; A - file descriptor
esp_close:
    ld c, a 
    ld a, ESPCMD_CLOSE
    call esp_cmd
    ld a, c
    call esp_send_byte
    jp esp_get_byte

;-----------------------------------------------------------------------------
; Issue command to ESP
;-----------------------------------------------------------------------------
esp_cmd:
    push    af

    ; Drain RX FIFO
.drain:
    in      a, (IO_ESPCTRL)
    and     a, 1
    jr      z, .done
    in      a, (IO_ESPDATA)
    jr      .drain
.done:

    ; Issue start of command
    ld      a, $80
    out     (IO_ESPCTRL), a

    ; Issue command
    pop     af
    jp      esp_send_byte

;-----------------------------------------------------------------------------
; Wait for data from ESP
;-----------------------------------------------------------------------------
esp_get_byte:
.wait:
    in      a, (IO_ESPCTRL)
    and     a, 1
    jr      z, .wait
    in      a, (IO_ESPDATA)
    ret

;-----------------------------------------------------------------------------
; Write data to ESP
;-----------------------------------------------------------------------------
esp_send_byte:
    push    af

.wait:
    in      a, (IO_ESPCTRL)
    and     a, 2
    jr      nz, .wait

    pop     af
    out     (IO_ESPDATA), a
    ret

esp_send_string:
    ld a, (hl)
    call esp_send_byte
    and a 
    ret z
    inc hl
    jr esp_send_string