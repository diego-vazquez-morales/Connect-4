;-----------------------------------------------------------------------
;NOMBRE: Tablero.asm
;DESCRIPCION: Dibuja el tablero de Conecta 4 y maneja el movimiento de fichas
;-----------------------------------------------------------------------

; constantes
AZUL        EQU 1
AMARILLO    EQU 6
ROJO        EQU 2
NEGRO       EQU 0
ANCHO_FILA  EQU 29
ALTO_COL    EQU 19
SIGUIENTE_FILA EQU 67
ANCHO_FICHA EQU 3

; Variables
pos_x:      DB 66              ; Posicion X inicial ($5842)
turno:      DB 0               ; 0 = Jugador 1 (Amarillo), 1 = Jugador 2 (Rojo)
columna:     DB 0

; Tablero: 42 slots organizados por columnas (7 columnas x 6 filas)
; Cada columna tiene 6 valores, de arriba (fila 6) a abajo (fila 1)
; Valor: 0 = vacío, AMARILLO (6) = jugador 1, ROJO (2) = jugador 2
tablero:
        ; Columna 1: (6,1), (5,1), (4,1), (3,1), (2,1), (1,1)
        DB 0, 0, 0, 0, 0, 0
        ; Columna 2: (6,2), (5,2), (4,2), (3,2), (2,2), (1,2)
        DB 0, 0, 0, 0, 0, 0
        ; Columna 3: (6,3), (5,3), (4,3), (3,3), (2,3), (1,3)
        DB 0, 0, 0, 0, 0, 0
        ; Columna 4: (6,4), (5,4), (4,4), (3,4), (2,4), (1,4)
        DB 0, 0, 0, 0, 0, 0
        ; Columna 5: (6,5), (5,5), (4,5), (3,5), (2,5), (1,5)
        DB 0, 0, 0, 0, 0, 0
        ; Columna 6: (6,6), (5,6), (4,6), (3,6), (2,6), (1,6)
        DB 0, 0, 0, 0, 0, 0
        ; Columna 7: (6,7), (5,7), (4,7), (3,7), (2,7), (1,7)
        DB 0, 0, 0, 0, 0, 0

DibujarTablero:
        CALL CLEARSCR 
        LD HL, $5881            
        LD DE, HL               
        PUSH HL

DibujarFilas:
        LD A, 8*AZUL            
        LD B, 7                 

BucleFilas:
        PUSH BC
        LD B, ANCHO_FILA        

PintarFila:
        LD (HL), A              
        INC HL                  
        DJNZ PintarFila         

        LD BC, SIGUIENTE_FILA   
        ADD HL, BC              
        POP BC                  
        DJNZ BucleFilas        
        POP HL
        LD HL, DE               

DibujarColumnas:
        LD B, 8                 

BucleColumnas:
        LD DE, HL               
        PUSH BC
        LD B, ALTO_COL          

PintarColumna:
        LD (HL), A              
        PUSH BC
        LD BC, 32              
        ADD HL, BC              
        POP BC
        DJNZ PintarColumna      

        LD HL, DE                         
        LD BC, 4                
        ADD HL, BC              
        POP BC
        DJNZ BucleColumnas     
        RET

DibujarFichaInicial:
        ; Dibuja la ficha en (pos_x) según (turno)
        LD A, (pos_x)
        LD HL, $5800
        LD D, 0
        LD E, A
        ADD HL, DE          ; HL = direccion inicial de la ficha

        LD A, (turno)
        AND 1
        JR NZ, .jug2
        LD A, 8*AMARILLO    ; PAPER = AMARILLO
        JR .draw
.jug2:
        LD A, 8*ROJO
.draw:
        LD B, 2             ; alto = 2 filas
.loop_fila:
        PUSH BC
        LD B, ANCHO_FICHA   ; ancho = 3 columnas
.loop_col:
        LD (HL), A
        INC HL
        DJNZ .loop_col
        LD BC, 29           ; saltar a la siguiente linea
        ADD HL, BC
        POP BC
        DJNZ .loop_fila
        RET

