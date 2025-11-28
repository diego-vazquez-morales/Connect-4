;-----------------------------------------------------------------------
;NOMBRE: Arkanoi.asm
;DESCRIPCION: Rutina que contiene la lógica principal del juego Arkanoid, 
;              incluyendo la pantalla de inicio, la gestión de entradas 
;              del usuario y el flujo del juego.
;ENTRADA: Ninguna
;SALIDA: Pantalla de juego o la pantalla de adios.
;-----------------------------------------------------------------------
    DEVICE ZXSPECTRUM48
    org $8000
    ld sp, 0
;--------------------------espacio para variables y definiciones-----------------------------
    jp inicio
jugar: DB "Quieres jugar (S/N)?", 0
bienvenida: DB "Bienvenido a Conecta 4", 0
;--------------------------------------------------------------------------------------------

;----------------------------------Programa Principal----------------------------------------
inicio:
    ld a, 0*8 + 0  ; A = PAPER * 8 + INK
    out($fe), a 

    ld ix, bienvenida 
    ld b, 2  ; fila donde quiero que empiece el texto
    ld c, 7  ; columna donde quiero que empiece el texto
    ld a, 0*8 + 2   ; A = PAPER * 8 + INK
    call PRINTAT

    ld ix, jugar
    ld b, 23  ; fila donde quiero que empiece el texto
    ld c, 0   ; columna donde quiero que empiece el texto
    ld a, 0*8 + 6   ; A = PAPER * 8 + INK
    call PRINTAT


    ld a, 198
    ld ($5800+ 23*32 + 20), a

    LD B, 23                        ;Fila
    LD C, 20                        ;Columna
    LD A, 6                         ;Atributo
    call LEER_SN          ; Llama a la rutina para leer S/N 
    ld a, (TECLA_SN)     ; Cargar la tecla leída en A (se almacena en LEER_SN)

    ; ha pulsado s 
    cp 'S'  ; 
    jp z, pantalla_juego
    call pantalla_adios

fin: jr fin
;--------------------------------------------------------------------------------------------


;---------------------------------------Rutinas----------------------------------------------
    include "Tablero.asm"
    include "printat.asm"
    include "leersn.asm"
    include "pantallajuego.asm"
    include "pantallaAdios.asm"
    include "pantallaFinJuego.asm"

;--------------------------------------------------------------------------------------------

;--------------------------------------Comentarios-------------------------------------------
;Parámetros
;
;
;
