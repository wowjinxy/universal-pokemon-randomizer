    .nds
    .thumb
    .open "pkmnwhite_ovl195", "pkmnwhite_ovl195_shedinja", 0x02203FC0

    NEW_INDEX_TO_SHEDINJA_SUBR_HOOK equ 0x0220575E
    OLD_INDEX_TO_SHEDINJA_SUBR_CONTINUED equ 0x02205786

    SET_POKEMON_SPECIES equ 0x020178F4
    SET_POKEMON_ATTRIBUTE equ 0x02017E5C

    ITCM_SRC_START equ 0x020A9EA0
    ITCM_DEST_START equ 0x01FF8000
    ITCM_OLD_SIZE equ 0x91C ; Originally 0x820, but this occurs after the 0xFC sized music patch

    NEW_INDEX_TO_SHEDINJA_SUBR equ ITCM_SRC_START + ITCM_OLD_SIZE
    NEW_INDEX_TO_SHEDINJA_SUBR_ITCM equ ITCM_DEST_START + ITCM_OLD_SIZE
    BL_OFFSET equ (NEW_INDEX_TO_SHEDINJA_SUBR) - (NEW_INDEX_TO_SHEDINJA_SUBR_ITCM)

    ; Hook that jumps to our new subroutine
    .org NEW_INDEX_TO_SHEDINJA_SUBR_HOOK
    mov     r0, r4
    bl      org() + 6
    b       OLD_INDEX_TO_SHEDINJA_SUBR_CONTINUED
    ldr     r2,=#(NEW_INDEX_TO_SHEDINJA_SUBR_ITCM + 1)
    bx      r2
    .pool

    .close

    .open "pkmnwhite.bin", "pkmnwhite_shedinja.bin", 0x02004000
    ; New subroutine. This is passed a pointer to the Pokemon data struct in r0; it is responsible
    ; for setting the species and first few attributes of the newly-generated Shedinja. Most of this
    ; code is copied from the original game, but it has been modified for easier modification of the
    ; species ID (it was generated via some silly left shift in the original code).
    .org NEW_INDEX_TO_SHEDINJA_SUBR
    .area 48

    push    { r4, lr }
    mov     r4, r0                             ; Save pointer to Pokemon data to r4 so it can be used again after calling functions
    ldr     r1,=#0x124                         ; Shedinja
    bl      BL_OFFSET + SET_POKEMON_SPECIES
    mov     r0, r4
    mov     r1, #0x98                          ; Attribute key for which ball the Pokemon is caught in
    mov     r2, #0x4                           ; Poke Ball
    bl      BL_OFFSET + SET_POKEMON_ATTRIBUTE
    mov     r0, r4
    mov     r1, #0x6                           ; Attribute key for the Pokemon's held item
    mov     r2, #0x0                           ; No item
    bl      BL_OFFSET + SET_POKEMON_ATTRIBUTE
    mov     r0, r4
    mov     r1, #0xB                           ; Attribute key for the Pokemon's mark
    mov     r2, #0x0                           ; No mark
    bl      BL_OFFSET + SET_POKEMON_ATTRIBUTE
    pop     { r4, pc }
    .pool
    .endarea

    .close