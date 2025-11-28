;--------------------------variables y definiciones-----------------------------
mensajeFin: DB "La partida ha finalizado", 0
otraPartidaFin: DB "Quieres jugar otra partida (S/N)?", 0
;--------------------------------------------------------------------------------------------

pantalla_fin_juego:
    call CLEARSCR
    
    ; borde negro
    XOR A
    OUT ($FE), A

    ld ix, mensajeFin 
    ld b, 2
    ld c, 1
    ld a, 0*8 + 1
    call PRINTAT
    
    ld ix, otraPartidaFin
    ld b, 23
    ld c, 0
    ld a, 0*8 + 6
    call PRINTAT

    call LEER_SN
    ld a, (TECLA_SN)      ; Cargar la tecla leida
    
    cp 'S'
    jp z, reiniciar_juego  ; Si es S ir a reiniciar juego
    jp pantalla_adios      ; Si es n ir a pantalla adios

reiniciar_juego:
    ; Reiniciar variables del juego
    LD A, 66
    LD (pos_x), A
    XOR A
    LD (turno), A
    
    ; Volver al juego
    JP pantalla_juego