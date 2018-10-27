
{$G+,N+}
{ Editeur de sprite }
program SprMaker;

uses MrpStr, MrpInit, MrpVga, MrpPal, MrpLoad, MrpTps, MrpText, MrpKey, MrpGraph;

var
  ScreenX, ScreenY: Word; 	{ Position dans le sprites 	             }
  SpriteX, SpriteY: array[0..511] of Word;	{ Position des sprites 	     }
  SpriteTemp: Word;
  Sprite: Word;         { Sprite actuel 			             }
  Color: Word;		{ Couleur actuelle                                   }
  Draw: record 		{ Information sur les dessins 			     }
    Statut: Byte; 	{ * Etat du dessin 				     }
    X1, Y1: integer; 	{ * D‚but du dessin 				     }
    X2, Y2: integer; 	{ * fin du dessin 				     }
    T     : LongInt;    { * D‚lai pour faire scroller le niveau	             }
  end;                  {						     }
  Red  : Word;          { Quantite de rouge de Color 			     }
  Green: Word;		{ Quantite de vert de Color 			     }
  Blue : Word;          { Quantite de bleu de Color 			     }
  PointMode: Byte;      { Mode de tracage des points 			     }
  Selection: record     { Information sur la s‚l‚ction			     }
    Actif: Boolean; 	{ * Etat du dessin 				     }
    X1, Y1: integer; 	{ * D‚but du dessin 				     }
    X2, Y2: integer; 	{ * fin du dessin 				     }
    Largeur: Word;
    Hauteur: Word;
    LargeurCut: Word;
    HauteurCut: Word;
  end;                  {						     }
  Deplace: Boolean;     { Information sur le d‚placement de la s‚l‚ction     }
  Echelle: Byte;
  TimScreen: LongInt;
  DimSpr: LongInt;
  ChgSprOk: WordBool;
  Sprite1: PtrBuffer;
  Sprite2: PtrBuffer;
  FinColor: Boolean;

const
  { Nombre maiximum de couleur }
  MaxColor: Word = 223;

  { Nombre maiximum de sprites }
  MaxSprite: Word = 511;

  { Nombre de rouge, vert, bleu maximum }
  MaxRGB: Word = 63;

  { Pour les dessins }
  Pixel   = 0;
  Line    = 1;
  Box     = 2;
  Boxf    = 3;
  Circle  = 4;
  Circlef = 5;
  Select  = 6;

  { Pour les curseurs }
  CurseurInSel: array[1..33] of ShortInt =
(16,-1,-3, 0,-3,+1,-3, 0,-4,-1,+3, 0,+3,+1,+3, 0,+4,-3,-1,-3, 0,-3,+1,-4, 0,+3,-1,+3, 0,+3,+1,+4, 0);
  CurseurClic: array[1..33] of ShortInt =
(16,-1,-3, 0,-3,+1,-3, 0,-2,-1,+3, 0,+3,+1,+3, 0,+2,-3,-1,-3, 0,-2, 0,+3,-1,+3, 0,+3,+1,+2, 0,-3,+1);
  CurseurSetScreen: array[1..25] of ShortInt =
(12,-2,-1,-2,-2,-1,-2,+2,-1,+2,-2,+1,-2,-2,+1,-2,+2,-1,+2,+2,+1,+2,+2,+1,+2);
  CurseurNormal: array[1..17] of ShortInt =
(08,-1, 0,-2, 0,+1, 0,+2, 0, 0,-1, 0,-2, 0,+1, 0,+2);

procedure LoadSprite1;
var
  F: File;
begin
  Ouvre ('MRPSPR.SQZ', F, 1);
  BlockRead (F, DimSprite, SizeOf (DimSprite));
  BlockRead (F, Palette[1], 333);
  BlockRead (F, Sprite1^, 32768);
  BlockRead (F, Sprite1^[32768], 32768);
  BlockRead (F, Sprite2^, 32768);
  BlockRead (F, Sprite2^[32768], 32768);
  Close (F);
  asm
  	MOV	CX,512
        MOV	SI,OFFSET [PtrSprite]
        MOV	DI,OFFSET [DimSprite]
        MOV	BX,WORD PTR [Sprite1+2]
  	XOR	DX,DX
  @LoopSetPtr:
        MOV	[SI],DX
        MOV	[SI+2],BX
  	MOV	AX,[DI]
        MUL	AH
        ADD	DX,AX
        JNC	@EndSetPtr
        MOV	BX,WORD PTR [Sprite2+2]
  @EndSetPtr:
  	ADD	SI,4
        ADD	DI,2
        LOOP	@LoopSetPtr
  end;
end;

{ Proc‚dure de fin }
procedure exitProg(Sender: Word); far;
begin
  Fin;
end;

procedure movePoint (Src, Dst: LongInt); assembler;
asm
        PUSH	DS
	MOV	AX,WORD PTR [Dst+2]
        SHL	AX,12
        ADD	AX,WORD PTR [Sprite1+2]
        MOV	ES,AX
        MOV	DI,WORD PTR [Dst]
	MOV	AX,WORD PTR [Src+2]
        SHL	AX,12
        ADD	AX,WORD PTR [Sprite1+2]
        MOV	DS,AX
        MOV	SI,WORD PTR [Src]
        MOVSB
        POP	DS
end;

procedure ChargeSprite(hdl: Word);
var
  D: Word;
begin
  filld (Decor^, 4096);
  with DimSprite[hdl] do if (Largeur <> 0) and (Hauteur <> 0) then begin
    D := Largeur*Hauteur;
    if Hdl <> 511 then asm
        MOV	BX,[Hdl]
        SHL	BX,1
        MOV	DX,WORD PTR [DimSprite+BX]
        MOV	DI,WORD PTR [SpriteY+BX]
        SHL	DI,7
        OR	DI,WORD PTR [SpriteX+BX]
        SHL	BX,1
        MOV     ES,WORD PTR [Decor+2]
        PUSH	DS
        LDS	SI,DWORD PTR [PtrSprite+BX]
        MOV	AX,DS
        MOV	BX,SI
        SHR	BX,4
        ADD	AX,BX
        MOV	DS,AX
        AND	SI,$000F
    	MOV	BL,DH
        XOR	DH,DH
    @Label4:
    	MOV	CX,DX
        REP	MOVSB
        ADD     DI,128
        SUB	DI,DX
        DEC	BL
        JNZ	@Label4
        POP	DS
      	MOV	BX,[Hdl]
        INC	BX
