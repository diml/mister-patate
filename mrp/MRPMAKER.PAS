{$G+,N+}
{ Editeur de sprite }
program MrpMaker;

uses MrpStr,  MrpInit, MrpVga,   MrpJeu,  MrpPal, MrpMenu, MrpLoad, MrpTps,
     MrpText, MrpKey,  MrpGraph, MrpCode, MrpSon;

var
  Mode: Byte;           { Mode actuel 					     }
  EtatPiege: Byte;      { Pour les piŠges 				     }
  ColorTimer: LongInt;  { Pour les couleurs 				     }
  CaseMode: Byte;       { Mode de tracage des cases 			     }
  HandleCase: Word;     { Case s‚lectionn‚e 				     }
  ShowPlan: array[0..3] of WordBool;  { Est-ce qu'on affiche le plan 1 ?     }
  Draw: record 		{ Information sur les dessins 			     }
    Statut: Byte; 	{ * Etat du dessin 				     }
    X1, Y1: Word; 	{ * D‚but du dessin 				     }
    X2, Y2: Word; 	{ * fin du dessin 				     }
    Plan  : ^Buffer;    { * Plan de dessin                                   }
    T     : LongInt;    { * D‚lai pour faire scroller le niveau	             }
  end;                  {						     }
  Color: Word;          { Couleur actuelle 				     }
  Red  : Word;          { Quantite de rouge de Color 			     }
  Green: Word;		{ Quantite de vert de Color 			     }
  Blue : Word;          { Quantite de bleu de Color 			     }
  ColorOn: Boolean;     { Est-ce que l'on peut modifier les couleurs ?       }
  PointMode: Byte;      { Mode de tracage des points 			     }
  TmpSprite: array[0..255] of Byte;    { Sprite temporaire                                  }
  NextLine: Word;
  ObjetActu: Word;
  SpriteObjA: Word;
  SpriteActu: Word;
  PlaceObjet: Boolean;
  Vitesse: Word;
  ObjetOn: Boolean;
  MusiqueFile: Byte;
  PeurVide: WordBool;

const
  SpriteBonnus: array[0..6*256-1] of Byte =(
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E8,$00,
$00,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$E9,$EA,$E8,
$00,$1D,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$E9,$00,
$00,$1D,$1F,$04,$04,$04,$04,$04,$04,$04,$04,$04,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$0B,$0B,$1E,$1E,$1E,$1E,$1E,$1E,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$0B,$0B,$19,$19,$15,$1E,$1E,$1E,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$0B,$1E,$1E,$1E,$1E,$0C,$1E,$1F,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$1E,$1E,$19,$1E,$0C,$0C,$0C,$1E,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$1E,$1E,$19,$1E,$0C,$0C,$0C,$1E,$1E,$1F,$1D,$00,
$00,$1D,$1F,$04,$1E,$17,$1E,$1E,$19,$19,$1E,$1E,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$1E,$17,$17,$1E,$1E,$1E,$1E,$1E,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$1E,$17,$1E,$1E,$1F,$1E,$19,$1E,$1F,$1F,$1D,$00,
$00,$1D,$1F,$04,$1E,$1F,$1E,$1E,$1F,$1F,$19,$1E,$1F,$1F,$1D,$00,
$00,$E1,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1D,$00,
$E0,$E1,$E1,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$00,
$00,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E8,$00,
$00,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$E9,$EA,$E8,
$00,$08,$1F,$1F,$1F,$1F,$14,$14,$14,$14,$1F,$1F,$1F,$1F,$E9,$00,
$00,$08,$1F,$1F,$1F,$14,$0C,$0D,$0D,$0C,$14,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$14,$14,$14,$14,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$14,$17,$17,$14,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$14,$17,$17,$14,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$14,$17,$20,$20,$17,$14,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$14,$18,$20,$0E,$20,$17,$18,$14,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$14,$17,$17,$20,$20,$20,$17,$14,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$14,$17,$17,$17,$17,$20,$17,$14,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$14,$18,$20,$20,$20,$20,$18,$14,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$14,$20,$17,$20,$17,$14,$1F,$1F,$1F,$08,$00,
$00,$E1,$1F,$1F,$1F,$1F,$14,$14,$14,$14,$1F,$1F,$1F,$1F,$08,$00,
$E0,$E1,$E1,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$00,
$00,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E8,$00,
$00,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$E9,$EA,$E8,
$00,$08,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$E9,$00,
$00,$08,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$14,$14,$14,$1F,$1F,$08,$00,
$00,$08,$1F,$14,$14,$14,$14,$14,$14,$1D,$1D,$1D,$14,$1F,$08,$00,
$00,$08,$14,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$14,$1D,$14,$08,$00,
$00,$08,$1F,$14,$1D,$1D,$1D,$14,$14,$1D,$1D,$1D,$14,$1F,$08,$00,
$00,$08,$1F,$14,$1D,$14,$1D,$14,$1F,$14,$14,$14,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$14,$1F,$14,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$08,$00,
$00,$08,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$08,$00,
$00,$E1,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$08,$00,
$E0,$E1,$E1,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$00,
$00,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E8,$00,
$00,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$E9,$EA,$E8,
$00,$1D,$1F,$1F,$1F,$1F,$14,$14,$14,$14,$1F,$1F,$1F,$1F,$E9,$00,
$00,$1D,$1F,$1F,$1F,$14,$02,$02,$02,$02,$14,$1F,$1F,$1F,$1D,$00,
$00,$1D,$1F,$1F,$14,$02,$14,$14,$14,$14,$02,$14,$1F,$1F,$1D,$00,
$00,$1D,$1F,$1F,$14,$02,$14,$1F,$1F,$14,$02,$14,$1F,$1F,$1D,$00,
$00,$1D,$1F,$1F,$14,$02,$14,$14,$14,$14,$02,$14,$1F,$1F,$1D,$00,
$00,$1D,$1F,$14,$02,$02,$02,$02,$02,$02,$02,$02,$14,$1F,$1D,$00,
$00,$1D,$1F,$14,$02,$14,$02,$04,$04,$02,$14,$02,$14,$1F,$1D,$00,
$00,$1D,$1F,$14,$02,$02,$02,$02,$04,$02,$02,$02,$14,$1F,$1D,$00,
$00,$1D,$1F,$14,$02,$02,$02,$02,$04,$02,$02,$02,$14,$1F,$1D,$00,
$00,$1D,$1F,$14,$02,$14,$02,$04,$02,$02,$14,$02,$14,$1F,$1D,$00,
$00,$1D,$1F,$1F,$14,$02,$02,$02,$02,$02,$02,$14,$1F,$1F,$1D,$00,
$00,$E1,$1F,$1F,$1F,$14,$14,$14,$14,$14,$14,$1F,$1F,$1F,$1D,$00,
$E0,$E1,$E1,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$00,
$00,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$04,$04,$04,$04,$04,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$04,$04,$0A,$0A,$0A,$0A,$0A,$04,$04,$00,$00,$00,$00,
$00,$00,$04,$0A,$0A,$EC,$EC,$EC,$EC,$EC,$0A,$0A,$04,$00,$00,$00,
$00,$04,$0A,$EC,$EC,$EC,$EC,$1B,$EC,$ED,$ED,$ED,$0A,$04,$00,$00,
$00,$04,$0A,$EC,$EC,$EC,$1B,$19,$0A,$ED,$ED,$ED,$1B,$04,$00,$00,
$04,$0A,$EC,$EC,$EC,$1B,$19,$19,$0A,$ED,$ED,$ED,$EB,$1B,$04,$00,
$04,$0A,$EC,$EC,$EC,$EC,$1B,$19,$0A,$ED,$ED,$EB,$EB,$1B,$04,$00,
$04,$0A,$EC,$EC,$EC,$ED,$1B,$19,$0A,$ED,$EB,$EB,$EB,$1B,$04,$00,
$04,$0A,$EC,$EC,$ED,$ED,$1B,$19,$0A,$EB,$EB,$EB,$EB,$1B,$04,$00,
$04,$0A,$EC,$ED,$ED,$ED,$1B,$19,$0A,$EB,$EB,$EB,$EB,$1B,$04,$00,
$00,$04,$0A,$ED,$ED,$1B,$19,$19,$19,$0A,$EB,$EB,$1B,$04,$00,$00,
$00,$04,$1B,$ED,$ED,$ED,$0A,$0A,$0A,$EB,$EB,$EB,$1B,$04,$00,$00,
$00,$00,$04,$1B,$1B,$EB,$EB,$EB,$EB,$EB,$1B,$1B,$04,$00,$00,$00,
$00,$00,$00,$04,$04,$1B,$1B,$1B,$1B,$1B,$04,$04,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$04,$04,$04,$04,$04,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$E2,$E2,$00,$00,$E2,$E2,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$E2,$0C,$0C,$E2,$E2,$0C,$0C,$E2,$00,$00,$00,$00,
$00,$00,$00,$00,$E2,$0C,$0C,$0C,$0C,$0C,$0C,$E2,$00,$00,$00,$00,
$00,$00,$E2,$E2,$E2,$03,$03,$12,$12,$03,$03,$E2,$E2,$E2,$00,$00,
$00,$E2,$11,$11,$11,$11,$10,$10,$10,$10,$11,$11,$11,$11,$E2,$00,
$00,$00,$E2,$E2,$1B,$1B,$1B,$1B,$1B,$1B,$1B,$1B,$E2,$E2,$00,$00,
$00,$00,$E2,$1B,$08,$08,$08,$08,$08,$08,$08,$08,$1B,$E2,$00,$00,
$00,$00,$E2,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$E2,$00,$00,
$00,$00,$E2,$08,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$08,$E2,$00,$00,
$00,$00,$E2,$08,$E3,$E3,$E3,$08,$08,$E3,$E3,$E3,$08,$E2,$00,$00,
$00,$00,$E2,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$E2,$00,$00,
$00,$00,$E2,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$E2,$00,$00,
$00,$00,$E2,$19,$19,$1A,$19,$19,$19,$19,$1A,$19,$19,$E2,$00,$00,
$00,$00,$E2,$19,$19,$19,$1A,$1A,$1A,$1A,$19,$19,$19,$E2,$00,$00,
$00,$00,$00,$E2,$19,$19,$19,$19,$19,$19,$19,$19,$E2,$00,$00,$00,
$00,$00,$00,$00,$E2,$E2,$E2,$E2,$E2,$E2,$E2,$E2,$00,$00,$00,$00);

  Max: Word = 1024;
  MaxVitesse: Word = 7;

  { Nombre maximum de d‚cor }
  MaxDecor: Word = 255;

  { Nombre maiximum de couleur }
  MaxColor: Word = 223;

  { Nombre de rouge, vert, bleu maximum }
  MaxRGB: Word = 63;

  MaxObjet: Word = 200;
  MaxSprite: Word = 15;

  { Codes des niveaux }
  CodeNiveau: array[0..15] of Word =
    ($000,$DDB,$1BE,$141,$EBB,$703,$744,$6F0,
     $DED,$338,$196,$97F,$44A,$C95,$07B,$627);

  { Pour les dessins }
  Pixel   = 0;
  Line    = 1;
  Boxv     = 2;
  Boxf    = 3;
  Circle  = 4;
  Circlef = 5;

  { Pour le mode }
  ModeStage   = 1;
  ModeSprite  = 2;
  ModeObjets  = 3;
  ModeInfo    = 4;

  Objet: array[0..15,0..2] of Word = (
  (0,0,0),
  (256,ObjetTsp,0),
  (257,0,0),
  (258,ObjetTsp,0),
  (259,ObjetTsp,0),
  (260,0,0),
  (267,ObjetTsp,0),
  (57,ObjetPerso,ObjetPeurVide),
  (64,ObjetPerso,0),
  (74,0,0),
  (265,ObjetTsp,ObjetPiquant),
  (76,ObjetPerso,ObjetPeurVide),
  (81,0,0),
  (82,0,0),
  (83,ObjetTsp,0),
  (84,0,0));

procedure SetMode(Sender: Word); far; forward;

{ ***** Test le niveau ***** }
procedure Test(Sender: Word); far;
var
  SaveX, SaveY, SaveFX, SaveFY, i: Word;
begin
  { Sauvergarde le niveau }
  moved (Plan[0]^, BufferTemp^, 8192);
  moved (Plan[2]^, BufferTemp^[32768], 8192);
  SaveFX := ObjetX[200];
  SaveFY := ObjetY[200];
  FirstPosX := SaveFX;
  FirstPosY := SaveFY + ObjetVSize[200]-1;
  ObjetSprite[200] := 0;
  ObjetX[200] := 0;
  ObjetY[200] := 0;
  PushObjet;

  SaveX := ScreenX;
  SaveY := ScreenY;

  { Initialisation de mister patate }
  MisterPos := Droite;
  PlusMarche := 2;
  MisterElan := 0;
  CompteurPasBouge := 0;
  EtatTombe := 0;
  Boss := 0;
  if Boss <> 0 then begin
    MisterLargeur := DimSprite[2].Largeur;
    MisterHauteur := DimSprite[2].Hauteur;
  end else begin
    MisterLargeur := DimSprite[30].Largeur;
    MisterHauteur := DimSprite[30].Hauteur;
  end;
  MaxPosX := 1 shl (ShiftLargeur + 4 )- 1;
  MaxScreenX := MaxPosX - 319;
  MaxPosY := 1 shl (19 - ShiftLargeur)- 1;
  MaxScreenY:= MaxPosY - 199;
  WaitSaute := 0;
  Vie := 3;
  Bonnus := 0;
  Energie := 16;
  PaletteFadeIn;

  SetPaletteV (0, 0, 0, 0);
  SetPaletteV (240,  0,  0,  0);
  SetPaletteV (241, 63, 63, 63);
  SetPaletteV (242, 57, 47,  0);
  SetPaletteV (243, 60, 57,  0);
  SetPaletteV (244,  7, 63,  7);
  SetPaletteV (245,  0, 58,  0);
  for i := 0 to 3 do SetPaletteV (255-i,63-5*i,0,0);

  StatutColor := 2;
  avancement := 0;
  Code := Sqr(Code) shr 8;

  { Lance le jeu }
  Page_display := Page_display and 1;
  Page_not_display := Page_not_display and 1;
  Jeu;

  Code := CodeNiveau[Niveau];
  Page_display := Page_display or (Page_display shl 1);
  Page_not_display := Page_not_display or (Page_not_display shl 1);

  { Recharge le niveau }
  moved (BufferTemp^, Plan[0]^, 8192);
  moved (BufferTemp^[32768], Plan[2]^, 8192);
  PopObjet;
  ObjetSprite[200] := 30;
  ObjetHSize[200] := DimSprite[30].Largeur;
  ObjetVSize[200] := DimSprite[30].Hauteur;
  ObjetX[200] := SaveFX;
  ObjetY[200] := SaveFY;

  { R‚initialisation de certaines variables }
  ScreenX := SaveX;
  ScreenY := SaveY;
  MaxScreenX := 1 shl ShiftLargeur - 12;
  MaxScreenY := 1 shl (15 - ShiftLargeur) - 10;
  EtatPalette1 := 0;
  EtatPalette2 := 4;
  EtatPiege := 0;
  InitColor;
  with Palette[7] do begin
    SetPalette (0,r,v,b);
    fillpalette(r,v,b);
  end;
  SetMode (ModeInfo);
  Wait; PCopy (1, Page_display);
  ConvertPalette;
end;

procedure SetPutCaseMode(Sender: Word); far;
var
  i: Byte;
begin
  if Draw.Statut <> 0 then exit;
  if Sender > 25 then begin
    OutText8 (1, 226, 100, ' INFO ', 246, Tsp, false);
    ObjetInfo[26].Color := 246;
    for i := 1 to 3 do begin
      OutText8 (1, 226, 100+i*18, 'PLAN ' + Str(i,1), 246, Tsp, false);
      ObjetInfo[26+i].Color := 246;
    end;
    ObjetInfo[Sender].Color := 244;
    Draw.Plan := @Plan[Sender-26]^;
  end else begin
    OutText8 (1, 225 + CaseMode shl 4, 185, char (248 + CaseMode), 246, Tsp, false);
    ObjetInfo[CaseMode+13].Color := 246;
    CaseMode := Sender - 13;
    ObjetInfo[Sender].Color := 244;
  end;
end;

procedure SetPutPointMode(Sender: Word); far;
begin
  OutText8 (1, 9 + PointMode shl 4, 163, char (248 + PointMode), 246, Tsp, false);
  ObjetInfo[PointMode+27].Color := 246;
  PointMode := Sender - 27;
  ObjetInfo[Sender].Color := 244;
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

procedure range (a, b: word; var a1, b1: word); assembler;
asm
	MOV	AX,[a]
        MOV	BX,[b]
        CMP	AX,BX
        JA	@Label1
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

procedure MakeDraw;
var
  x, y: integer;
  Dx, Dy: word;
  D, aincr, bincr: Integer;
  TL: Byte;
  Sx, Sy: Integer;
  rx1, rx2, ry1, ry2: word;
  Perimetre, Rayon, angle: integer;
begin with Draw do begin
  moved (BufferTemp^, Plan^, 16384);
  Dx := abs (integer(x2 - x1));
  Dy := abs (integer(y2 - y1));
  range (x1, x2, rx1, rx2);
  range (y1, y2, ry1, ry2);
  Sx := Signe (x2 - x1);
  Sy := Signe (y2 - y1);
  case CaseMode of
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
        Plan^[y shl ShiftLargeur or x] := handleCase;
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
          Plan^[y shl ShiftLargeur or x] := handleCase;
        until (x = x2) and (y = y2);
    end;
    Boxv: begin
           fillchar (Plan^[y1 shl ShiftLargeur or rx1], Dx, HandleCase);
           fillchar (Plan^[y2 shl ShiftLargeur or rx1], Dx, HandleCase);
           for y := ry1 to ry2 do begin
             Plan^[y shl ShiftLargeur or rx1] := HandleCase;
             Plan^[y shl ShiftLargeur or rx2] := HandleCase;
           end;
         end;
    Boxf: for y := ry1 to ry2 do fillchar (Plan^[y shl ShiftLargeur or rx1], Dx+1, HandleCase);
    Circle: begin
      if (dx = 0) and (dy = 0) then begin
        Plan^[x1 or y1 shl ShiftLargeur] := handlecase;
        exit;
      end;
      Rayon := Round (Sqrt (Sqr (Dx) + Sqr (Dy)));
      Perimetre := Round (Rayon * Pi / 2);
      for angle := 0 to Perimetre do begin
        x := round (cos (angle * Pi / (perimetre shl 1)) * rayon);
        y := round (sin (angle * Pi / (perimetre shl 1)) * rayon);
        if x1 + x < 1 shl ShiftLargeur then begin
          if y1 + y < 1 shl (15-ShiftLargeur) then
            Plan^[(x + x1) or (y + y1) shl ShiftLargeur] := HandleCase;
          if y1 - y >= 0 then
            Plan^[(x + x1) or (y1 - y) shl ShiftLargeur] := HandleCase;
        end;
        if x1 - x >= 0 then begin
          if y1 + y < 1 shl (15-ShiftLargeur) then
            Plan^[(x1 - x) or (y + y1) shl ShiftLargeur] := HandleCase;
          if y1 - y >= 0 then
            Plan^[(x1 - x) or (y1 - y) shl ShiftLargeur] := HandleCase;
        end;
      end;
    end;
    Circlef: begin
      if (dx = 0) and (dy = 0) then begin
        Plan^[x1 or y1 shl ShiftLargeur] := handlecase;
        exit;
      end;
      Rayon := Round (Sqrt (Sqr (Dx) + Sqr (Dy)));
      Perimetre := Round (Rayon * Pi / 2);
      for angle := 0 to Perimetre do begin
        x := round (cos (angle * Pi / (perimetre shl 1)) * rayon);
        y := round (sin (angle * Pi / (perimetre shl 1)) * rayon);
        if x1 - x < 0 then rx1 := 0 else rx1 := x1 - x;
        if x1 + x >= 1 shl ShiftLargeur then rx2 := 1 shl ShiftLargeur - 1 else rx2 := x1 + x;
        if y1 - y >= 0 then fillchar (plan^[rx1 or (y1 - y) shl ShiftLargeur], rx2 - rx1 + 1, HandleCase);
        if y1 + y < 1 shl (15-ShiftLargeur) then fillchar (plan^[rx1 or (y1 + y) shl ShiftLargeur], rx2 - rx1 + 1, HandleCase);
      end;
    end;
  end;
end; end;

procedure testDraw;
var
  x, y: word;
begin with Draw do begin
  x := MouseXr shr 4 + ScreenX;
  y := MouseYr shr 4 + ScreenY;
  if not MouseBL then begin
    if Statut = 3 then begin
      Statut := 0;
      SetWindowMouse (0, 0, 319, 199);
    end else if Statut = 1 then Statut := 2;
  end;
  if (Statut = 10) and not MouseBR then begin
    Statut := 0;
    moved (BufferTemp^, Plan^, 16384);
    SetWindowMouse (0, 0, 319, 199);
  end else begin
    if Timer > T then begin
      T := Timer;
      if (x = ScreenX) and (ScreenX > 0) then begin
        dec (ScreenX); dec (x);
        DrawBarreH (7);
      end;
      if (y = ScreenY) and (ScreenY > 0) then begin
        dec (ScreenY); dec (y);
        DrawBarreV (10);
      end;
      if (x = ScreenX + 11) and (ScreenX < MaxScreenX) then begin
        inc (ScreenX); inc (x);
        DrawBarreH (7);
      end;
      if (y = ScreenY + 9) and (ScreenY < MaxScreenY) then begin
        inc (ScreenY); inc (y);
        DrawBarreV (10);
      end;
    end;
    if (x2 <> x) or (y2 <> y) then begin
      x2 := x; y2 := y;
      MakeDraw;
    end;
  end;
end; end;

procedure PutStage(Sender: Word); far;
var
  x, y: Word;
begin with Draw do begin
  if PlaceObjet then begin
    PlaceObjet := false;
    SetWindowMouse (0, 0, 319, 199);
    ObjetInfo[6].Attribut := ObjetInfo[6].Attribut or 1;
    exit;
  end;
  { Calcul de la position }
  x := MouseXr shr 4 + ScreenX;
  y := MouseYr shr 4 + ScreenY;
  { Si ce n'est qu'un point }
  if CaseMode = Pixel then begin
    Plan^[y shl ShiftLargeur or x] := HandleCase;
    exit;
  end;
  { Sinon on fait le dessin }
  if Statut = 0 then begin
    moved (Plan^, BufferTemp^, 16384);
    Statut := 1;
    x1 := x; y1 := y;
    x2 := x; y2 := y;
    Plan^[y shl ShiftLargeur or x] := HandleCase;
    SetWindowMouse (4, 20, 211, 195);
  end else if Statut = 2 then Statut := 3;
end; end;

procedure SetCase(Sender: Word); far;
begin
  if Draw.Statut <> 0 then Draw.Statut := 10
    else begin
      HandleCase := Draw.Plan^[(MouseXr shr 4 + ScreenX) or (MouseYr shr 4 + ScreenY) shl ShiftLargeur];
      DrawBarreH (22);
    end;
end;

procedure UpdateBarreCase(Sender: Word); far;
begin
  DrawBarreH (22);
end;

procedure Quitter(Sender: Word); far;
begin
  { Sauve les configurations si n‚scessaire }
  if ModifConfig then SaveConfig;
  halt(0);
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
  ColorOn := (Color >= 112) and ((Color <= 223) or (Color >= 240));
  with Palette[Color] do begin
    Red   := R;
    Green := V;
    Blue  := B;
  end;
  Remplace (1, 221, 92, 234, 155, 248, 11);
  if Red <> 0 then Remplace (1, 221, 155 - Red, 234, 155, 11, 248);
  Remplace (1, 253, 92, 266, 155, 243, 11);
  if Green <> 0 then Remplace (1, 253, 155 - Green, 266, 155, 11, 243);
  Remplace (1, 285, 92, 298, 155, 242, 11);
  if Blue <> 0 then Remplace (1, 285, 155 - Blue, 298, 155, 11, 242);
  OutText8 (1, 220, 79, StrE (Red, 2), 248, 249, false);
  OutText8 (1, 252, 79, StrE (Green, 2), 243, 249, false);
  OutText8 (1, 284, 79, StrE (Blue, 2), 242, 249, false);
  OutText8 (1, 171, 157, StrE (Color, 3), 247, 0, false);
  FillBox (1, 153, 173, 196, 182, Color);
end;

procedure PutColor(Sender: Word); far;
begin
  if Color < 112 then begin
    UpdateColor(Sender);
    exit;
  end;
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
  if Color < 112 then exit;
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

procedure SetColor(Sender: Word); far;
begin
  Color := GetPixel (1, MouseX, MouseY);
  UpdateColor(Sender);
end;

procedure MakeDrawPoint;
var
  x, y: integer;
  Dx, Dy: word;
  D, aincr, bincr: Integer;
  TL: Byte;
  Sx, Sy: Integer;
  rx1, rx2, ry1, ry2: word;
  Perimetre, Rayon, angle: integer;
begin with Draw do begin
  moved (BufferTemp^, Decor^[HandleCase shl 8], 64);
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
        Decor^[(HandleCase shl 8) or (y shl 4) or x] := Color;
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
          Decor^[(HandleCase shl 8) or (y shl 4) or x] := Color;
        until (x = x2) and (y = y2);
    end;
    Boxv: begin
           fillchar (Decor^[HandleCase shl 8 or y1 shl 4 or rx1], Dx, color);
           fillchar (Decor^[HandleCase shl 8 or y2 shl 4 or rx1], Dx, color);
           for y := ry1 to ry2 do begin
             Decor^[(HandleCase shl 8) or (y shl 4) or rx1] := color;
             Decor^[(HandleCase shl 8) or (y shl 4) or rx2] := color;
           end;
         end;
    Boxf: for y := ry1 to ry2 do fillchar (Decor^[HandleCase shl 8 or y shl 4 or rx1], Dx+1, color);
    Circle: begin
      if (dx = 0) and (dy = 0) then begin
        Decor^[(HandleCase shl 8) or (y1 shl 4) or x1] := Color;
        exit;
      end;
      Rayon := Round (Sqrt (Sqr (Dx) + Sqr (Dy)));
      Perimetre := Round (Rayon * Pi / 2);
      for angle := 0 to Perimetre do begin
        x := round (cos (angle * Pi / (perimetre shl 1)) * rayon);
        y := round (sin (angle * Pi / (perimetre shl 1)) * rayon);
        if x1 + x < 16 then begin
          if y1 + y < 16 then
            decor^[(HandleCase shl 8) or (x + x1) or (y + y1) shl 4] := color;
          if y1 - y >= 0 then
            decor^[(HandleCase shl 8) or (x + x1) or (y1 - y) shl 4] := color;
        end;
        if x1 - x >= 0 then begin
          if y1 + y < 16 then
            decor^[(HandleCase shl 8) or (x1 - x) or (y + y1) shl 4] := color;
          if y1 - y >= 0 then
            decor^[(HandleCase shl 8) or (x1 - x) or (y1 - y) shl 4] := color;
        end;
      end;
    end;
    Circlef: begin
      if (dx = 0) and (dy = 0) then begin
        Decor^[(HandleCase shl 8) or (y1 shl 4) or x1] := Color;
        exit;
      end;
      Rayon := Round (Sqrt (Sqr (Dx) + Sqr (Dy)));
      Perimetre := Round (Rayon * Pi / 2);
      for angle := 0 to Perimetre do begin
        x := round (cos (angle * Pi / (perimetre shl 1)) * rayon);
        y := round (sin (angle * Pi / (perimetre shl 1)) * rayon);
        if x1 - x < 0 then rx1 := 0 else rx1 := x1 - x;
        if x1 + x >= 16 then rx2 := 15 else rx2 := x1 + x;
        if y1 - y >= 0 then fillchar (decor^[(HandleCase shl 8) or rx1 or (y1 - y) shl 4], rx2 - rx1 + 1, color);
        if y1 + y < 16 then fillchar (decor^[(HandleCase shl 8) or rx1 or (y1 + y) shl 4], rx2 - rx1 + 1, color);
      end;
    end;
  end;
end; end;

procedure testDrawPoint;
var
  x, y: word;
begin with Draw do begin
  x := (MouseXr shr 3); if x = 16 then x := 15;
  y := (MouseYr shr 3); if y = 16 then y := 15;
  if not MouseBL then begin
    if Statut = 3 then begin
      Statut := 0;
      SetWindowMouse (0, 0, 319, 199);
    end else if Statut = 1 then Statut := 2;
  end;
  if (Statut = 10) and not MouseBR then begin
    Statut := 0;
    moved (BufferTemp^, decor^[handlecase shl 8], 64);
    SetWindowMouse (0, 0, 319, 199);
  end else if (x2 <> x) or (y2 <> y) then begin
      x2 := x; y2 := y;
      MakeDrawPoint;
  end;
end; end;

procedure PutPoint(Sender: Word); far;
var
  x, y: Word;
begin with Draw do begin
  { Calcul de la position }
  x := MouseXr shr 3; if x = 16 then x := 15;
  y := MouseYr shr 3; if y = 16 then y := 15;
  { Si ce n'est qu'un point }
  if PointMode = Pixel then begin
    Decor^[(HandleCase shl 8) or (y shl 4) or x] := Color;
    exit;
  end;
  { Sinon on fait le dessin }
  if Statut = 0 then begin
    moved (Decor^[HandleCase shl 8], BufferTemp^, 64);
    Statut := 1;
    x1 := x; y1 := y;
    x2 := x; y2 := y;
    Decor^[(HandleCase shl 8) or (y shl 4) or x] := Color;
    SetWindowMouse (6, 22, 134, 150);
  end else if Statut = 2 then Statut := 3;
end; end;

procedure GetColor(Sender: Word); far;
var
  x, y: word;
begin
  if Draw.Statut <> 0 then Draw.Statut := 10
    else begin
      x := mousexr shr 3; if x = 16 then x := 15;
      y := mouseyr shr 3; if y = 16 then y := 15;
      Color := Decor^[HandleCase shl 8 or y shl 4 or x];
      UpdateColor(Sender);
    end;
end;

procedure IDC(Sender: Word); far;
begin
  if Color < 112 then exit;
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

procedure Copier(Sender: Word); far;
begin
  moved (decor^[handlecase shl 8], TmpSprite, 64);
end;

procedure Coller(Sender: Word); far;
var
  x, y: Word;
begin
  for y := 0 to 15 do for x := 0 to 15 do
    if decor^[handlecase shl 8 or y shl 4 or x] = 0 then
       decor^[handlecase shl 8 or y shl 4 or x] := TmpSprite[y shl 4 or x];
end;

procedure Save (Sender: Word); far;
var
  F: file;
  w: Word;
begin
  { Ouvre le fichier du niveau }
  assign (F, 'STAGE\MRPSTG' + Str (Niveau, 2) + '.SQZ');
  rewrite (F, 1);
  { Lit les informations }
  BlockWrite (F, ShiftLargeur, 1);
  BlockWrite (F, MusiqueFile, 1);
  BlockWrite (F, Plan[0]^, 32768);
  BlockWrite (F, Plan[1]^, 32768);
  BlockWrite (F, Plan[2]^, 32768);
  BlockWrite (F, Plan[3]^, 32768);
  BlockWrite (F, Decor^, 32768);
  BlockWrite (F, Decor^[32768], 32768);
  BlockWrite (F, Palette[112], 112 * 3);
  BlockWrite (F, ObjetX, 512*11);
  BlockWrite (F, SecretX, 32);
  w := Sqr(Code) shr 8;
  BlockWrite (F, w, 2);
  close (F);
end;

procedure UpdateScreenObjets (Sender: Word); far;
begin
  OutText8 (1, 47, 108, StrE (ObjetLim1[ObjetActu], 5), 250, 249, false);
  OutText8 (1, 47, 121, StrE (ObjetLim2[ObjetActu], 5), 250, 249, false);
  OutText8 (1, 79, 134, StrE (Vitesse, 1), 250, 249, false);
  if PeurVide then OutText8 (1, 109, 147, #241, 243, tsp, false)
              else OutText8 (1, 109, 147, #241, 249, tsp, false);
end;

procedure UpdateScreenInfo (Sender: Word); far;
var
  i: integer;
begin
  for i := 0 to 7 do begin
    OutText8 (1, 138, 63+i*12, StrE(SecretX[i],5), 247, 0, false);
    OutText8 (1, 186, 63+i*12, StrE(SecretY[i],5), 247, 0, false);
  end;
end;

procedure SetVitesse (Sender: Word); far;
begin
  ObjetAttr2[ObjetActu] := (ObjetAttr2[ObjetActu] and $F8FF) or (Vitesse shl 8);
  UpdateScreenObjets (0);
end;

procedure SetVide (Sender: Word); far;
begin
  if PeurVide then ObjetAttr2[ObjetActu] := ObjetAttr2[ObjetActu] or ObjetPeurVide
              else ObjetAttr2[ObjetActu] := ObjetAttr2[ObjetActu] and not ObjetPeurVide;
  UpdateScreenObjets (0);
end;

procedure SetSprite (Sender: Word); far;
begin
  if ObjetActu <> 200 then begin
    SpriteObjA := Objet[SpriteActu,0];
    if ObjetSprite[ObjetActu] <> SpriteObjA then
    begin
      ObjetSprite[ObjetActu] := SpriteObjA;
      ObjetHSize[ObjetActu] := DimSprite[SpriteObjA].Largeur;
      ObjetVSize[ObjetActu] := DimSprite[SpriteObjA].Hauteur;
      ObjetAttr[ObjetActu] := (ObjetAttr[ObjetActu] and 1) or Objet[SpriteActu,1];
      ObjetAttr2[ObjetActu] := (ObjetAttr2[ObjetActu] and ObjetSpeedBit) or Objet[SpriteActu,2];
    end;
  end;
  FillBox (1, 7, 26, 83, 84, 0);
  if ObjetSprite[ObjetActu] = 0 then OutText8 (1, 29,51, 'RIEN', 246, tsp, true)
  else with DimSprite[SpriteObjA] do
    PutObjet (1, 45-Largeur shr 1, 55-Hauteur shr 1, ObjetAttr[ObjetActu] and 1, ObjetSprite[ObjetActu]);
end;

procedure SetObjet (Sender: Word); far;
var
  i: Byte;
begin
  if Sender = 13 then DrawBarreH (6);
  OutText8 (1, 292, 185, StrE (ObjetActu, 3), 250, 249, false);
  if ObjetActu = 200 then SpriteActu := 0
    else for i := 0 to MaxSprite do if Objet[i,0] = ObjetSprite[ObjetActu] then SpriteActu := i;
  ObjetOn := ObjetActu <> 200;
  DrawBarreH (9);
  SetSprite(0);
  OutText8 (1, 106, 33, 'X = '+StrE(ObjetX[ObjetActu] shr 4,5), 247, 0, false);
  OutText8 (1, 106, 48, 'Y = '+StrE(ObjetY[ObjetActu] shr 4,5), 247, 0, false);
  MakeValeur (15, 39, 108, ObjetLim1[ObjetActu], Max, 250, 249, UpdateScreenObjets);
  MakeValeur (16, 39, 121, ObjetLim2[ObjetActu], Max, 250, 249, UpdateScreenObjets);
  ObjetInfo[15].PtrOn := @ObjetOn;
  ObjetInfo[16].PtrOn := @ObjetOn;
  Vitesse := (ObjetAttr2[ObjetActu] shr 8) and 7;
  PeurVide := (ObjetAttr2[ObjetActu] and ObjetPeurVide) <> 0;
  UpdateScreenObjets (0);
end;

procedure Place (Sender: Word); far;
begin
  if ObjetSprite[ObjetActu] = 0 then exit;
  SetWindowMouse (4, 20, 211, 195);
  PlaceObjet := true;
  SetMode (ModeStage);
end;

procedure Fixer (Sender: Word); far;
var
  x, y: Integer;
begin
  if ObjetSprite[ObjetActu] = 0 then exit;
  if ObjetX[ObjetActu] = $FFFF then exit;
  x := (ObjetX[ObjetActu] + ObjetHSize[ObjetActu] shr 1) shr 4 - 6;
  y := (ObjetY[ObjetActu] + ObjetVSize[ObjetActu] shr 1) shr 4 - 5;
  if x < 0 then ScreenX := 0
    else if x > MaxScreenX then ScreenX := MaxScreenX
    else ScreenX := x;
  if y < 0 then ScreenY := 0
    else if y > MaxScreenY then ScreenY := MaxScreenY
    else ScreenY := y;
end;

procedure InverseSens (Sender: Word); far;
begin
  ObjetAttr[ObjetActu] := ObjetAttr[ObjetActu] xor 1;
  SetSprite (0);
end;
procedure MakeNewStage(Sender: Word); far;
begin
  Code := CodeNiveau[Niveau];
  FillD(Plan[0]^, 16384);
  FillD(Plan[2]^, 16384);
  FillD(Decor^, 16000);
  MoveD(SpriteBonnus, Decor^[250*256], 384);
  FillChar(Palette[112], 112*3, 0);
  FillChar(ObjetX, 512*11, 0);
  FillChar(SecretX, 32, 0);
  ObjetSprite[200] := 30;
  OutPalette (112, 223);
  NextLine := 1 shl ShiftLargeur;
  MaxScreenX := NextLine - 12;
  MaxScreenY := 1 shl (15 - ShiftLargeur) - 10;
end;

procedure ChangeDim(Sender: Word); far;
begin
  case Sender of
    2: if ShiftLargeur > 5  then Dec(ShiftLargeur);
    3: if ShiftLargeur < 10 then Inc(ShiftLargeur);
  end;
end;

function Lit(var F: file; var Buffer; Qte: Word): Boolean;
var
  NB: Word;
begin
  BlockRead(F, Buffer, Qte, NB);
  Lit := NB = Qte;
end;
procedure LoadStage;
var
  F: file;
  i: Byte;
label NewStage;
begin
  Code := CodeNiveau[Niveau];
  { Ouvre le fichier du niveau }
  if not Ouvre ('STAGE\MRPSTG' + Str (Niveau, 2) + '.SQZ', F, 1) then goto NewStage;
  { Lit les informations }
  if not Lit(F, ShiftLargeur, 1) then goto NewStage;
  if not Lit(F, MusiqueFile, 1) then goto NewStage;
  if not Lit(F, Plan[0]^, 32768) then goto NewStage;
  if not Lit(F, Plan[1]^, 32768) then goto NewStage;
  if not Lit(F, Plan[2]^, 32768) then goto NewStage;
  if not Lit(F, Plan[3]^, 32768) then goto NewStage;
  if not Lit(F, Decor^, 32768) then goto NewStage;
  if not Lit(F, Decor^[32768], 32768) then goto NewStage;
  if not Lit(F, Palette[112], 112 * 3) then goto NewStage;
  if not Lit(F, ObjetX, 512*11) then goto NewStage;
  if not Lit(F, SecretX, 32) then goto NewStage;
  close (F);
  LoadMusic(MusiqueFile);
  OutPalette (112, 223);
  NextLine := 1 shl ShiftLargeur;
  MaxScreenX := NextLine - 12;
  MaxScreenY := 1 shl (15 - ShiftLargeur) - 10;
  exit;
NewStage:
  MakeWindow(108, 51, 'Nouveau');
  MakeBouton(1, 108, 109, '   Cr‚er   ', 246, MakeNewStage);
  MakeBouton(2, 108, 92, #17, 246, ChangeDim);
  MakeBouton(3, 197, 92, #16, 246, ChangeDim);
  ShiftLargeur := 8;
  NextLine := 0;
  repeat
    Update;
    OutText8(1, Centre, Centre, ' '+Str(1 shl ShiftLargeur,0)+'x'+Str(1 shl (15-ShiftLargeur),0)+' ',246,0,false);
  until NextLine <> 0;
  SetMode(Mode);
end;

procedure Charger(Sender: Word); far;
var
  i: Byte;
begin
  i := SelectFile(Nom, 'Charger', Niveau, 0);
  if i < 16 then begin
    Niveau := i;
    LoadStage;
  end;
  SetMode(Mode);
end;
procedure ChargerMusic(Sender: Word); far;
var
  i: Byte;
begin
  i := SelectFile(FileMusic, 'Charger', MusiqueFile, 0);
  if i < 16 then begin
    Music.EnAble := False;
    Music.OfsSound := Ofs(MusicNote);
    MusiqueFile := i;
    LoadMusic(MusiqueFile);
  end;
  SetMode(Mode);
end;

procedure SetMode;
var
  BitMode: Byte;
  Col: Byte;
  x, y: integer;
  txt: string;
  i: Byte;
  w: Word;
begin
  { Changement de page }
  ClearObjet(0,255); Cls (2, 0); Cls (1, 0);
  Mode := Sender;
  MakeClasseur (1, Mode, 0, 0, 319, 199, 'Niveau/Sprites/Objets/Attributs', SetMode);
  Draw.Statut := 0;
  case Mode of
    ModeStage: begin
      { Pour le niveau }
      if PlaceObjet then x := CursorMain+EventOnClick else x := CursorMain+EventOnPush;
      MakeBox (6, 3, 19, 196, 180, 0, x, PutStage, SetCase);
      MakeBarreH (07{,08,09}, 3, 181, 193, ScreenX, MaxScreenX, 4, 0, 1, nil);
      MakeBarreV (10{,11,12}, 197, 19, 161, ScreenY, MaxScreenY, 4, 0, 1, nil);
      { Pour le mode de dessin }
      BitMode := 1 shl CaseMode;
      MakeBouton (13, 221, 181, #248, 246-(BitMode and $01)shl 1, SetPutCaseMode);
      MakeBouton (14, 237, 181, #249, 246-(BitMode and $02), SetPutCaseMode);
      MakeBouton (15, 253, 181, #250, 246-(BitMode and $04)shr 1, SetPutCaseMode);
      MakeBouton (16, 269, 181, #251, 246-(BitMode and $08)shr 2, SetPutCaseMode);
      MakeBouton (17, 285, 181, #252, 246-(BitMode and $10)shr 3, SetPutCaseMode);
      MakeBouton (18, 301, 181, #253, 246-(BitMode and $20)shr 4, SetPutCaseMode);
      { Pour le d‚cor s‚l‚ctionn‚ }
      MakeRelief (215, 23, 316, 66, 'Case', 244);
      OutText8 (1, 219, 33, 'n'#240, 247,tsp, false);
      MakeValeur (25, 235, 33, HandleCase, MaxDecor, 247, 0, UpdateBarreCase);
      MakeBox (21, 268, 27, 285, 44, 0, 0, nil, nil);
      MakeBarreH (22{,23,24}, 219, 47, 93, HandleCase, MaxDecor, 4, 0, 1, nil);
      { Pour la souris }
      MakeRelief (215, 73, 316, 171, 'Souris', 244);
      MakeBox (19, 219, 77, 312, 91, 250, 0, nil, nil);
      OutText8 (1, 262, 80, ':', 243,tsp, false);
      EcritNombre (1, 221, 79, Str (ScreenX, 4) + ' ' +
                               Str (ScreenY, 4), 243, 250, 7, 4, 1, 1);
      for x := 0 to 3 do begin
        if Draw.Plan = @Plan[x]^ then Col := 244 else Col := 246;
        if x = 0 then txt := ' INFO ' else txt := 'PLAN ' + Str (x,1);
        MakeBouton (26+x, 222, 96 + x * 18, txt, Col, SetPutCaseMode);
        MakeBox (34+x, 292, 95 + x * 18, 309, 112 + x * 18, 0, 0, nil, nil);
        MakeSelBox (30+x, 281, 100 + x * 18, ShowPlan[x], nil);
      end;
    end;
    ModeSprite: begin
      { Pour le sprite }
      MakeBox (6, 5, 21, 135, 151, 0, CursorMain+EventOnPush, PutPoint, GetColor);
      for x := 0 to 16 do LineV (1, 6 + x shl 3, 22, 150, 249);
      for y := 0 to 16 do LineH (1, 22 + y shl 3, 6, 134, 249);
      { Pour le d‚cor s‚l‚ctionn‚ }
      MakeRelief (215, 23, 316, 66, 'Case', 244);
      OutText8 (1, 219, 33, 'n'#240, 247,tsp, false);
      MakeValeur (35, 235, 33, HandleCase, MaxDecor, 247, 0, UpdateBarreCase);
      MakeBox (21, 268, 27, 285, 44, 0, 0, nil, nil);
      MakeBarreH (22{,23,24}, 219, 47, 93, HandleCase, MaxDecor, 4, 0, 1, nil);
      { Pour les informations sur la positons de la souris }
      MakeRelief (138, 23, 212, 66, 'Souris', 244);
      MakeBox (7, 142, 27, 208, 47, 250, 0, nil, nil);
      OutText (1, 168, 32, ':', 243,243, false);
      EcritNombre (1, 146, 31, '00:00', 243, 250, 6, 4, 2, 2);
      MakeBox (8, 142, 50, 154, 62, 0, 0, nil, nil);
      OutText8 (1, 162, 52, 'n'#240'  0', 247,tsp, false);
      { Pour la palette }
      MakeRelief (138, 73, 316, 196, 'Palette', 244);
      MakeBox (9, 142, 86, 207, 151, 0, CursorMain + EventOnPush, SetColor, nil);
      for y := 0 to 15 do for x := 0 to 15 do
        fillbox (1, 143 + x shl 2, 87 + y shl 2, 146 + x shl 2, 90 + y shl 2, y shl 4 or x);
      DessineTube (16, 220, 90);
      DessineTube (17, 252, 90);
      DessineTube (18, 284, 90);
      for x := 16 to 18 do ObjetInfo[x].PtrOn := @ColorOn;
      MakeBouton (10, 220, 160, '+', 246, IDC);
      MakeBouton (11, 220, 176, '-', 246, IDC);
      MakeBouton (12, 252, 160, '+', 246, IDC);
      MakeBouton (13, 252, 176, '-', 246, IDC);
      MakeBouton (14, 284, 160, '+', 246, IDC);
      MakeBouton (15, 284, 176, '-', 246, IDC);
      for x := 10 to 15 do with ObjetInfo[x] do begin
        Attribut := Attribut or EventOnPush;
        Pas1 := 7;
        Pas2 := 0;
        PtrOn := @ColorOn;
      end;
      DrawBox (19, 215, 77, 241, 87, 249);
      DrawBox (20, 247, 77, 273, 87, 249);
      DrawBox (25, 279, 77, 305, 87, 249);
      MakeValeur (19, 217, 79, Red, MaxRGB, 248, 249, PutColor);
      MakeValeur (20, 249, 79, Green, MaxRGB, 243, 249, PutColor);
      MakeValeur (25, 281, 79, Blue, MaxRGB, 242, 249, PutColor);
      ObjetInfo[19].PtrOn := @ColorOn;
      ObjetInfo[20].PtrOn := @ColorOn;
      ObjetInfo[25].PtrOn := @ColorOn;
      OutText8 (1, 155, 157, 'n'#240, 247,tsp, false);
      MakeValeur (26, 171, 157, Color, MaxColor, 247, 0, UpdateColor);
      DrawBox (0, 152, 172, 197, 183, 0);
      UpdateColor(0);
      BitMode := 1 shl PointMode;
      MakeBouton (27, 005, 159, #248, 246-(BitMode and $01)shl 1, SetPutPointMode);
      MakeBouton (28, 021, 159, #249, 246-(BitMode and $02), SetPutPointMode);
      MakeBouton (29, 037, 159, #250, 246-(BitMode and $04)shr 1, SetPutPointMode);
      MakeBouton (30, 053, 159, #251, 246-(BitMode and $08)shr 2, SetPutPointMode);
      MakeBouton (31, 069, 159, #252, 246-(BitMode and $10)shr 3, SetPutPointMode);
      MakeBouton (32, 085, 159, #253, 246-(BitMode and $20)shr 4, SetPutPointMode);
      MakeBouton (33, 005, 179, 'Copier', 246, Copier);
      MakeBouton (34, 061, 179, 'Coller', 246, Coller);
    end;
    ModeInfo: begin
      OutText8 (1, Centre, 34, Nom[Niveau], 246, tsp, true);
      MakeRelief (3, 58, 115, 106, 'Attributs', 244);
      OutText8 (1, 7, 63, 'Largeur: ' + StrE (1 shl ShiftLargeur, 4), 247,tsp, false);
      OutText8 (1, 7, 75, 'Hauteur: ' + StrE (1 shl (15-ShiftLargeur), 4), 247,tsp, false);
      OutText8 (1, 7, 91, 'Code:', 247,tsp, false);
      for i := 0 to 3 do
        Put (1, 47 + i shl 4, 87, 16, 16, 0, SpriteCode[(Code shr ((3-i)* 3)) and 7]);
      MakeBouton (8, 3, 181, 'Enregistrer', 246, Save);
      MakeBouton (6, 99, 181,  'Test', 246, Test);
      MakeBouton(25, 139, 181, 'Charger', 246, Charger);
      MakeBouton (7, 203, 181, 'Quitter', 246, Quitter);
      MakeRelief (118, 58, 237, 157, 'Passage secret', 244);
      for x := 0 to 7 do begin
        OutText8 (1, 122, 63 + x * 12, Str(x+1,1)+'(     ;     )',247,0,false);
        MakeValeur (9+x, 138, 63 + x * 12, SecretX[x], Max, 247, 0, UpdateScreenInfo);
        OutText8 (2, 138, 63 + x * 12, 'ÛÛÛÛÛ', 9+x,0,false);
        MakeValeur (17+x,186, 63 + x * 12, SecretY[x], Max, 247, 0, UpdateScreenInfo);
        OutText8 (2, 186, 63 + x * 12, 'ÛÛÛÛÛ', 17+x,0,false);
      end;
      MakeRelief (3, 113, 115, 157, 'Musique', 244);
      MakeBouton(26, 7, 118, 'Charger', 246, ChargerMusic);
      UpdateScreenInfo (0);
    end;
    ModeObjets: begin
      MakeBarreH (06{,07,08}, 3, 181, 279, ObjetActu, MaxObjet, 4, 0, 1, SetObjet);
      DrawBox (13, 282, 183, 316, 193, 249);
      MakeValeur (13, 284, 185, ObjetActu, MaxObjet, 250, 249, SetObjet);
      MakeRelief (05, 23, 85, 103, 'Profil', 244);
      MakeBarreH (09{,10,11}, 8, 85, 74, SpriteActu, MaxSprite, 4, 0, 1, SetSprite);
      for x := 9 to 11 do ObjetInfo[x].PtrOn := @ObjetOn;
      MakeRelief (88, 23, 197, 103, 'Position', 244);
      MakeBouton (12, 91, 85, 'Placer', 246, Place);
      MakeBouton (14, 147, 85, 'Fixer', 246, Fixer);
      FillBox (2, 7, 26, 83, 84, 18);
      with ObjetInfo[18] do begin
        Attribut := CursorMain + EventOnClick;
        Event := InverseSens;
        PtrOn := @ObjetAble;
      end;
      OutText8 (1, 5, 108, 'Min:', 247, 0, false);
      OutText8 (1, 5, 121, 'Max:', 247, 0, false);
      DrawBox (15, 37, 106, 87, 116, 249);
      DrawBox (16, 37, 119, 87, 129, 249);
      OutText8 (1, 5, 134, 'Vitesse:', 247, 0, false);
      DrawBox (17, 69, 132, 87, 142, 249);
      MakeValeur (17, 71, 134, Vitesse, MaxVitesse, 250, 249, SetVitesse);
      OutText8 (1, 5, 147, 'Peur du vide', 247, 0, false);
      MakeSelBox(18, 109, 147, PeurVide, SetVide);
      ObjetInfo[17].PtrOn := @ObjetOn;
      ObjetInfo[18].PtrOn := @ObjetOn;
      SetObjet (0);
    end;
  end;
end;

procedure ShowStage; assembler;
asm
        MOV	AX,WORD PTR [ShowPlan+4]
        OR	AX,WORD PTR [ShowPlan+6]
        JNZ	@PSRA
	PUSH	1
        PUSH	4
        PUSH	20
        PUSH	195
        PUSH	179
	PUSH	0
        CALL	FillBox
        JMP	@EndPutStage
@PSRA:	MOV	DI,17601
	MOV	BX,4
@LoopRowStage:
        PUSH	BX
        MOV	CL,BL
        AND	CL,3
        MOV	AX,$0102
        SHL	AH,CL
        MOV	DX,$3C4
        OUT	DX,AX
        MOV	SI,[ScreenY]
        MOV	CL,[ShiftLargeur]
        SHL	SI,CL
        MOV	AX,[ScreenX]
        SHL	AX,4
        SUB	BX,4
        ADD	AX,BX
        SHR	AX,4
        OR	SI,AX
        AND	BX,$000F
        MOV	CX,160
@LoopRowCase:
	MOV	ES,WORD PTR [Plan+2]
        XOR	AH,AH
        MOV	AL,ES:[SI]
        MOV	ES,WORD PTR [Plan+10]
        TEST	AL,64
	JZ	@SS4
	AND	AL,7
        CMP	AL,5
        JE	@SS4
	MOV	AL,[EtatPiege]
	ADD	AL,ES:[SI]
	JMP	@SS5
@SS4:	MOV	AL,ES:[SI]
@SS5:   SHL	AX,4
        ADD	AX,WORD PTR [Decor+2]
        DB	$8E,$E0 { MOV FS,AX }
        XOR	AH,AH
        MOV	AL,ES:[SI+32768]
        SHL	AX,4
        ADD	AX,WORD PTR [Decor+2]
        DB	$8E,$E8 { MOV GS,AX }
        ADD	SI,[NextLine]
        MOV	AX,$A000
        MOV	ES,AX
@LoopRowPixel:
        TEST	WORD PTR [ShowPlan+4],$FFFF
        JZ	@PSR9
        TEST	WORD PTR [ShowPlan+6],$FFFF
        JZ	@PSRB
DB $64;	MOV	AL,[BX]
	OR	AL,AL
	JNZ	@PSR1
DB $65;	MOV	AL,[BX]
@PSR1:	ADD	BX,4
DB $64;	MOV	AH,[BX]
	OR	AH,AH
	JNZ	@PSR4
DB $65;	MOV	AH,[BX]
	JMP	@PSR4
@PSR9:
DB $65;	MOV	AL,[BX]
	ADD	BX,4
DB $65;	MOV	AH,[BX]
	JMP	@PSR4
@PSRB:
DB $64;	MOV	AL,[BX]
	ADD	BX,4
DB $64;	MOV	AH,[BX]
@PSR4:  STOSW
	ADD	DI,78
        LOOP	@PSR2
	POP	BX
        SUB	DI,160*80
        INC	BX
        TEST	BX,3
	JNZ	@PSR3
        ADD	BX,4
	ADD	DI,2
@PSR3:	CMP	BX,195
        JBE	@LoopRowStage
        JMP	@EndPutStage
@PSR2:	ADD	BL,12
	JNC	@LoopRowPixel
        JMP	@LoopRowCase
@EndPutStage:
end;

procedure ShowPlan0;
var
  x, y, c: Word;
  xp,yp,col: word;
begin
  for y := 0 to 9 do begin
    yp := y shl 4 + 20;
    for x := 0 to 11 do begin
      c := Plan[0]^[(y+screeny) shl shiftlargeur or (x+screenx)];
      if c = 0 then continue;
      xp := x shl 4 + 4;
      if c = 32 then begin
        fillbox (1, xp,yp,xp+15,yp+15,240);
        continue;
      end;
      if c and 128=128 then col := 241 else col := 240;
      box (1, xp,yp,xp+15,yp+15,col);
      case c and 7 of
        1: begin
          if c and 16 = 16 then fillbox(1,xp+1,yp+1,xp+14,yp+3,col);
	  if c and  8 =  0 then begin
            FillBox(1,xp+1,yp+7,xp+14,yp+8,col);
            FillBox(1,xp+7,yp+1,xp+8,yp+14,col);
          end;
          if c and 32=32 then OutText8 (1, xp+4,yp+4,'E',col,tsp,false);
        end;
        2: OutText8 (1, xp+4,yp+4,str((c shr 3) and 7+1,1),col,tsp,false);
        3: begin
          LineH(1,yp+6,xp+1,xp+14,col);
          LineH(1,yp+11,xp+1,xp+14,col);
        end;
        4: OutText8 (1, xp,yp+4,'S'+str((c shr 3) and 7+1,1),col,tsp,false);
        5: OutText8 (1, xp,yp+4,'L'+str((c shr 3) and 7+1,1),col,tsp,false);
        6: case (c shr 3) and 7 of
	     0: OutText8 (1, xp,yp+4,'BO',col,tsp,false);
	     1: OutText8 (1, xp,yp+4,'VI',col,tsp,false);
	     2: OutText8 (1, xp,yp+4,'PO',col,tsp,false);
	     3: OutText8 (1, xp,yp+4,'CA',col,tsp,false);
	     4: OutText8 (1, xp,yp+4,'CO',col,tsp,false);
           end;
        7: begin
          OutText8 (1, xp+4,yp+4,'P',col,tsp,false);
	  if c and  8 =  0 then begin
            FillBox(1,xp+1,yp+7,xp+14,yp+8,col);
            FillBox(1,xp+7,yp+1,xp+8,yp+14,col);
          end;
        end;
      end;
    end;
  end;
end;

procedure ShowSprite;
var
  x, y: word;
begin
  for y := 0 to 15 do for x := 0 to 15 do
    fillbox (1, objetinfo[6].x1+x shl 3+1,
                objetinfo[6].y1+y shl 3+1,
                objetinfo[6].x1+x shl 3+7,
                objetinfo[6].y1+y shl 3+7, decor^[handlecase shl 8 + y shl 4 or x]);
end;

procedure ActiveColor; assembler;
asm
        MOV	AL,[EtatPalette1]
        INC	AL
        MOV	[EtatPalette1],AL
        TEST	AL,$01
        JNZ	@LBL19
	INC	[EtatPiege]
        AND	[EtatPiege],$03
@LBL19: TEST	AL,$03
        JNZ	@LBL10
        TEST	AL,$04
        JNZ	@LBL01
        MOV	SI,OFFSET PalAnim2+24
        JMP	@LBL02
@LBL01:	MOV	SI,OFFSET PalAnim2
@LBL02: MOV	DX,$3C8
        MOV	AL,224
        OUT	DX,AL
        INC	DX
	MOV	CX,24
        REP	OUTSB
@LBL10: MOV	AL,[EtatPalette2]
        INC	AL
        MOV	[EtatPalette2],AL
        CMP	AL,6
        JE	@LBL13
        CMP	AL,9
        JE	@LBL16
        CMP	AL,3
        JNE	@LBL12
@LBL17: MOV	SI,OFFSET PalAnim3
	JMP     @LBL20
@LBL13:	MOV	SI,OFFSET PalAnim3+24
	JMP	@LBL20
@LBL16: MOV	SI,OFFSET PalAnim3+48
	MOV	[EtatPalette2],0
@LBL20:	MOV	DX,$3C8
        MOV	AL,232
        OUT	DX,AL
        INC	DX
	MOV	CX,24
	REP	OUTSB
@LBL12:
end;

procedure ShowCase(Handle: Word; NumCase: Byte);
begin
  PutDecor (1, objetinfo[handle].x1, objetinfo[handle].y1, numcase);
end;

var
  i, L: Integer;
  offset: Word;
  x, y: word;
  testObjet: boolean;
begin
  InitGraph (0);
  Page_not_display := 3;

  OutPalette (1, 111);
  MaxScreenX := 2;
  MaxScreenY := 2;
  Niveau := SelectFile(Nom, 'EDITER', 0, 1);
  LoadStage;
  SetMode(1);
  EtatPalette1 := 0;
  EtatPalette2 := 4;
  EtatPiege := 0;
  for i := 0 to 3 do ShowPlan[i] := true;
  Draw.Plan := @Plan[0]^;

  TexteSp := '';
  repeat
    Update;

      { Execute un action particuliŠre en fonction de la page }
      case Mode of
        ModeStage: begin
          if HandleNow = 6 then begin
            if PlaceObjet then begin
              if not GetKey[ScanShiftG] then begin
                x := MouseXr shr 4 + ScreenX;
                y := (MouseYr+ObjetVSize[ObjetActu]-1) shr 4 + ScreenY;
                L := ((MouseXr and $000F)+ObjetHSize[ObjetActu]-2) shr 4;
                if (MouseXr and $000F) = $000F then begin
	          dec (L);
                  inc (x);
                end;
                repeat
                  testObjet := true;
                  for i := 0 to L do
                    TestObjet := TestObjet and not ((Plan[0]^[y shl ShiftLargeur or (x+i)] and 7) in [1,2,7]);
                  if testObjet then inc (y);
                until not testObjet or (y >= 1 shl (15-ShiftLargeur));
                ObjetY[ObjetActu] := y shl 4 - DimSprite[ObjetSprite[ObjetActu]].Hauteur+1;
              end else ObjetY[ObjetActu] := MouseYr + ScreenY shl 4;
              ObjetX[ObjetActu] := MouseXr + ScreenX shl 4;
            end;
            { Test su l'on dessine }
            if Draw.Statut <> 0 then TestDraw;
            { Calcul de la position de la souris dans le niveau }
            x := MouseXr shr 4 + ScreenX;
            y := MouseYr shr 4 + ScreenY;
            offset := y shl ShiftLargeur or x;
            if GetKey[ScanInser] and (inkey = CharInser)  then begin
              for i := 0 to 1 shl (16-ShiftLargeur) - 1 do begin
                for L := 0 to 3 do
  	          move (Plan[L]^[x + i shl ShiftLargeur], Plan[L]^[x + i shl ShiftLargeur + 1], 1 shl ShiftLargeur - x - 1);
              end;
              for i := 0 to 255 do if (ObjetSprite[i] <> 0) and (ObjetX[i] shr 4 > x) then inc (ObjetX[i], 16);
            end;
            { Affiche la position de la souris }
            EcritNombre (1, 221, 79, Str (x, 4) + ' ' + Str (y, 4), 243, 250, 7, 4, 1, 1);
            { Affiche les informations sur la case point‚e par la souris }
            for i := 0 to 3 do ShowCase(34+i, Plan[i]^[offset]);
          end;
          { Affiche les informations sur la case s‚l‚ctionn‚e }
          ShowCase(21, HandleCase);
          OutText8 (1, 235, 33, StrE (HandleCase, 3), 247, 0, false);
          { Affichage du niveau }
          ShowStage;
          SetSpriteWindow (4, 20, 195, 179);
          x := MouseXr + ScreenX shl 4;
          y := MouseYr + ScreenY shl 4;
          for i := 0 to 200 do if ObjetSprite[i] <> 0 then begin
            PutObjet (1, ObjetX[i] - ScreenX shl 4 + 4,
	                 ObjetY[i] - ScreenY shl 4 + 20, (ObjetAttr[i] and 1), ObjetSprite[i]);
            if (HandleNow=6) and (ObjetX[i] <= x) and (ObjetX[i]+ObjetHSize[i]>x) and
            		         (ObjetY[i] <= y) and (ObjetY[i]+ObjetVSize[i]>y) then
              TexteSp := Str (i, 0);
          end;
          ResetSpriteWindow;
          if ShowPlan[0] then ShowPlan0;
        end;
        ModeSprite: begin
          { Affiche le sprite }
          ShowSprite;
          { Affiche les informations sur la case s‚l‚ctionn‚e }
          ShowCase(21, HandleCase);
          OutText8 (1, 235, 33, StrE (HandleCase, 3), 247, 0, false);
          if HandleNow = 6 then begin
            { Test su l'on dessine }
	  if Draw.Statut <> 0 then TestDrawPoint;
            x := MouseXr shr 3; if x = 16 then x := 15;
            y := MouseYr shr 3; if y = 16 then y := 15;
            offset := (HandleCase shl 8) or (y shl 4) or x;
            EcritNombre (1, 146, 31, Str (x, 2) + ' ' + Str (y, 2), 243, 250, 6, 4, 2, 2);
            with ObjetInfo[8] do FillBox (1, X1, Y1, X2, Y2, Decor^[offset]);
            OutText8 (1, 178, 52, StrE (Decor^[offset], 3), 247, 0, false);
          end else if HandleNow = 9 then begin
            with ObjetInfo[8] do FillBox (1, X1, Y1, X2, Y2, GetPixel(1, MouseX, MouseY));
            OutText8 (1, 178, 52, StrE (GetPixel(1, MouseX, MouseY), 3), 247, 0, false);
          end;
        end;
      end;

      { Fait bouger les couleurs }
      if Timer > ColorTimer then begin
        ColorTimer := Timer;
        Wait; ActiveColor;
      end;

  until false;
end.
