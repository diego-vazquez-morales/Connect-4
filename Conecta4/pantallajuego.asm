;-----------------------------------------------------------------------
;NOMBRE: pantallaJuego.asm
;DESCRIPCION: Maneja la pantalla y lógica del juego
;-----------------------------------------------------------------------

pantalla_juego:
        ; NO usar DI, o si lo usas, activar EI después
        CALL CLEARSCR
        XOR A
        OUT ($FE), A
        
        CALL DibujarTablero
        
        LD A, 66
        LD (pos_x), A
        XOR A
        LD (turno), A
        CALL DibujarFichaInicial
        
        EI                     ; ← IMPORTANTE: Habilitar interrupciones

bucle_principal:
        ; HALT                 ; ← Mantener comentado por ahora
        
        CALL ComprobarTeclado
        
        ; Delay para no ir muy rápido
        LD B, 50
.delay: 
        PUSH BC
        LD BC, 500
.delay2:
        DEC BC
        LD A, B
        OR C
        JR NZ, .delay2
        POP BC
        DJNZ .delay
        
        JR bucle_principal