DB $66;	XOR	DX,DX
        MOV	DX,[D]
DB $66; SUB	WORD PTR [DimSpr],DX
    @Label0:
      	MOV	SI,BX
        SHL	SI,1
        MOV	AX,WORD PTR [DimSprite+SI]
        OR	AX,AX
        JZ	@Label1
        MUL	AH
        MOV	CX,AX
        SHL	SI,1
        LES	DI,DWORD PTR [PtrSprite+SI]
        SUB	WORD PTR [PtrSprite+SI],DX
        JNC	@Label3
        MOV	AX,WORD PTR [Sprite1+2]
        MOV	WORD PTR [PtrSprite+SI+2],AX
    @Label3:
        SUB	DI,DX
        JNC	@Label5
    	MOV	AX,WORD PTR [Sprite1+2]
        JMP	@Label6
    @Label5:
        MOV	AX,ES
    @Label6:
        MOV	SI,DI
        SHR	SI,4
        ADD	AX,SI
        MOV	ES,AX
        AND	DI,$000F
        PUSH	DS
	MOV	DS,AX
        MOV	SI,DI
        ADD	SI,DX
        REP	MOVSB
        POP	DS
      	JMP	@Label2
    @Label1:
      	SHL	SI,1
        SUB	WORD PTR [PtrSprite+SI],DX
        JNC	@Label2
        MOV	AX,WORD PTR [Sprite1+2]
        MOV	WORD PTR [PtrSprite+SI+2],AX
    @Label2:
      	INC	BX
        CMP	BX,512
        JNE	@Label0
    end;
  end;
  DimSprite[Hdl].Largeur := 0;
  DimSprite[Hdl].Hauteur := 0;
  Sprite := hdl;
  OutText8 (1, 234, 134, StrE (Sprite, 4), 250, 249,false);
end;

procedure CalculDim (var Dim: Dimmension; var PosX, PosY: Integer); assembler;
var
  x, y: integer;
asm
      	LES	DI,[Decor]
        XOR	AX,AX
        MOV	CX,16384
	REPE	SCASB
        JE	@exit
        DEC	DI
        SHR	DI,7
        MOV	BX,DI
        MOV     [y],DI
	MOV	DI,16383
        MOV	CX,16384
        STD
        REPE	SCASB
        CLD
        MOV	AX,DI
        INC	AX
        SHR	AX,7
        SUB	AX,BX
        INC	AX
        MOV	AH,AL
      	XOR	DX,DX
      	XOR	AL,AL
      	MOV	BX,127
@SearchG:
      	MOV	DI,DX
        SHL	DI,7
        MOV	CX,128
        REPE	SCASB
        SUB	CX,127
        NEG	CX
        CMP	BX,CX
        JBE	@@1
        MOV	BX,CX
@@1:	INC	DX
        TEST	DX,$80
        JZ	@SearchG
        MOV	SI,BX
        MOV	[x],BX
      	XOR	DX,DX
      	XOR	BX,BX
      	STD
@SearchD:
      	MOV	DI,DX
        SHL	DI,7
        ADD	DI,127
        MOV	CX,128
        REPE	SCASB
        CMP	BX,CX
        JAE	@@2
        MOV	BX,CX
@@2:	INC	DX
        TEST	DX,$80
        JZ	@SearchD
        CLD
        SUB	BX,SI
        INC	BX
        MOV	AL,BL
@exit:	LES	DI,[Dim]
	STOSW
	LES	DI,[PosX]
        MOV	AX,[x]
        STOSW
	LES	DI,[PosY]
        MOV	AX,[y]
        STOSW
end;

procedure ChangeSprite (Sender: Word); far;
var
  DimTmp: Dimmension;
  x, y: integer;
  D: Word;
begin
  CalculDim (DimTmp, x, y);
  if DimSpr + longint (DimTmp.Largeur) * longint (DimTmp.Hauteur) > 131072 then begin
    SpriteTemp := Sprite;
    if Sender = 36 then DrawBarreH (36);
    exit;
  end;
  if Sender <> 36 then DrawBarreH (36);
  DimSprite[Sprite].Largeur := DimTmp.Largeur;
  DimSprite[Sprite].Hauteur := DimTmp.Hauteur;
  D := DimTmp.Hauteur*DimTmp.Largeur;
  if D <> 0 then begin
    if Sprite <> 511 then asm
      	MOV	BX,511
DB $66;	XOR	DX,DX
        MOV	DX,[D]
DB $66; ADD	WORD PTR [DimSpr],DX
        STD
    @Label0:
      	MOV	SI,BX
        SHL	SI,1
        MOV	AX,WORD PTR [DimSprite+SI]
        OR	AX,AX
        JZ	@Label1
        MUL	AH
        MOV	CX,AX
        SHL	SI,1
        LES	DI,DWORD PTR [PtrSprite+SI]
        ADD	WORD PTR [PtrSprite+SI],DX
        JNC	@Label3
        MOV	AX,WORD PTR [Sprite2+2]
        MOV	WORD PTR [PtrSprite+SI+2],AX
    @Label3:
        MOV	AX,ES
        MOV	SI,DI
        SHR	SI,4
        ADD	AX,SI
        MOV	ES,AX
        AND	DI,$000F
        PUSH	DS
	MOV	DS,AX
        ADD	DI,CX
        DEC	DI
        MOV	SI,DI
        ADD	DI,DX
        REP	MOVSB
        POP	DS
      	JMP	@Label2
    @Label1:
      	SHL	SI,1
        ADD	WORD PTR [PtrSprite+SI],DX
        JNC	@Label2
        MOV	AX,WORD PTR [Sprite2+2]
        MOV	WORD PTR [PtrSprite+SI+2],AX
    @Label2:
      	DEC	BX
        CMP	BX,[Sprite]
        JNE	@Label0
    	CLD
        SHL	BX,2
        LES	DI,DWORD PTR [PtrSprite+BX]
        MOV	AX,ES
        MOV	SI,DI
        SHR	SI,4
        ADD	AX,SI
        MOV	ES,AX
        AND	DI,$000F
        PUSH	DS
        MOV     DS,WORD PTR [Decor+2]
        MOV	SI,[y]
        SHL	SI,7
        OR	SI,[x]
        MOV	DL,[DimTmp.Largeur]
        XOR	DH,DH
        MOV	BL,[DimTmp.Hauteur]
    @Label4:
    	MOV	CX,DX
        REP	MOVSB
        ADD	SI,128
        SUB	SI,DX
        DEC	BL
        JNZ	@Label4
        POP	DS
    end;
    SpriteX[Sprite] := x;
    SpriteY[Sprite] := y;
  end else begin
    SpriteX[Sprite] := 0;
    SpriteY[Sprite] := 0;
  end;
  Selection.actif := false;
  ChargeSprite (SpriteTemp);
