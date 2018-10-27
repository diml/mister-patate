
{ Nouvelle interruption du clavier pour Mister Patate }
unit MrpKey;

interface

const
  { Constantes de codes du clavier }
  ScanEchap	= 1;
  ScanDel	= 14;
  ScanTab	= 15;
  ScanEntree	= 28;
  ScanCtrlG	= 29;
  ScanShiftG	= 42;
  ScanShiftD	= 54;
  ScanAltG	= 56;
  ScanEspace	= 57;
  ScanVerrouille= 58;
  ScanF1	= 59;
  ScanF2	= 60;
  ScanF3	= 61;
  ScanF4	= 62;
  ScanF5	= 63;
  ScanF6	= 64;
  ScanF7	= 65;
  ScanF8	= 66;
  ScanF9	= 67;
  ScanF10	= 68;
  ScanVerrNum	= 69;
  ScanArretDefil= 70;
  ScanMoins	= 74;
  ScanPlus	= 78;
  ScanF11	= 87;
  ScanF12	= 88;
  ScanEntr	= 156;
  ScanCtrlD	= 157;
  ScanImprEcran	= 183;
  ScanAltD	= 184;
  ScanOrigine	= 199;
  ScanHaut	= 200;
  ScanPageHaut	= 201;
  ScanGauche	= 203;
  ScanDroite	= 205;
  ScanFin	= 207;
  ScanBas	= 208;
  ScanPageBas	= 209;
  ScanInser	= 210;
  ScanSuppr	= 211;

  { Constantes de charactŠres }
  CharEchap	= #27;
  CharDel	= #8;
  CharTab	= #9;
  CharEntree	= #13;
  CharEspace	= #32;
  CharF1	= #187;
  CharF2	= #188;
  CharF3	= #189;
  CharF4	= #190;
  CharF5	= #191;
  CharF6	= #192;
  CharF7	= #193;
  CharF8	= #194;
  CharF9	= #195;
  CharF10	= #196;
  CharMoins	= #45;
  CharPlus	= #43;
  CharF11	= #133;
  CharF12	= #134;
  CharEntr	= #13;
  CharOrigine	= #199;
  CharHaut	= #200;
  CharPageHaut	= #201;
  CharGauche	= #203;
  CharDroite	= #205;
  CharFin	= #207;
  CharBas	= #208;
  CharPageBas	= #209;
  CharInser	= #210;
  CharSuppr	= #211;

  Touche: array[0..255] of Char = (
{       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F }
{ 0 }  #0,#27,'1','2','3','4','5','6','7','8','9','0', #0, #0, #8, #0,
{ 1 } 'A', #0,'E','R','T', #0,'U', #0, #0,'P', #0, #0,#13, #0,'Q','S',
{ 2 } 'D','F','G','H','J','K','L','M','%', #0, #0,'æ', #0, #0,'C', #0,
{ 3 } 'B', #0, #0, #0, #0, #0, #0, #0, #0,' ', #0, #0, #0, #0, #0, #0,
{ 4 }  #0, #0, #0, #0, #0, #0, #0,'7','8','9','-','4','5','6','+','1',
{ 5 } '2','3','0', #0, #0, #0,'>', #0, #1, #0, #0, #0, #0, #0, #0, #0,
{ 6 }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ 7 }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ 8 }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ 9 }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ A }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ B }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ C }  #0, #0, #0, #0, #0, #0, #0, #0,'È', #0, #0,'Ë', #0,'Í', #0, #0,
{ D } 'Ð', #0,'Ò','Ó', #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ E }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
{ F }  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0);

var
  GetKey: array[0..255] of Boolean; { Etat des 256 touches }
  CharPress: array[0..255] of Char;
  PosChar: Byte;

{ Installe la nouvelle interruption }
procedure KBHon;

