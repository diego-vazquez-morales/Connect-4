;-----------------------------------------------------------------------
;NOMBRE: LEER_SN
;DESCRIPCION: Rutina para leer la tecla 'S' o 'N' del teclado.
;ENTRADA: Ninguna.
;SALIDA: TECLA_SN - Contiene 'S' o 'N' dependiendo de la tecla presionada.
;-----------------------------------------------------------------------
TECLA_SN: db 0

LEER_SN:
    push af

ESPERAR_TECLA:
    ld a, $FD
    in a, ($FE)

    bit 1, a
    jr Z, TECLA_S

    ld a, $7F
    in a, ($FE)

    bit 3, a
    jr Z, TECLA_N

    jr ESPERAR_TECLA

TECLA_S:
    ld a,'S'
    ld (TECLA_SN),a

SOLTAR_S:
    ld a, $FD
    in a, ($FE)
    bit 1, a
    jr Z, SOLTAR_S
    pop af
    ret

TECLA_N:
    ld a,'N'
    ld (TECLA_SN), a

SOLTAR_N:
    ld a, $7F
    in a, ($FE)
    bit 3, a
    jr Z, SOLTAR_N
    pop af
    ret