BorrarFichaAnterior:
        ; Borra la ficha en la posición actual
        LD A, (pos_x)
        LD HL, $5800
        LD D, 0
        LD E, A
        ADD HL, DE

        LD A, 8*NEGRO       ; atributo negro
        LD B, 2             ; alto = 2 filas

.bucle_fila:
        PUSH BC
        LD B, ANCHO_FICHA
        
.bucle_col:
        LD (HL), A
        INC HL
        DJNZ .bucle_col
        LD BC, 29
        ADD HL, BC
        POP BC
        DJNZ .bucle_fila
        RET

ComprobarTeclado:
        ; Detectar F (finalizar partida) - PRIMERO
        LD BC, $FDFE          ; Fila A-G
        IN A, (C)
        BIT 3, A              ; F = bit 3
        JR NZ, .no_f
        
        ; Esperar a que se suelte F
.esperar_f:
        LD BC, $FDFE
        IN A, (C)
        BIT 3, A
        JR Z, .esperar_f
        
        JP pantalla_fin_juego ; Ir a pantalla final
        
.no_f:
        ; Detectar Q (izquierda)
        LD BC, $FBFE
        IN A, (C)
        BIT 0, A
        JR NZ, .no_q

        CALL MoverIzquierda
        RET
        
.no_q:
        ; Detectar W (derecha)
        LD BC, $FBFE
        IN A, (C)
        BIT 1, A
        JR NZ, .no_w
        
        CALL MoverDerecha
        RET
        
.no_w:
        ; Detectar ENTER (cambiar jugador)
        LD BC, $BFFE
        IN A, (C)
        BIT 0, A
        JR NZ, .no_enter
        
        CALL CambiarJugador
        RET
.no_espacio:
        ; Detectar ESPACIO (Soltar Ficha)
        LD BC, $7FFE
        IN A, (C)
        BIT 0, A 
        JR NZ, .no_espacio

        CALL SoltarFicha
        RET 

.no_enter:
        ; Ninguna tecla - borde negro
        XOR A
        OUT ($FE), A
        RET

MoverDerecha:
        LD A, (pos_x)
        CP 90                  ; Limite derecho de la ficha
        RET NC
        
        CALL BorrarFichaAnterior
        
        LD A, (pos_x)
        ADD A, 4
        LD (pos_x), A
        
        CALL DibujarFichaInicial
        RET

MoverIzquierda:
        LD A, (pos_x)
        CP 66                  ; Limite izquierdo de la ficha
        RET Z
        
        CALL BorrarFichaAnterior
        
        LD A, (pos_x)
        SUB 4
        LD (pos_x), A
        
        CALL DibujarFichaInicial
        RET

CambiarJugador:
        ; Alternar entre j1 (0) y j2 (1)
        LD A, (turno)
        XOR 1                 ; Cambiar 0 a 1 o 1 a 0
        LD (turno), A
        
        ; Redibujar la ficha con el nuevo color
        CALL DibujarFichaInicial
        RET

SoltarFicha:
        ; Comprobar el turno
        LD A, (turno)
        CP 0                  ; ¿Es turno 0 (Amarillo)?
        JR Z, TurnoAmarillo   ; Si es 0, saltar a TurnoAmarillo
        JR TurnoRojo          ; Si no, es TurnoRojo

TurnoAmarillo:
        ; Comprobamos el numero de columna en la que esta la ficha
        ; Tenemos que hacer la siguiente operacion para comprobar la columna
        ; Columna = (pos_x - 66) / 4 + 1
        LD A, (pos_x)
        SUB 66          ; pos_x - 66
        SRL A 
        SRL A           ; Dividimos entre 4
        INC A           ; +1 para obtener columna (1-7)
        ; Cargamos en columna la columna que es
        LD (columna), A
        

        ; ...
        RET

TurnoRojo:
        ; Aquí código para soltar ficha roja
        ; ...
        RET