{ Remet l'ancienne interruption }
procedure KBHoff;

{ Renvoie le dernier charactŠre frapp‚e au clavier }
function InKey: Char;

{ Vide le buffer du clavier }
procedure ClearKey;

{ Test si une touche est press‚e }
function KeyPress: Boolean;

{ Renvoie le nom d'une touche }
function NomTouche (Code: Byte): String;

{ Attend que l'on appuie sur entr‚e }
procedure Sleep;

implementation

uses MrpStr;

var
  ScanEtendue: Boolean; { Si on re‡oit un code etendue }
  SaveInt09: Procedure; { Vecteur de l'ancienne interruption }

procedure KBHon; assembler;
asm
	DB	66h
        TEST	WORD PTR SaveInt09,0FFFFh { Si SaveInt09 <> nil, }
        DW	0FFFFh                    { on quitte		 }
        JNZ	@Exit
{ -* Change le vecteur de l'interruption 09h }
	MOV	AX,$3509
        INT	$21
	MOV 	WORD PTR [SaveInt09],BX
	MOV 	WORD PTR [SaveInt09+2],ES
        PUSH	DS { Sauve DS }
        MOV	AX,SEG @KeyboardHandling
        MOV	DS,AX { DS:DX -> Addresse de la nouvelle interruption }
        MOV	DX,OFFSET @KeyboardHandling
        MOV	AX,2509h { INT 21h, fonction 25h: change un vecteur }
	INT	21h      { d'interruption                           }
        POP	DS { Recharge DS }
	JMP	@Exit
{ * Nouvelle interruption du clavier * }
@KeyboardHandling:
	CLI     { Interdit les interruptions mat‚rielles }
        PUSH	AX
        PUSH	BX
        PUSH	DS
        MOV	AX,SEG @Data
        MOV	DS,AX
        IN	AL,60h { R‚cupŠre le scancode }
        MOV	BL,AL
        IN	AL,61h { Initialise la touche }
        OR	AL,80h
        OUT	61h,AL
        AND	AL,7Fh
        OUT	61h,AL
        MOV	AL,20h
	OUT	20h,AL
	CMP	BL,224 { Scancode ‚tendue }
        JNE	@Suite0
        MOV	ScanEtendue,1
        JMP	@ExitInt
@Suite0:MOV	AL,BL
	AND	AL,80h { Septi‚me Bit = 0 => Touche enfonc‚e}
        XOR	AL,80h
        AND	BX,7Fh
        TEST	ScanEtendue,1
        JE	@Suite1
        MOV	ScanEtendue,0
        CMP	BL,42 { Code parasite }
        JE	@ExitInt
        OR	BL,80h { Code = Code + 128 }
@Suite1:MOV	BYTE PTR [GetKey+BX],AL
        CMP	BX,ScanF12
        JNE	@Suite2
        CALL	ExitProc
@Suite2:TEST	AL,$FF
        JZ	@ExitInt
        MOV	AL,BYTE PTR [Touche+BX]
	MOV	BL,[PosChar]
        INC	BL
        JZ	@ExitInt
        MOV	[PosChar],BL
        MOV	BYTE PTR [CharPress+BX],AL
@ExitInt:
	POP     DS
        POP	BX
        POP	AX
	IRET
@Exit:
end;

procedure KBHoff; assembler;
asm
	DB	66h
        TEST	WORD PTR SaveInt09,0FFFFh { Si SaveInt09 = nil, }
        DW	0FFFFh                    { on quitte		}
        JZ	@Exit
{ -* Change le vecteur de l'interruption 09h }
        PUSH	DS { Sauve DS }
        LDS	DX,SaveInt09 { DS:DX -> Addresse de la nouvelle interruption }
        MOV	AX,2509h { INT 21h, fonction 25h: change un vecteur }
	INT	21h      { d'interruption                           }
        MOV	AX,0040h
        MOV	DS,AX { DS = Segment du BIOS }
        CLI
        MOV	BYTE PTR [0017h],32 { Etat des touches de fonctions = 32 }
        STI
        POP	DS { Recharge DS }
@Exit:
end;

function InKey; assembler;
asm
        XOR	BH,BH
        XOR	AL,AL
	MOV	BL,[PosChar]
        OR	BL,BL
        JZ	@ExitInkey
        MOV	AL,BYTE PTR [CharPress+BX]
        DEC	BL
        MOV	[PosChar],BL
@ExitInkey:
end;

procedure ClearKey; assembler;
asm
	MOV	[PosChar],0
end;

function KeyPress; assembler;
asm
	MOV	AX,DS
        MOV	ES,AX
        MOV	DI,OFFSET GetKey { ES:DI -> GetKey[0] }
        DB	66h
        XOR	AX,AX
        MOV	CX,64
        DB	66h
        REPE	SCASW { Compare 64 Dwords dans GetKey … 0 }
        JE	@Exit
    	MOV	AL,1 { Si un seul est dif‚rent de 0, on renvoie True }
@Exit:
end;

function NomTouche;
var
   S : string[11];
begin
  Case Code of
    0  : S := '????';
    1  : S := 'ECHAP';
    2  : S := '1';
    3  : S := '2';
    4  : S := '3';
    5  : S := '4';
    6  : S := '5';
    7  : S := '6';
    8  : S := '7';
    9  : S := '8';
    10 : S := '9';
    11 : S := '0';
    12 : S := ')';
    13 : S := '=';
    14 : S := 'DELETE';
    15 : S := 'TAB';
    16 : S := 'A';
    17 : S := 'Z';
    18 : S := 'E';
    19 : S := 'R';
    20 : S := 'T';
    21 : S := 'Y';
    22 : S := 'U';
    23 : S := 'I';
    24 : S := 'O';
    25 : S := 'P';
    26 : S := '^';
    27 : S := '$';
    28 : S := 'ENTREE';
    29 : S := 'CTRLG';
    30 : S := 'Q';
    31 : S := 'S';
    32 : S := 'D';
    33 : S := 'F';
    34 : S := 'G';
    35 : S := 'H';
    36 : S := 'J';
    37 : S := 'K';
    38 : S := 'L';
    39 : S := 'M';
    40 : S := '—';
    41 : S := 'ý';
    42 : S := 'SHIFTG';
    43 : S := 'æ';
    44 : S := 'W';
    45 : S := 'X';
    46 : S := 'C';
    47 : S := 'V';
    48 : S := 'B';
    49 : S := 'N';
    50 : S := ',';
    51 : S := ';';
    52 : S := ':';
    53 : S := '!';
    54 : S := 'SHIFTD';
    55 : S := '*';
    56 : S := 'ALT';
    57 : S := 'ESPACE';
    58 : S := 'VERROUILLE';
    59 : S := 'F1';
    60 : S := 'F2';
    61 : S := 'F3';
    62 : S := 'F4';
    63 : S := 'F5';
    64 : S := 'F6';
    65 : S := 'F7';
    66 : S := 'F8';
    67 : S := 'F9';
    68 : S := 'F10';
    69 : S := 'VERRNUM';
    70 : S := 'ARRET DEFIL';
    71 : S := 'PN 7';
    72 : S := 'PN 8';
    73 : S := 'PN 9';
    74 : S := '-';
    75 : S := 'PN 4';
    76 : S := 'PN 5';
    77 : S := 'PN 6';
    78 : S := '+';
    79 : S := 'PN 1';
    80 : S := 'PN 2';
    81 : S := 'PN 3';
    82 : S := 'PN 0';
    83 : S := '.';
    86 : S := '>';
    87 : S := 'F11';
    88 : S := 'F12';
    156: S := 'ENTR';
    157: S := 'CTRLD';
    181: S := '\';
    183: S := 'IMPR ECRAN';
    184: S := 'ALT GR';
    199: S := 'ORIGINE';
    200: S := 'HALT';
    201: S := 'PAGE HAUT';
    203: S := 'GAUCHE';
    205: S := 'DROITE';
    207: S := 'FIN';
    208: S := 'BAS';
    209: S := 'PAGEBAS';
    210: S := 'INSER';
    211: S := 'SUPPR';
    else S := '';
  end;
  NomTouche := StrChar (' ', 11 - Length (S)) + S;
end;

procedure Sleep;
begin
  ClearKey;
  repeat until InKey = CharEntree;
end;

end.

