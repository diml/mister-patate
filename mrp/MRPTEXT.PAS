
{ Affichage de texte en mode texte pour Mister Patate }
unit MrpText;

interface

{ Passe en mode texte }
procedure InitTexte;

{ Renvoie le mode courant }
function GetMode: Byte;

{ Ecrit un texte … la position du curseur, avec la couleur 'color' }
procedure Print (Txt: String; Color: Byte);

{ Idem que 'Print' mais passe … la ligne }
procedure PrintR (Txt: String; Color: Byte);

{ Retourne … la ligne si la colonne du curseur est sup‚rieur … 0 }
procedure Retour;

{ Efface l'‚cran }
procedure ClsTexte;

implementation

procedure InitTexte; assembler;
asm
	MOV	AX,0003h { INT 10h, fonction 00h: Change de mode vid‚o }
        INT	10h
end;

function GetMode; assembler;
asm
	MOV	AH,0Fh { INT 10h, fonctions 0Fh: renvoie le mode vid‚o }
        INT	10h
end;

procedure Print; assembler;
asm
	PUSH	DS
        LDS	SI,[Txt]
        LODSB
        MOV	DL,AL
        XOR	BH,BH
        MOV	BL,[Color]
	MOV	CX,1
@LoopChar:
        MOV	AX,$0900
        INT	$10
        MOV	AH,$0E
        LODSB
	INT	$10
        DEC	DL
        JNZ	@LoopChar
        POP	DS
end;

procedure PrintR;
begin
  Print (Txt, Color);
  Retour;
end;

procedure Retour; assembler;
asm
	MOV	AX,$0E0A
        INT	$10
        MOV	AX,$0E0D
        INT	$10
end;

procedure ClsTexte; assembler;
asm
	MOV	AX,$B800
        MOV	ES,AX
        DB	66h
        XOR	AX,AX
        MOV	CX,80*25*2/4
        DB	66h
        REP	STOSW
        PUSH	BP
        MOV	AH,$02
	XOR	DX,DX
        INT	10h
        POP	BP
end;

end.
