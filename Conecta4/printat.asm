; -------------------------------
; ZX Spectrum Text print library
; Daniel León - AOC - UFV 2020
; -------------------------------


; ----------------------------------------------------------------------------------------   
; PRINTAT - Print a string in a position and attributes as per registers:
;		IN	A	: Bit 7=1 For Flash / Bit 6=1 For Brigh / Bit 5,4,3 for Paper / Bit 2,1,0 for Ink
;		IN	B	: Row 0..23
;		IN	C	: Column 0..31
;		IN	IX	: Address of text (Text must end in a 0)
; ---------------------------------------------------------------------------------------- 
PRINTAT:	call PREP_PRT				; Update Attribute var &Screen & Attributes pointers
; ---------------------------------------------------------------------------------------- 
;		VVV Do not move PRINTSTR below as PRINTAT continues into PRINTSTR routine
; ----------------------------------------------------------------------------------------   
; PRINTSTR - Prints String - IX Points to the String start
; ----------------------------------------------------------------------------------------      
PRINTSTR:   ld a, (ix)					; A Contains first char to print
			or a						; check for end of string (0)
			ret z						; Finish printing if 0
			call PRINTCHNUM			
			inc ix						; Move to next char in string
			jr PRINTSTR					; Start over printing sequence	
; ----------------------------------------------------------------------------------------  


;-----------------------------------------------------------------------------------------
; PREP_PRT - Updates Print_Attr, SCR & ATTR Vars
;-----------------------------------------------------------------------------------------
PREP_PRT:	ld (PRINT_ATTR),a			; Set Attribute
PREP_PRT_2:	call CRtoSCREEN
			jp CRtoATTR				
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; CRtoSCREEN - Converts a scr char coord into a SCREEN Address   b,c = y,x positions
;	IN  - B=Row, C=Column
;	OUT - HL=Address in screen also stored in (SCR_CUR_PTR)
;	Conversion:
;			Row FFfff   Column CCCCC
;			HL=%010FF000 fffCCCCC
;-----------------------------------------------------------------------------------------
CRtoSCREEN:
		ld a,b						; %___FFfff
			or #40						; %010FFfff
			and #F8						; %010FF000
			ld h,a
	
			ld a,b						; %___FFfff
			and #7						; %00000fff
			rrca						; %f00000ff
			rrca						; %ff00000f
			rrca						; %fff00000
			or c						; %fffCCCCC
			ld l,a
            ld (SCR_CUR_PTR),hl			; Update Variable
            ret
; ---------------------------------------------------------------------------------------- 



;-----------------------------------------------------------------------------------------
; CRtoATTR - Converts a screen char coord  into a ATTR Address  b,c = y,x positions
;	IN  - B=Row, C=Column
;	OUT - HL=Address in screen also stored in (SCR_ATTR_PTR)
;	Conversion:
;			Row FFfff   Column CCCCC
;			HL=%010110FF fffCCCCC
;-----------------------------------------------------------------------------------------
CRtoATTR:	
			ld a,b						; %___FFfff
			rrca						; %f000FFff
			rrca						; %ff000FFf
			rrca						; %fff000FF
			ld l,a
			and 3						; %000000FF	value of FF can be only 00,01,10
			or #58						; %010110FF value will be #58, #59 or #5A
			ld h,a

			ld a,l						; %fff000FF
			and #E0						; %fff00000
			or c						; %fffCCCCC
			ld l,a

            ld (SCR_ATTR_PTR),hl		; Update Variable
            ret
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------   
; PRINTCHNUM - Prints Char Number N (stored in A)
;----------------------------------------------------------------------------------------- 
PRINTCHNUM:	;SUB 32						; Adjust Ascii to charset
			ld h,0						; Multiply value by 8 to get to right Char in Charset
			ld l,a
			add hl,hl
			add hl,hl
			add hl,hl
			ld de, CHARSET-(8*32)		; Optimize in compile time (instead of sub 32)
			add hl,de
			ex  de,hl					;Value in DE
			; Continues to printchar below
; ----------------------------------------------------------------------------------------

		
; ----------------------------------------------------------------------------------------   
; PRINTCHAR - Prints Char  (DE points to the char. Uses HL as last Cur Pointer)
; ----------------------------------------------------------------------------------------  
PRINTCHAR:
			ld b,8						; 8 Lines per char
            ld hl, (SCR_CUR_PTR)		; Load Cursor Pointer y,x 

BYTEPCHAR:	ld a,(de)					; Get Char to be printed, first line
			ld (hl),a					; Move to Printing location           
            inc h						; inc H so next line in char (ZX Spectrum Screen RAM)
            inc de						; next line to be printed
            djnz BYTEPCHAR				; Repeat 8 lines
            ld a,(PRINT_ATTR) 			; Load Attributes to print char with
            ld hl, (SCR_ATTR_PTR)		
            ld (hl),a
            ld hl, SCR_ATTR_PTR			; Get pointer to ATTR
            inc (hl)					; Move Attribute cursor to next char
			ld hl, SCR_CUR_PTR
			inc (hl)					; update Cursor pointer to next position
            ret
; ----------------------------------------------------------------------------------------  



; ----------------------------------------------------------------------------------------   
; INK2PAPER - moves ink of attribute stored in (PRINT_ATTR) to paper and sets ink to 0
; 				Sets bright 1 and flash 0
; ---------------------------------------------------------------------------------------- 
INK2PAPER:	ld a, (PRINT_ATTR)		    ; Get storedAttribute         
			and 7						; get Attr INK in A
			rlca
			rlca
			rlca						; move Ink to Paper
			or 64						; ink 0 bright 1
			ld (PRINT_ATTR),a		    ; Get storedAttribute     
			ret
; ----------------------------------------------------------------------------------------



CLEARSCR:	ld hl,$4000					; Erases screen by writing 0 to all pixels and attributes
			ld de,$4001
			ld bc,6911
			ld (hl),0
			ldir
			ret


SCR_CUR_PTR : 	db $00, $00				; Cursor Pointer in Screen (2 bytes) (HL)
SCR_ATTR_PTR: 	db $00, $00				; Attr Pointer in Screen (2 bytes) (HL)
PRINT_ATTR:		db $00					; Attribute used by printchar routine (1 byte)

CHARSET: incbin "charset.bin"			; Charset used

