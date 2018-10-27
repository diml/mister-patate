
{ Routine pour la palette }
unit MrpPal;

interface

uses MrpVga, MrpTps;

type
  Couleur = record
    R, V, B: Byte;
  end;
  TypePalette = array[0..255] of Couleur;
  T8Color = array[0..7] of Couleur;
var
  { Toute la palette }
  Palette: TypePalette;



const
  PalInit: array[0..15] of Couleur =(
(R: 0;V: 0;B: 0),(R:63;V:63;B:63),(R:57;V:47;B: 0),(R:60;V:57;B: 0),
(R: 7;V:63;B: 7),(R: 0;V:58;B: 0),(R:15;V:31;B:63),(R: 0;V: 0;B: 0),
(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),
(R:48;V: 0;B: 0),(R:53;V: 0;B: 0),(R:58;V: 0;B: 0),(R:63;V: 0;B: 0));

  PalAnim3: array[0..2] of T8Color = (
((R:17;V:32;B:57),(R:63;V:58;B: 0),(R:63;V:58;B: 0),(R:63;V:58;B: 0),
 (R:63;V:58;B: 0),(R:63;V:63;B:47),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0)),
((R:17;V:32;B:57),(R:63;V:58;B: 0),(R:63;V:63;B:63),(R:63;V:58;B: 0),
 (R:63;V:63;B:47),(R:63;V:58;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0)),
((R:63;V:63;B:63),(R:63;V:63;B:63),(R:63;V:63;B:63),(R:63;V:63;B:47),
 (R:63;V:58;B: 0),(R:63;V:58;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0)));

  PalAnim2: array[0..1] of T8Color = (
((R:17;V:32;B:57),(R:63;V:58;B: 0),(R:63;V:63;B:31),(R:47;V:47;B:15),
 (R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0)),
((R:47;V:34;B:33),(R:47;V:34;B:33),(R:47;V:47;B:15),(R:63;V:63;B:31),
 (R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0),(R: 0;V: 0;B: 0)));

{ Change toutes les couleurs }
procedure OutPalette(D, F: Word);

{ Lit toutes les couleurs }
procedure InPalette(D, F: Word);

{ Change une couleur pour une autre se trouvant dans 'Palette' }
procedure ChangePalette (Src, Dst: Byte);

