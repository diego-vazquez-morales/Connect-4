mensajeAdios: db "ADIOS!!!!", 0

pantalla_adios:
    call CLEARSCR

    ld ix, mensajeAdios 
    ld b, 12  ; fila donde quiero que empiece el texto
    ld c, 13  ; columna donde quiero que empiece el texto
    ld a, 2*8 + 0   ; A = PAPER * 8 + INK
    call PRINTAT
    halt