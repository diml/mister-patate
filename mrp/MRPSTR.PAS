
{ Fonctions de chaines pour Mister Patate }
unit MrpStr;

interface

{ Convertit une valeur en chaine }
function Str (Valeur: LongInt; NbrChiffre: Byte): String;

{ Convertit une valeur en chaine en laissant des espaces }
function StrE (Valeur: LongInt; NbrChiffre: Byte): String;

{ Convertit une chaine en valeur }
function Val (S: String): LongInt;

{ Convertit une valeur en chaine hexad‚cimale }
function StrHexa (Valeur: LongInt; NbrChiffre: Byte): String;

{ Convertit une valeur en chaine hexad‚cimale }
function ValHexa (S: String): Word;

{ Convertit un pointer en SSSS:OOOO }
function PtrToStr(P: Pointer): String;

{ Cr‚e une chaine du mˆme charactŠre }
function StrChar (Charact: Char; Nb: Word): String;

{ Cr‚e une chaine de 80 espaces avec un texte au milieu }
function CenterText (Txt: String): String;

{ Renvoie 'OUI' si Bool = True et 'NON' si Bool = False }
function StrOk (Bool: Boolean): String;

{ Nombre de nombre de chiffre d'un nombre }
function Len (Nombre: Word): Byte;

{ Convertit une chaine en minuscule }
function StrLower (S: String): String;

{ Renvoie la moiti‚ d'une chaine }
function StrPart1 (S: String): String;
function StrPart2 (S: String): String;

implementation

function Str; assembler;
asm
DB $66; XOR	DX,DX
	MOV	DX,10
DB $66; MOV	SI,DX
	LES	DI,@Result { ES:DI -> Chaine de destination }
	XOR	AH,AH
	MOV	AL,NbrChiffre { Si NbrChiffre <> 0, on prend le nombre }
	OR	AL,AL	      { de chiffre indiqu‚es                   }
	JNZ	@CHiffreIndique
	DB	66h
	MOV	AX,Valeur.Word
	XOR	CX,CX
	INC	DI
	TEST	Valeur.Word[2],8000h { Si la valeur est < 0       }
	JZ	@@3		     { la chaine commence par '-' }
	MOV	ES:Byte[DI],'-'
	INC	DI
	DB	66h
	NEG	AX
@@3:    XOR	DX,DX
	DB	66h
	DIV	SI
	ADD	DL,'0'
	MOV	ES:[DI],DL
	INC	DI
	INC	CL
	DB	66h
	OR	AX,AX
	JNZ	@@3
	LES	DI,@Result
	MOV	ES:[DI],CL
	MOV	SI,DI
	ADD	SI,CX
	INC	DI
	CMP	ES:Byte[DI],'-'
	JNE	@@7
	INC	ES:Byte[DI-1]
	INC	DI
	INC	SI
@@7:	SHR	CX,1
	OR	CX,CX
	JZ	@@4
@@5:	MOV	AL,ES:[DI]
	XCHG	AL,ES:[SI]
	STOSB
	DEC	SI
	LOOP	@@5
	JMP	@@4
@ChiffreIndique:
	STOSB
	TEST	Valeur.Word[2],8000h
	JZ	@@6
	MOV	ES:Byte[DI],'-'
	INC	ES:Byte[DI-1]
	INC	DI
	DB	66h
	NEG	Valeur.Word
@@6:	ADD	DI,AX
	DEC	DI
	MOV	CX,AX
	DB	66h
	MOV	AX,Valeur.Word
@@1:    XOR	DX,DX
	DB	66h
	DIV	SI
	ADD	DL,"0"
	MOV	ES:[DI],DL
	DEC	DI
	LOOP	@@1
@@4:
end;

function StrE; assembler;
asm
DB $66; XOR	DX,DX
	MOV	DX,10
DB $66; MOV	SI,DX
	LES	DI,@Result
	XOR	AH,AH
	MOV	AL,NbrChiffre
	STOSB
	TEST	Valeur.Word[2],8000h
	JZ	@@6
	MOV	ES:Byte[DI],'-'
	INC	ES:Byte[DI-1]
	INC	DI
	DB	66h
	NEG	Valeur.Word
@@6:	ADD	DI,AX
	DEC	DI
	MOV	CX,AX
	DB	66h
	MOV	AX,Valeur.Word
@@1:    XOR	DX,DX
	DB	66h
	DIV	SI
	ADD	DL,"0"
	MOV	ES:[DI],DL
	DEC	DI
DB $66; OR	AX,AX
	JZ	@@2
	LOOP	@@1
	JMP	@@4
@@2:    DEC	CX
	JZ	@@4
	MOV	AL,' '
        STD
	REP	STOSB
	CLD
@@4:
end;

function Val; assembler;
asm
	XOR	DX,DX
	XOR	AX,AX
	PUSH	DS
	LDS	SI,S
	LODSB
	MOV	CL,AL
	XOR	CH,CH
	OR	AL,AL
	JZ	@@1
	DB	66h
	XOR	AX,AX
	DB	66h
	XOR	BX,BX
	DB	66h
	XOR	DI,DI
	MOV	DI,10
	CMP	DS:Byte[SI],'-'
	JNE	@@2
	INC	SI
	DEC	CX
@@2:    MOV	BL,DS:[SI]
	INC	SI
	SUB	BL,'0'
	DB	66h
	MUL	DI
	DB	66h
	ADD	AX,BX
	DB	66h
	LOOP	@@2
	LDS	SI,S
	CMP	DS:Byte[SI+1],'-'
	JNE     @@3
	DB	66h
	NEG	AX
@@3:    MOV	BX,AX
	DB	66h
	SHR	AX,16
	MOV	DX,AX
	MOV	AX,BX
@@1:	POP	DS
end;

function StrHexa; assembler;
asm
	DB	66h
	MOV	DX,Valeur.Word
	LES	DI,@Result
	XOR	AH,AH
	MOV	AL,NbrChiffre
	OR	AL,AL
	JNZ	@@2
	INC	DI
	XOR	BH,BH
	XOR	CX,CX
@@3:    INC	CL
	MOV	AL,DL
	AND	AL,15
	CMP	AL,9
	JA	@@6
	ADD	AL,'0'
	JMP	@@7
@@6:	ADD	AL,'A' - 10
@@7:	STOSB
	DB	66h
	SHR	DX,4
	DB	66h
	OR	DX,DX
	JNZ	@@3
	LES	DI,@Result
	MOV	ES:[DI],CL
	MOV	SI,DI
	ADD	SI,CX
	INC	DI
	SHR	CX,1
	OR	CX,CX
        JZ      @@4
@@5:	MOV	AL,ES:[DI]
	XCHG	AL,ES:[SI]
	STOSB
	DEC	SI
	LOOP	@@5
	JMP	@@4
@@2:	STOSB
	ADD	DI,AX
	DEC	DI
	STD
	MOV	CL,AL
	XOR	CH,CH
	XOR	BH,BH
@@1:	MOV	AL,DL
	AND	AL,15
	CMP	AL,9
	JA	@@8
	ADD	AL,'0'
	JMP	@@9
@@8:	ADD	AL,'A' - 10
@@9:     	STOSB
	DB	66h
	SHR	DX,4
	LOOP	@@1
	CLD
@@4:
end;

function ValHexa; assembler;
asm
	XOR	DX,DX
	XOR	AX,AX
	PUSH	DS
	LDS	SI,S
	LODSB
	MOV	DI,AX
	OR	AL,AL
	JZ	@@1
	DB	66h
	XOR	BX,BX
	DB	66h
	XOR	AX,AX
	ADD	SI,DI
	DEC	SI
	STD
	XOR	CL,CL
@@2:    LODSB
	CMP	AL,'9'
	JA	@@3
	SUB	AL,'0'
	JMP	@@4
@@3:	SUB	AL,'A' - 10
@@4:	DB	66h
	SHL	AX,CL
	DB	66h
	OR	BX,AX
	DB	66h
	XOR	AX,AX
	ADD	CL,4
	DEC	DI
	JNZ	@@2
	CLD
	MOV	AX,BX
	DB	66h
	SHR	BX,16
	MOV	DX,BX
@@1:	POP	DS
end;


function PtrToStr;
begin
  PtrToStr := StrHexa (LongInt (P) shr 16, 4) + ':' + StrHexa (LongInt (P) and $FFFF, 4);
end;

function StrChar; assembler;
asm
	LES	DI,@Result { ES:DI -> Chaine de destination }
        MOV	AX,Nb
	STOSB
        MOV	CX,AX
        MOV	AL,Charact
        REP	STOSB
end;

function CenterText; assembler;
asm
	LES	DI,@Result { ES:DI -> Chaine de destination }
        MOV	AL,80
        STOSB   { Length (CenterText) = 80 }
        DB	66h
        MOV	AX,"  "
        DW	"  " { EAX = 4 esapces }
        MOV	CX,20
        DB	66h
        REP     STOSW { Remplit la chaine d'espace }
        SUB	DI,40 { Met DI au milieu de la chaine }
        PUSH	DS
        LDS	SI,Txt { DS:SI -> Texte … centrer }
        LODSB   { Longueur du texte }
        XOR	AH,AH
        MOV	CX,AX
        SHR	AX,1
        SUB	DI,AX { DI = 40 - Length (Txt) / 2 }
        REP	MOVSB
        POP	DS
end;

function StrOk; assembler;
asm
	LES	DI,@Result
        TEST	[Bool],255
	JZ	@Non
        DB	66h
        MOV	AX,"O" * 256 + 3
        DW	"IU"
        JMP	@Fin
@Non:   DB	66h
        MOV	AX,"N" * 256 + 3
        DW	"NO"
@Fin:	DB	66h
	STOSW
end;

function Len; assembler;
asm
        MOV	AX,WORD[Nombre]
        XOR	DX,DX
        XOR	CL,CL
        MOV	BX,10
@LoopLen:
        XOR	DX,DX
        DIV	BX
        INC	CL
        OR	AX,AX
        JNZ	@LoopLen
        MOV	AL,CL
end;

function StrLower; assembler;
asm
        PUSH	DS
        LDS	SI,[S]
	LES	DI,@Result
        LODSB
        STOSB
        MOV	CL,AL
        XOR	CH,CH
@LoopStr:
	LODSB
        CMP	AL,'A'
        JB	@PutChar
        CMP	AL,'Z'
        JA	@PutChar
        OR	AL,32
@PutChar:
        STOSB
        LOOP	@LoopStr
        POP	DS
end;

function StrPart1;
var
  Middle, Pos: Byte;
begin
  Middle := Length (S) shr 1;
  Pos := 0;
  repeat
    if S[Middle-Pos] = ' ' then begin
      StrPart1 := Copy (S, 1, Middle - Pos - 1);
      exit;
    end;
    if S[Middle+Pos] = ' ' then begin
      StrPart1 := Copy (S, 1, Middle + Pos - 1);
      exit;
    end;
    inc (Pos);
  until false;
end;

function StrPart2;
var
  Middle, Pos: Byte;
begin
  Middle := Length (S) shr 1;
  Pos := 0;
  repeat
    if S[Middle-Pos] = ' ' then begin
      StrPart2 := Copy (S, Middle - Pos + 1, Length (S) - (Middle - Pos));
      exit;
    end;
    if S[Middle+Pos] = ' ' then begin
      StrPart2 := Copy (S, Middle + Pos + 1, Length (S) - (Middle + Pos));
      exit;
    end;
    inc (Pos);
  until false;
end;

end.