{ Change les couleurs d'un attribut }
procedure SetPalette (Attribut, R, V, B: Byte);

{ Change les couleurs d'un attribut }
procedure SetPaletteV (Attribut, R, V, B: Byte);

{ Diminue progressivement les couleurs }
procedure PaletteFadeIn;

{ Augmente progressivement les couleurs }
procedure PaletteFadeOut;

{ Augmente progressivement les couleurs }
procedure ConvertPalette;

{ Change les couleurs de tous attribut }
procedure FillPalette (R, V, B: Byte);

implementation

procedure OutPalette; assembler;
asm
        MOV	AX,[D]
        MOV	SI,AX
        SHL	SI,1
        ADD	SI,AX
	ADD	SI,OFFSET Palette { DS:SI -> Couleur D }
        MOV	CX,[F]
        SUB	CX,AX
        INC	CX
        MOV	BX,CX
        SHL	CX,1
        ADD	CX,BX
        MOV	DX,3C8h { Port d'‚criture de la palette }
        OUT	DX,AL { Commence avec la couleur D }
        INC	DX
        REP	OUTSB { Envoie toute la palette }
end;

procedure InPalette; assembler;
asm
        MOV	AX,DS
        MOV	ES,AX
        MOV	AX,[D]
        MOV	CX,[F]
        SUB	CX,AX
        INC	CX
        MOV	BX,CX
        SHL	CX,1
        ADD	CX,BX
        MOV	DI,AX
        SHL	DI,1
        ADD	DI,AX
	ADD	DI,OFFSET Palette { ES:DI -> Couleur D }
        MOV	DX,3C7h { Port de lecture de la palette }
        XOR	AL,AL
        OUT	DX,AL { Commence avec la couleur D }
        MOV	DX,3C9h
        REP	INSB { Lit toute la palette }
end;

procedure ChangePalette; assembler;
asm
        MOV	DX,3C8h { Port d'‚criture de la palette }
        MOV	AL,Dst
        OUT	DX,AL { Change la couleur 'Dst' }
        MOV	AL,Src
        XOR	AH,AH
        MOV	SI,AX
        SHL	AX,1
	ADD	SI,AX
	ADD	SI,OFFSET Palette { DS:SI -> Palette[Src] }
        MOV	CX,3
        INC	DX
        REP	OUTSB { Envoie une couleur }
end;

procedure SetPalette; assembler;
asm
	MOV	AL,[Attribut]
        MOV	DX,$3C8
        OUT	DX,AL
        MOV	AL,[R]
        INC	DX
        OUT	DX,AL
        MOV	AL,[V]
        OUT	DX,AL
        MOV	AL,[B]
        OUT	DX,AL
end;

procedure SetPaletteV;
begin
  Palette[Attribut].R := R;
  Palette[Attribut].V := V;
  Palette[Attribut].B := B;
end;

procedure PaletteFadeIn; assembler;
var
  PaletteTmp: array[0..255] of Couleur;
asm
	MOV	AX,SS
        MOV	ES,AX
        LEA	DI,[PaletteTmp]
        MOV	SI,OFFSET Palette
        MOV	CX,768 / 4
DB $66; REP	MOVSW
@@1:    MOV	[Counter],0
	MOV	CX,768
        LEA	DI,[PaletteTmp]
	XOR	BL,BL
@@2:    MOV	AL,ES:[DI]
        OR	AL,AL
        JZ	@@3
	DEC	AL
@@3:    STOSB
	OR	BL,AL
        LOOP	@@2
        CALL	Wait
        MOV	DX,$3C8
        XOR	AL,AL
        OUT	DX,AL
        MOV	CX,768
        LEA	SI,[PaletteTmp]
        INC	DX
        PUSH	DS
        MOV	AX,SS
        MOV	DS,AX
        REP	OUTSB
	POP	DS
@@4:	TEST	[Counter],$FFFF
	JZ	@@4
	OR	BL,BL
        JNZ	@@1
end;

procedure PaletteFadeOut; assembler;
var
  PaletteTmp: array[0..255] of Couleur;
asm
        PUSH	DS
	MOV	BX,SS
        MOV	ES,BX
        MOV	CX,768 / 4
        LEA	DI,[PaletteTmp]
DB $66; XOR	AX,AX
DB $66; REP	STOSW
        MOV	AX,DS
	MOV	DS,BX
        MOV	ES,AX
@@1:    MOV	ES:[Counter],0
	MOV	CX,768
        LEA	SI,[PaletteTmp]
	MOV	DI,OFFSET Palette
	XOR	BL,BL
@@2:    MOV	AL,[SI]
        CMP	AL,ES:[DI]
        JE	@@3
	INC	BYTE PTR [SI]
	MOV	BL,1
@@3:	INC	DI
	INC	SI
        LOOP	@@2
        CALL	Wait
        MOV	DX,$3C8
        XOR	AL,AL
        OUT	DX,AL
        MOV	CX,768
        LEA	SI,[PaletteTmp]
        INC	DX
        REP	OUTSB
@@4:	TEST	ES:[Counter],$FFFF
	JZ	@@4
        OR	BL,BL
        JNZ	@@1
	POP	DS
end;

procedure ConvertPalette; assembler;
var
  PaletteTmp: array[0..255] of Couleur;
asm
        PUSH	DS
	MOV	BX,SS
        MOV	ES,BX
        MOV	CX,768 / 4
        LEA	DI,[PaletteTmp]
        MOV	DX,$3C7
        XOR	AL,AL
        OUT	DX,AL
        MOV	DL,$C9
        MOV	CX,768
	REP	INSB
        MOV	AX,DS
	MOV	DS,BX
        MOV	ES,AX
@@1:    MOV	ES:[Counter],0
	MOV	CX,768
        LEA	SI,[PaletteTmp]
	MOV	DI,OFFSET Palette
	XOR	BL,BL
@@2:    MOV	AL,[SI]
        CMP	AL,ES:[DI]
        JE	@@3
        JA	@@5
        INC	BYTE PTR [SI]
        JMP	@@6
@@5:	DEC	BYTE PTR [SI]
@@6:	MOV	BL,1
@@3:	INC	DI
	INC	SI
        LOOP	@@2
        CALL	Wait
        MOV	DX,$3C8
        XOR	AL,AL
        OUT	DX,AL
        MOV	CX,768
        LEA	SI,[PaletteTmp]
        INC	DX
        REP	OUTSB
@@4:	TEST	ES:[Counter],$FFFF
	JZ	@@4
        OR	BL,BL
        JNZ	@@1
	POP	DS
end;

procedure FillPalette;
var
  i: Byte;
begin
  for i := 1 to 255 do SetPalette (i,R,V,B);
end;

end.