end;

procedure ResetSprite (Sender: Word); far;
var
  i: integer;
begin
  LoadSprite1;
  ChargeSprite (Sprite);
  for i := 0 to 111 do begin
    if Palette[i].R > 8 then Palette[i+112].R := Palette[i].R - 8
      else Palette[i+112].R := 0;
    if Palette[i].V > 8 then Palette[i+112].V := Palette[i].V - 8
      else Palette[i+112].V := 0;
    if Palette[i].B > 8 then Palette[i+112].B := Palette[i].B - 8
      else Palette[i+112].B := 0;
  end;
  OutPalette (1, 239);
  DimSpr := 0;
  for i := 0 to 511 do inc (DimSpr, DimSprite[i].Largeur * DimSprite[i].Hauteur);
end;

procedure SaveSprite (Sender: Word); far;
var
  F: File;
  i: Word;
begin
  if not ChgSprOk then exit;
  i := Sprite;
  SpriteTemp := 0;
  ChangeSprite(0);
  { Fixe les segments }
  asm
  	MOV	BX,Sprite1.Word[2]
        MOV	SI,OFFSET PtrSprite + 2
        MOV	AX,DS
        MOV	ES,AX
        MOV	CX,512
  @Chg: CMP	[SI].Word,BX
  	JNE	@Spr2
  	MOV	[SI].Word,0
        ADD	SI,4
        LOOP	@Chg
        JMP	@Exit
  @Spr2:MOV	[SI].Word,1
        ADD	SI,4
        LOOP	@Chg
  @Exit:
  end;
  assign (F, 'MRPSPR.SQZ');
  rewrite (F, 1);
  BlockWrite (F, DimSprite, SizeOf (DimSprite));
  BlockWrite (F, Palette[1], 333);
  BlockWrite (F, Sprite1^, 32768);
  BlockWrite (F, Sprite1^[32768], 32768);
  BlockWrite (F, Sprite2^, 32768);
  BlockWrite (F, Sprite2^[32768], 32768);
  Close (F);
  { Fixe les segments }
  asm
  	MOV	BX,Sprite1.Word[2]
  	MOV	DX,Sprite2.Word[2]
        MOV	SI,OFFSET PtrSprite + 2
        MOV	AX,DS
        MOV	ES,AX
        MOV	CX,512
  @Chg: TEST	[SI].Word,$FF
  	JNZ	@Spr2
  	MOV	[SI],BX
        ADD	SI,4
        LOOP	@Chg
        JMP	@Exit
  @Spr2:MOV	[SI],DX
        ADD	SI,4
        LOOP	@Chg
  @Exit:
  end;
  SpriteTemp := i;
  ChangeSprite(0);
end;

procedure Scroll(Sender: Word); far;
var
  i, j: integer;
  TmpOctet: array[0..127] of Byte;
begin
  Case Sender of
    10: begin
          move (Decor^[1], Decor^, 16383);
          for i := 0 to 127 do Decor^[i shl 7+127] := 0;
        end;
    11: begin
          move (Decor^, Decor^[1], 16383);
          for i := 0 to 127 do Decor^[i shl 7] := 0;
        end;
    12: begin
          move (Decor^[128], Decor^, 127*128);
          fillChar (Decor^[127*128], 128, 0);
        end;
    13: begin
          move (Decor^, Decor^[128], 127*128);
          fillChar (Decor^, 128, 0);
        end;
    14: for j := 0 to 127 do for i := 0 to 63 do begin
          TmpOctet[1] := Decor^[j shl 7 or i];
          Decor^[j shl 7 or i] := Decor^[j shl 7 or (127-i)];
          Decor^[j shl 7 or (127-i)] := TmpOctet[1];
        end;
    15: for i := 0 to 63 do begin
          moved (Decor^[i shl 7], TmpOctet, 32);
          moved (Decor^[(127-i) shl 7], Decor^[i shl 7], 32);
          moved (TmpOctet, Decor^[(127-i) shl 7], 32);
        end;
  end;
end;

procedure ShowSprite;
var
  x, y: Word;
  xp, yp: Word;
  D: Word;
begin
  D := 1 shl echelle - 1;
  for y := 0 to 128 shr echelle - 1 do begin
    yp := ObjetInfo[3].y1 + y shl echelle;
    for x := 0 to 128 shr echelle - 1 do begin
      xp := ObjetInfo[3].x1 + x shl echelle;
      FillBox (1,xp,yp,xp+d,yp+d,Decor^[(y + screeny) shl 7 or (x + screenx)]);
    end;
  end;
  for x := 0 to 127 do for y :=  0 to 127 do
    PutPixel (1, ObjetInfo[1].x1 + x, ObjetInfo[1].y1 + y, decor^[y shl 7 or x]);
end;

procedure SetColor(Sender: Word); far;
begin
  Color := GetPixel (1, MouseX, MouseY);
  OutText8 (1, 287, 65, StrE (Color, 3), 247, 0,false);
  FillBox (1, 272, 81, 308, 94, Color);
end;

