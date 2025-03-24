FIRST_RAM_PAGE = 40

hw_init:
;; Setting turbo mode

;; SYSCTL
;; 76543210
;;        ^  Disable regs (bit 0)
;;       ^   Disable AY   (bit 1)
;;      ^    Turbo mode   (bit 2)
;;     ^     Unlim. turbo (bit 3)
;; ..............................
;; ^         Reset system (bit 7)
    ld a, $c
    out (IO_SYSCTRL), a


    call set_page

    ret

set_page:
    and 30
    rrca
    add FIRST_RAM_PAGE
    out (IO_BANK2), a
    inc a
    out (IO_BANK3), a
    ret