procedure SetPutPointMode(Sender: Word); far;
begin
  if PointMode = Select then begin
    OutText8 (1, 164, 153, #239, 246,tsp,false);
    if Selection.actif then begin
      moved (Decor^, Decor^[$4000], $1000);
      Selection.actif := false;
    end;
  end else OutText8 (1, 68 + PointMode shl 4, 153, char (248 + PointMode), 246,tsp,false);
  ObjetInfo[PointMode+27].Color := 246;
  PointMode := Sender - 27;
  ObjetInfo[Sender].Color := 244;
end;

procedure SetScreen;
var
  x, y: integer;
begin
  if HandleNow = 1 then begin
    x := MouseXr;
    y := MouseYr;
    if (x >= 0)                    and (x < 64 shr Echelle)        then ScreenX := 0;
    if (x >= 64 shr Echelle)       and (x <= 127 - 64 shr Echelle) then ScreenX := MouseXr - 64 shr Echelle;
    if (x >= 128 - 64 shr Echelle) and (x <= 127)                  then ScreenX := 128 - 128 shr Echelle;
    if (y >= 0)                    and (y < 64 shr Echelle)        then ScreenY := 0;
    if (y >= 64 shr Echelle)       and (y <= 127 - 64 shr Echelle) then ScreenY := MouseYr - 64 shr Echelle;
    if (y >= 128 - 64 shr Echelle) and (y <= 127)                  then ScreenY := 128 - 128 shr Echelle;
  end else if (Timer > TimScreen) then begin
    x := (MouseXr shr Echelle);
    y := (MouseYr shr Echelle);
    TimScreen := Timer;
    if (x < 32 shr echelle) and (ScreenX > 0) then dec (ScreenX)
    else if (x > 96 shr echelle) and (ScreenX < 128 - 128 shr echelle) then inc (ScreenX);
    if (y < 32 shr echelle) and (ScreenY > 0) then dec (ScreenY)
    else if (y > 96 shr echelle) and (ScreenY < 128 - 128 shr echelle) then inc (ScreenY);
  end;
end;

function Signe (i: integer): integer; assembler;
asm
	MOV	AX,[i]
	CMP	AX,0
        JE	@Exit
        JL	@Moins
        MOV	AX,1
        JMP	@Exit
@Moins: MOV	AX,$FFFF
@Exit:
end;

procedure range (a, b: word; var a1, b1: integer); assembler;
asm
	MOV	AX,[a]
        MOV	BX,[b]
        CMP	AX,BX
        JG	@Label1
        LES	DI,[a1]
        MOV	ES:[DI],AX
        LES	DI,[b1]
        MOV	ES:[DI],BX
	JMP	@Exit
@Label1:LES	DI,[a1]
        MOV	ES:[DI],BX
        LES	DI,[b1]
        MOV	ES:[DI],AX
@Exit:
end;

procedure MakeDrawPoint;
var
  x, y: integer;
  Dx, Dy: word;
  D, aincr, bincr: Integer;
  TL: Byte;
  Sx, Sy: Integer;
  rx1, rx2, ry1, ry2: integer;
  Perimetre, Rayon, angle: integer;
begin with Draw do begin
  moved (Decor^[$4000], Decor^, 4096);
  Dx := abs (integer(x2 - x1));
  Dy := abs (integer(y2 - y1));
  range (x1, x2, rx1, rx2);
  range (y1, y2, ry1, ry2);
  Sx := Signe (x2 - x1);
  Sy := Signe (y2 - y1);
  case PointMode of
    Line: begin
        if Dx > Dy then begin
          TL := 1;
          D := Dy shl 1 - Dx;
          Aincr := (Dx - Dy) shl 1;
          Bincr := Dy shl 1;
        end else begin
          TL := 2;
          D := Dx shl 1 - Dy;
          Aincr := (Dy - Dx) shl 1;
          Bincr := Dx shl 1;
        end;
        x := x1;
        y := y1;
        Decor^[y shl 7 or x] := Color;
        repeat
          if TL = 1 then begin
            x := x + Sx;
            if D < 0 then D := D + Bincr
            else begin
              D := D - Aincr;
              y := y + Sy;
            end;
          end else begin
            y := y + Sy;
            if D < 0 then D := D + Bincr
            else begin
              D := D - Aincr;
              x := x + Sx;
            end;
          end;
          Decor^[y shl 7 or x] := Color;
        until (x = x2) and (y = y2);
    end;
    Box: begin
           fillchar (Decor^[y1 shl 7 or rx1], Dx, color);
           fillchar (Decor^[y2 shl 7 or rx1], Dx, color);
           for y := ry1 to ry2 do begin
             Decor^[y shl 7 or rx1] := color;
             Decor^[y shl 7 or rx2] := color;
           end;
         end;
    Boxf: for y := ry1 to ry2 do fillchar (Decor^[y shl 7 or rx1], Dx+1, color);
    Circle: begin
      if (dx = 0) and (dy = 0) then begin
        Decor^[y1 shl 7 or x1] := Color;
        exit;
      end;
      Rayon := Round (Sqrt (Sqr (Dx) + Sqr (Dy)));
      Perimetre := Round (Rayon * Pi / 2);
      for angle := 0 to Perimetre do begin
        x := round (cos (angle * Pi / (perimetre shl 1)) * rayon);
        y := round (sin (angle * Pi / (perimetre shl 1)) * rayon);
        if x1 + x < 128 then begin
          if y1 + y < 128 then
            decor^[(x + x1) or (y + y1) shl 7] := color;
          if y1 - y >= 0 then
            decor^[(x + x1) or (y1 - y) shl 7] := color;
        end;
        if x1 - x >= 0 then begin
          if y1 + y < 128 then
            decor^[(x1 - x) or (y + y1) shl 7] := color;
          if y1 - y >= 0 then
            decor^[(x1 - x) or (y1 - y) shl 7] := color;
        end;
      end;
    end;
    Circlef: begin
      if (dx = 0) and (dy = 0) then begin
        Decor^[(y1 shl 7) or x1] := Color;
        exit;
      end;
      Rayon := Round (Sqrt (Sqr (Dx) + Sqr (Dy)));
      Perimetre := Round (Rayon * Pi / 2);
      for angle := 0 to Perimetre do begin
        x := round (cos (angle * Pi / (perimetre shl 1)) * rayon);
        y := round (sin (angle * Pi / (perimetre shl 1)) * rayon);
        if x1 - x < 0 then rx1 := 0 else rx1 := x1 - x;
        if x1 + x >= 128 then rx2 := 127 else rx2 := x1 + x;
        if y1 - y >= 0 then fillchar (decor^[rx1 or (y1 - y) shl 7], rx2 - rx1 + 1, color);
        if y1 + y < 128 then fillchar (decor^[rx1 or (y1 + y) shl 7], rx2 - rx1 + 1, color);
      end;
    end;
  end;
end; end;

procedure GetSel;
var
  rx1, rx2, ry1, ry2: integer;
  y: integer;
begin
  range (Selection.x1, Selection.x2, rx1, rx2);
  range (Selection.y1, Selection.y2, ry1, ry2);
  Selection.Largeur := rx2 - rx1 + 1;
  Selection.Hauteur := ry2 - ry1 + 1;
  moved (Decor^, Decor^[$4000], $1000);
  for y := ry1 to ry2 do begin
    move (Decor^[y shl 7 or rx1], Decor^[$8000 + (y - ry1) shl 7], Selection.Largeur);
    fillchar (Decor^[$4000 or y shl 7 or rx1], Selection.Largeur, 0);
  end;
end;

procedure PutSel;
var
  x, y: integer;
  x1, y1, x2, y2: integer;
  i: byte;
begin
  range (Selection.x1, Selection.x2, x1, x2);
  range (Selection.y1, Selection.y2, y1, y2);
  moved (Decor^[$4000], Decor^, $1000);
  for y := 0 to Selection.Hauteur - 1 do for x := 0 to Selection.Largeur - 1 do begin
    i := Decor^[$8000+y shl 7 or x];
    if (i <> 0) and (y1+y>=0) and (y1+y<=127) and (x1+x>=0) and (x1+x<=127) then Decor^[(y1+y) shl 7 or (x1+x)] := i;
  end;
end;

procedure testDrawPoint;
var
  x, y: integer;
begin with Draw do begin
  if HandleNow = 1 then begin
    x := MouseXr;
    y := MouseYr;
  end else begin
    x := (MouseXr shr Echelle) + screenx;
    y := (MouseYr shr Echelle) + screeny;
  end;
  if not MouseBL then begin
    if Statut = 3 then begin
      Statut := 0;
      SetWindowMouse (0, 0, 319, 199);
      if Selection.actif and not Deplace then GetSel;
      Deplace := false;
      exit;
    end else if Statut = 1 then Statut := 2;
  end;
  if (Statut = 10) and not MouseBR then begin
    Statut := 0;
    if PointMode = Select then begin
       Selection.Actif := false;
       moved (Decor^, Decor^[$4000], $1000);
       Deplace := false;
    end else moved (Decor^[$4000], decor^, 4096);
    SetWindowMouse (0, 0, 319, 199);
  end else begin
    if (Timer > T) and (HandleNow = 3) then begin
      T := Timer;
      if (x = ScreenX) and (ScreenX > 0) then begin dec (ScreenX); dec (x); end;
      if (y = ScreenY) and (ScreenY > 0) then begin dec (ScreenY); dec (y); end;
      if (x = ScreenX + 128 shr Echelle - 1) and (ScreenX < 128 - 128 shr Echelle) then begin inc (ScreenX); inc (x); end;
      if (y = ScreenY + 128 shr Echelle - 1) and (ScreenY < 128 - 128 shr Echelle) then begin inc (ScreenY); inc (y); end;
    end;
    if (x2 <> x) or (y2 <> y) then begin
      if Deplace then begin
        Selection.x1 := Selection.x1 + (x - x2);
        Selection.x2 := Selection.x2 + (x - x2);
        Selection.y1 := Selection.y1 + (y - y2);
        Selection.y2 := Selection.y2 + (y - y2);
        x2 := x; y2 := y;
        PutSel;
        exit;
      end;
      x2 := x; y2 := y;
      if PointMode = Select then begin
        Selection.x2 := x2;
        Selection.y2 := y2;
      end else  MakeDrawPoint;
    end;
  end;
end; end;

function MouseInSel: Boolean;
var
  x1, y1, x2, y2: integer;
  x, y: integer;
  c: Byte;
begin
  range (Selection.x1, Selection.x2, x1, x2);
  range (Selection.y1, Selection.y2, y1, y2);
  if HandleNow = 1 then begin
    x := MouseXr;
    y := MouseYr;
  end else begin
    x := MouseXr shr Echelle + screenx;
    y := MouseYr shr Echelle + screeny;
  end;
  MouseInSel := (x > x1) and (x < x2) and (y > y1) and (y < y2) and Selection.Actif;
end;

procedure PutPoint(Sender: Word); far;
var
  x, y: Word;
begin with Draw do begin
  { Calcul de la position }
  if Sender = 1 then begin
    x := MouseXr;
    y := MouseYr;
  end else begin
    x := MouseXr shr Echelle + screenx;
    y := MouseYr shr Echelle + screeny;
  end;
  { Si ce n'est qu'un point }
  if PointMode = Pixel then begin
    Decor^[y shl 7 or x] := Color;
    exit;
  end;
  { Sinon on fait le dessin }
  if Statut = 0 then begin
    Statut := 1;
    x1 := x; y1 := y;
    x2 := x; y2 := y;
    if Sender = 3 then SetWindowMouse (1, 1, 128, 128)
      else  SetWindowMouse (139, 1, 266, 128);
    if PointMode = Select then begin
      Deplace := MouseInSel;
      if not MouseInSel then begin
        Selection.actif := true;
        Selection.x1 := x1;
        Selection.y1 := y1;
        Selection.x2 := x2;
        Selection.y2 := y2;
      end;
    end else begin
      moved (Decor^, Decor^[$4000], 4096);
      Decor^[y shl 7 or x] := Color;
    end;
  end else if Statut = 2 then Statut := 3;
end; end;

procedure GetColor(Sender: Word); far;
var
  x, y: word;
begin
  if Draw.Statut <> 0 then Draw.Statut := 10
    else begin
      if (PointMode = Select) and not Deplace then begin
        moved (Decor^, Decor^[$4000], $1000);
        Selection.actif := false;
        exit;
      end;
      if Sender = 1 then begin
        x := MouseXr;
        y := MouseYr;
      end else begin
        x := MouseXr shr Echelle + screenx;
        y := MouseYr shr Echelle + screeny;
      end;
      Color := Decor^[y shl 7 or x];
      OutText8 (1, 287, 65, StrE (Color, 3), 247, 0,false);
      FillBox (1, 272, 81, 308, 94, Color);
  end;
end;

procedure TmpPoint (x, y: integer; c, c1: byte);
begin
  if (x < 0) or (x > 127) or (y < 0) or (y > 127) then exit;
  PutPixel (1, ObjetInfo[1].x1 + x, ObjetInfo[1].y1 + y, c);
  if (x < screenx) or (y < screeny) or (x >= screenx + 128 shr echelle) or (y >= screeny + 128 shr echelle) then exit;
  FillBox (1, ObjetInfo[3].x1 + (x-screenx) shl echelle, ObjetInfo[3].y1 + (y-screeny) shl echelle,
              ObjetInfo[3].x1 + (x-screenx+1) shl echelle-1, ObjetInfo[3].y1 + (y-screeny+1) shl echelle-1, c1);
end;
{assembler;
asm
        MOV	ES,WORD PTR [Ecran+6]
	MOV	AX,[y]
        CMP	AX,0
        JL	@GPoint
        CMP	AX,127
        JG	@GPoint
        INC	AX
        MOV	DI,AX
        SHL	AX,8
        SHL	DI,6
        ADD	DI,AX
        MOV	AX,[x]
        CMP	AX,0
        JL	@GPoint
        CMP	AX,127
        JG	@GPoint
	ADD	DI,AX
        ADD	DI,139
	MOV	AL,[c]
        STOSB
@GPoint:MOV	CL,[echelle]
	MOV	AX,[y]
        SUB	AX,[ScreenY]
	SHL	AX,CL
        CMP	AX,0
        JL	@exit
        CMP	AX,127
        JG	@exit
        INC	AX
        MOV	DI,AX
        SHL	AX,8
        SHL	DI,6
        ADD	DI,AX
	MOV	AX,[x]
	SUB	AX,[ScreenX]
        SHL	AX,CL
        CMP	AX,0
        JL	@exit
        CMP	AX,127
        JG	@exit
        INC	AX
        ADD	DI,AX
        MOV	AL,[c1]
        MOV	AH,AL
        MOV	DX,320
        MOV	BX,1
        SHL	BX,CL
        SUB	DX,BX
        MOV	BH,BL
        SHR	BH,1
@LoopLigne:
        MOV	CL,BH
        REP	STOSW
        ADD	DI,DX
        DEC	BL
        JNZ	@LoopLigne
@exit:
end;}

procedure PutCurseur (x, y: integer; var curseur: array of ShortInt);
var
  P, TmpX, TmpY: integer;
begin
  for P := 1 to curseur[0] do begin
    TmpX := x + curseur[P shl 1-1];
    TmpY := y + curseur[P shl 1];
    TmpPoint (TmpX, TmpY, 250, Decor^[TmpX or TmpY shl 7] + 112);
  end;
end;

procedure DrawSel;
var
  x, y: integer;
  x1, y1, x2, y2: integer;
  i: byte;
begin
  range (Selection.x1, Selection.x2, x1, x2);
  range (Selection.y1, Selection.y2, y1, y2);
  i := not timer;
  for x := x1 to x2 do begin
    if i and 2 <> 0 then TmpPoint (x, y1, 249,249); inc (i); end;
  dec (i);
  for y := y1 to y2 do begin
    if i and 2 <> 0 then TmpPoint (x2, y, 249,249); inc (i); end;
  dec (i);
  for x := x2 downto x1 do begin
    if i and 2 <> 0 then TmpPoint (x, y2, 249,249); inc (i); end;
  dec (i);
  for y := y2 downto y1 do begin
    if i and 2 <> 0 then TmpPoint (x1, y, 249,249); inc (i); end;
end;

procedure Couper(Sender: Word); far;
begin
  if not Selection.actif then exit;
  Selection.actif := false;
  moved (Decor^[$4000], Decor^, $1000);
  moved (Decor^[$8000], Decor^[$C000], $1000);
  with Selection do begin
    LargeurCut := Largeur;
    HauteurCut := Hauteur;
  end;
end;

procedure Copier(Sender: Word); far;
begin
  if not Selection.actif then exit;
  moved (Decor^[$8000], Decor^[$C000], $1000);
  with Selection do begin
    LargeurCut := Largeur;
    HauteurCut := Hauteur;
  end;
end;

procedure Coller(Sender: Word); far;
begin with Selection do begin
  if (LargeurCut = 0) or (HauteurCut = 0) then exit;
  if PointMode <> Select then begin
    SetPutPointMode (33);
    OutText8 (1, 164, 153, #239, 244,tsp,false);
  end;
  actif := true;
  moved (Decor^[$C000], Decor^[$8000], $1000);
  moved (Decor^, Decor^[$4000], $1000);
  Largeur := LargeurCut;
  Hauteur := HauteurCut;
  x1 := 0;
  y1 := 0;
  x2 := Largeur - 1;
  y2 := Hauteur - 1;
  PutSel;
end; end;

procedure PlusEchelle(Sender: Word); far;
begin
  if Echelle < 4 then inc (Echelle);
end;

procedure MoinsEchelle(Sender: Word); far;
begin
  if Echelle > 1 then dec (Echelle);
end;

procedure Remplace (Page, X1, Y1, X2, Y2: Word; ColorSrc, Color: Byte);
var
  x, y: word;
begin
  for y := y1 to y2 do for x := x1 to x2 do
    if GetPixel (Page, x, y) = ColorSrc then PutPixel (Page, x, y, Color);
end;

procedure UpdateColor(Sender: Word); far;
begin
  with Palette[Color] do begin
    Red   := R;
    Green := V;
    Blue  := B;
  end;
  Remplace (1, 121, 63, 134, 126, 248, 11);
  if Red <> 0 then Remplace (1, 121, 126 - Red, 134, 126, 11, 248);
  Remplace (1, 153, 63, 166, 126, 243, 11);
  if Green <> 0 then Remplace (1, 153, 126 - Green, 166, 126, 11, 243);
  Remplace (1, 185, 63, 198, 126, 242, 11);
  if Blue <> 0 then Remplace (1, 185, 126 - Blue, 198, 126, 11, 242);
  OutText8 (1, 121, 50, StrE (Red, 2), 248, 249, false);
  OutText8 (1, 153, 50, StrE (Green, 2), 243, 249, false);
  OutText8 (1, 185, 50, StrE (Blue, 2), 242, 249, false);
end;

procedure PutColor(Sender: Word); far;
begin
  SetPalette (Color, Red, Green, Blue);
  with Palette[Color] do begin
    R := Red;
    V := Green;
    B := Blue;
  end;
  UpdateColor(Sender);
end;

procedure SetRVB(Sender: Word); far;
begin
  case Sender of
    16: Red := 63 - MouseYr;
    17: Green := 63 - MouseYr;
    18: Blue := 63 - MouseYr;
  end;
  PutColor (Sender);
end;

procedure DessineTube (Handle, x, y: Word);
begin
  LineV (1, x, y, y + 58, 9);
  LineV (1, x + 15, y, y + 58, 9);
  BordCircleC (1, x + 8, y + 58, 7, 1, 9);
  BordCircleC (1, x + 7, y + 58, 7, 2, 9);
  FillCircle (1, x + 8, y + 58, 6, 1, 11);
  FillCircle (1, x + 7, y + 58, 6, 2, 11);
  FillBox (1, x + 1, y + 2, x + 14, y + 58, 11);
  FillBox (1, x + 3, y +  8, x + 4, y + 10, 249);
  FillBox (1, x + 3, y + 12, x + 4, y + 13, 249);
  FillBox (1, x + 6, y +  8, x + 7, y + 10, 249);
  FillBox (1, x + 6, y + 12, x + 7, y + 13, 249);
  FillCircle (2, x + 8, y + 58, 7, 1, Handle);
  FillCircle (2, x + 7, y + 58, 7, 2, Handle);
  FillBox (2, x, y + 2, x + 15, y + 58, Handle);
  with ObjetInfo[handle] do begin
    Attribut := EventOnPush + CUrsorMain;
    Y1 := y + 2;
    Event := SetRVB;
  end;
end;

procedure IDC(Sender: Word); far;
begin
  case Sender of
    10: if Red < 63 then inc (Red);
    11: if Red > 0 then dec (Red);
    12: if Green < 63 then inc (Green);
    13: if Green > 0 then dec (Green);
    14: if Blue < 63 then inc (Blue);
    15: if Blue > 0 then dec (Blue);
  end;
  PutColor (Sender);
end;

procedure OkColor(Sender: Word); far;
begin
  FinColor := True;
end;

procedure DrawPage; forward;

procedure ModifyColor(Sender: Word); far;
var
  x: Integer;
begin
      SetColor(0);
      { Pour la palette }
      MakeWindow (92, 127, 'n'#240+Str(Color,0));
      DessineTube (16, 120, 61);
      DessineTube (17, 152, 61);
      DessineTube (18, 184, 61);
      MakeBouton (10, 120, 131, '+', 246, IDC);
      MakeBouton (11, 120, 147, '-', 246, IDC);
      MakeBouton (12, 152, 131, '+', 246, IDC);
      MakeBouton (13, 152, 147, '-', 246, IDC);
      MakeBouton (14, 184, 131, '+', 246, IDC);
      MakeBouton (15, 184, 147, '-', 246, IDC);
      for x := 10 to 15 do with ObjetInfo[x] do begin
        Attribut := Attribut or EventOnPush;
        Pas1 := 7;
        Pas2 := 0;
      end;
      DrawBox (19, 116, 48, 142, 58, 249);
      DrawBox (20, 148, 48, 176, 58, 249);
      DrawBox (25, 180, 48, 204, 58, 249);
      MakeValeur (19, 118, 50, Red, MaxRGB, 248, 249, PutColor);
      MakeValeur (20, 150, 50, Green, MaxRGB, 243, 249, PutColor);
      MakeValeur (25, 182, 50, Blue, MaxRGB, 242, 249, PutColor);
      OutText8(1, 191, 39, 'x', 240, tsp, false);
      FillBox(2, 191, 39, 198, 46, 26);
      with ObjetInfo[26] do begin
      TxtX := 191;
      TxtY := 240;
      Text := 'x';
      Color := 240;
      Attribut := TextLight + CursorMain;
      Event := OkColor;
      PtrOn := @ObjetAble;
      end;
      UpdateColor(0);
      FinColor := False;
      repeat
        Update;
      until FinColor;
   DrawPage;
end;

procedure DrawPage;
var
  i, x, y: Integer;
begin
  Cls(1,0);
  { Boite Pour le sprie en taille r‚el }
  MakeBox (1, 138, 0, 267, 129, 0, CursorMain+EventOnPush, PutPoint, GetColor);
  MakeBouton (2, 0, 184, 'Quitter', 246, exitProg);
  MakeBox (3, 0, 0, 129, 129, 0, CursorMain+EventOnPush, PutPoint, GetColor);
  Echelle := 3;
  MakeBouton (4, 64, 165, 'Cut', 246, Couper);
  MakeBouton (5, 96, 165, 'Copy', 246, Copier);
  MakeBouton (6, 136, 165, 'Past', 246, Coller);
  MakeBouton (7, 176, 149, '+', 246, PlusEchelle);
  MakeBouton (8, 176, 165, '-', 246, MoinsEchelle);
  MakeBouton (10, 00, 149, #246, 246, Scroll);
  MakeBouton (11, 16, 149, #247, 246, Scroll);
  MakeBouton (12, 32, 149, #244, 246, Scroll);
  MakeBouton (13, 48, 149, #245, 246, Scroll);
  for i := 10 to 13 do with ObjetInfo[i] do begin
    Attribut := Attribut or EventOnPush;
    Pas1 := 5;
    Pas2 := 1;
  end;
  MakeBouton (14, 00, 165, #247#32#246, 246, Scroll);
  MakeBouton (15, 32, 165, #245#32#244, 246, Scroll);
  MakeBox (16, 275, 0, 308, 57, 0, CursorMain+EventOnPush, SetColor, ModifyColor);
  for y := 0 to 13 do for x := 0 to 7 do
    FillBox (1, 276 + x shl 2, 1+y shl 2, 279 + x shl 2, 4 + y shl 2, y shl 3 or x);
  OutText8 (1, 271, 65, 'n'#240'  0', 247,tsp,false);
  DrawBox (0, 271, 80, 309, 95, 0);
  MakeBouton (27, 064, 149, #248, 244, SetPutPointMode);
  MakeBouton (28, 080, 149, #249, 246, SetPutPointMode);
  MakeBouton (29, 096, 149, #250, 246, SetPutPointMode);
  MakeBouton (30, 112, 149, #251, 246, SetPutPointMode);
  MakeBouton (31, 128, 149, #252, 246, SetPutPointMode);
  MakeBouton (32, 144, 149, #253, 246, SetPutPointMode);
  MakeBouton (33, 160, 149, #239, 246, SetPutPointMode);
  DrawBox    (0,  200, 149, 253, 164, 250);
  OutText8   (1,  223, 153, ':', 243,tsp,false);
  EcritNombre(1,  203, 152, '000 000', 243, 250, 4, 4, 1, 1);
  OutText8   (1,  200, 169, 'n'#240'  0', 247,tsp,false);
  DrawBox    (0,  240, 165, 253, 180, 0);
  MakeBouton (34, 64, 184, 'Enregistrer', 246, SaveSprite);
  MakeBouton (35, 160, 184, 'Recharger', 246, ResetSprite);
  MakeBarreH (36{,37,38}, 0, 130, 231, SpriteTemp, MaxSprite, 5, 1, 1, ChangeSprite);
  MakeBox (39, 232, 130, 267, 145, 249, 0, nil, nil);
  MakeValeur (39, 234, 134, SpriteTemp, MaxSprite, 250, 249, ChangeSprite);
  for i := 36 to 39 do ObjetInfo[i].PtrOn := @ChgSprOk;
end;

var
  i: Integer;
  offset: Word;
  x, y: integer;
  DimTmp: Dimmension;

begin
  InitGraph(1);
  Page_not_display := 3;
  AlloueBuffer (Sprite1);
  AlloueBuffer (Sprite2);
  LoadSprite1;
  for i := 0 to 111 do begin
    if Palette[i].R > 8 then Palette[i+112].R := Palette[i].R - 8
      else Palette[i+112].R := 0;
    if Palette[i].V > 8 then Palette[i+112].V := Palette[i].V - 8
      else Palette[i+112].V := 0;
    if Palette[i].B > 8 then Palette[i+112].B := Palette[i].B - 8
      else Palette[i+112].B := 0;
  end;
  OutPalette (1, 239);

  for i := 0 to 511 do inc (DimSpr, DimSprite[i].Largeur * DimSprite[i].Hauteur);
{  y := 0;
  for i :=0 to 28 do for x := 0 to DimSprite[i].Largeur * DimSprite[i].Hauteur do begin
  inc (y);
  case Sprite1^[y] of
    8: Sprite1^[y] := 32;
    25:Sprite1^[y] := 23;
  end;
  end;}

  DrawPage;
  ChgSprOk := true;
  ChargeSprite (0);

  repeat
    Update;

      { Continu le dessin en cours }
      If (HandleNow in [1,3]) and MouseBC then SetScreen;
      if (Draw.Statut <> 0) and (HandleNow in [1,3]) then TestDrawPoint;
      { Calcul de la position }
      case HandleNow of
        1: begin
             x := MouseXr;
             y := MouseYr;
           end;
        3 : begin
              x := MouseXr shr Echelle + screenx;
              y := MouseYr shr Echelle + screeny;
            end;
      end;
      { Calcul les dimmensions du sprites }
      CalculDim (DimTmp, i, i);
      with DimTmp do begin
        OutText8 (1, 260, 149, StrE(Largeur,3)+'x'+StrE(Hauteur,3), 247, 0,false);
        OutText8 (1, 264, 157, '='+StrE(Largeur*Hauteur,5), 247, 0,false);
        ChgSprOk := DimSpr + longint (Largeur) * longint (Hauteur) <= 131072;
        if  not ChgSprOk then
          OutText8 (1, 257, 165, ' Satur‚ ' , 248 * (Timer shr 2 and 1), 0,false)
        else OutText8 (1, 261, 165, '/'+StrE(DimSpr + Largeur*Hauteur,6), 247, 0,false);
      end;
      { Affiche le sprite }
      ShowSprite;
      { Si la s‚l‚ction est active, alors on l'affiche }
      if Selection.Actif then DrawSel;
      { affiche la position de la souris dans le grand sprites }
      { si elle se trouve dans le petit                        }
      if HandleNow in [1,3] then begin
  	if Timer and 2 = 2 then if HandleNow = 1 then TmpPoint (x, y, 244,249)
          else TmpPoint (x, y, 249,244);
	if not (MouseBC or MouseBL) and MouseInSel then PutCurseur (x, y, CurseurInSel)
	else if MouseBL then PutCurseur (x, y, CurseurClic)
	else if MouseBC then PutCurseur (x, y, CurseurSetScreen)
	else PutCurseur (x, y, CurseurNormal);
        EcritNombre(1,  203, 152, Str (x, 3) + ' ' + Str (y, 3), 243, 250, 4, 4, 1, 1);
        OutText8      (1,  216, 169, StrE (Decor^[x or y shl 7],3), 247, 0,false);
        FillBox    (1,  241, 166, 252, 179, Decor^[x or y shl 7]);
      end;

  until false;

end.
