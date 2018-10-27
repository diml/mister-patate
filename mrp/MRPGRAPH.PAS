
{$G+,N+}
unit MrpGraph;

interface

uses MrpStr, MrpInit, MrpTps, MrpText, MrpKey, MrpPal, MrpVga, MrpLoad, MrpSon;

type
  TypeEvent = procedure(Sender: Word);
  Buffer = array[0..$FFFE] of Byte;

var
{ -***** SOURIS *****- }
  { Position }
  MouseX: Word;
  MouseY: Word;
  MouseXr: Word;
  MouseYr: Word;
  { Etat des butons }
  MouseBR: Boolean;
  MouseBL: Boolean;
  MouseBC: Boolean;
  { Handle d'objet sur lesquel passe la souris }
  HandleNow: Byte;
  HandlePush: Byte;
  HandleLight: Byte;
  PushTimer: LongInt;

{ -***** Objets *****- }
  ObjetInfo: array[0..255] of record
    X1, Y1, X2, Y2: Word;
    Attribut      : Word;
    Color         : Byte;
    Color1	  : Byte;
    Text	  : String[11];
    TxtX, TxtY    : Word;
    Event         : TypeEvent;
    Event1	  : TypeEvent;
    PtrVar	  : ^Word;
    PtrMax        : ^Word;
    Pas1, Pas2    : Byte;
    Step	  : Word;
    PtrOn         : ^Boolean;
  end;
  BufferTemp: PtrBuffer;
  TexteSp: String[3];
  Choice: Integer;
  FileSelected: Byte;

const
  { Taille d'un objet }
  SizeInfo = 52;

  { Variable d'activit‚ des objets }
  ObjetAble: Boolean = true;

  { Constante de retour d'initilisation }
  NoDriver    = 1;
  NoEnoughEms = 2;
  NoMouse     = 3;

  { Curseur de la souris }
  NNN = { noir  } 250;
  BBB = { blanc } 249;
  RED = { Rouge } 248;
  MouseCursor: array[0..12 * 16 + 1] of Byte = (12, 16,
  NNN,NNN,000,000,000,000,000,000,000,000,000,000,
  NNN,BBB,NNN,000,000,000,000,000,000,000,000,000,
  NNN,BBB,BBB,NNN,000,000,000,000,000,000,000,000,
  NNN,BBB,BBB,BBB,NNN,000,000,000,000,000,000,000,
  NNN,BBB,BBB,BBB,BBB,NNN,000,000,000,000,000,000,
  NNN,BBB,BBB,BBB,BBB,BBB,NNN,000,000,000,000,000,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,NNN,000,000,000,000,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,000,000,000,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,000,000,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,000,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,NNN,NNN,NNN,
  NNN,BBB,BBB,NNN,NNN,NNN,BBB,BBB,NNN,000,000,000,
  NNN,NNN,NNN,000,000,NNN,BBB,BBB,NNN,000,000,000,
  000,000,000,000,000,000,NNN,BBB,BBB,NNN,000,000,
  000,000,000,000,000,000,NNN,BBB,BBB,NNN,000,000,
  000,000,000,000,000,000,000,NNN,NNN,NNN,000,000);

  MainCursor: array[0..9 * 12 + 1] of Byte = (9, 12,
  000,NNN,000,000,000,000,000,000,000,
  NNN,BBB,NNN,000,000,000,000,000,000,
  NNN,BBB,NNN,NNN,NNN,NNN,000,000,000,
  NNN,BBB,NNN,BBB,NNN,BBB,NNN,NNN,000,
  NNN,BBB,NNN,BBB,NNN,BBB,NNN,BBB,NNN,
  NNN,BBB,NNN,BBB,NNN,BBB,NNN,BBB,NNN,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,
  NNN,BBB,BBB,BBB,BBB,BBB,BBB,BBB,NNN,
  000,NNN,BBB,BBB,BBB,BBB,BBB,NNN,000,
  000,000,NNN,NNN,NNN,NNN,NNN,000,000);

  CursorNot: array[0..11 * 13 + 1] of Byte = (11, 13,
  000,000,NNN,000,000,000,000,000,000,000,000,
  000,NNN,BBB,NNN,000,000,000,000,000,000,000,
  000,NNN,BBB,NNN,NNN,NNN,NNN,NNN,000,000,000,
  000,NNN,NNN,RED,RED,RED,RED,RED,NNN,000,000,
  000,NNN,RED,RED,NNN,NNN,NNN,RED,RED,NNN,000,
  NNN,RED,RED,NNN,BBB,BBB,NNN,RED,RED,RED,NNN,
  NNN,RED,NNN,BBB,BBB,NNN,RED,NNN,NNN,RED,NNN,
  NNN,RED,NNN,BBB,NNN,RED,NNN,BBB,NNN,RED,NNN,
  NNN,RED,NNN,NNN,RED,NNN,BBB,BBB,NNN,RED,NNN,
  NNN,RED,RED,RED,NNN,BBB,BBB,NNN,RED,RED,NNN,
  000,NNN,RED,RED,NNN,NNN,NNN,RED,RED,NNN,000,
  000,000,NNN,RED,RED,RED,RED,RED,NNN,000,000,
  000,000,000,NNN,NNN,NNN,NNN,NNN,000,000,000);

  BarreCursor: array[0..8*8 + 1] of Byte = (8, 8,
  000,000,NNN,NNN,NNN,NNN,000,000,
  000,NNN,RED,RED,RED,RED,NNN,000,
  NNN,RED,RED,BBB,BBB,RED,RED,NNN,
  NNN,RED,BBB,RED,RED,RED,RED,NNN,
  NNN,RED,RED,RED,RED,RED,RED,NNN,
  NNN,RED,RED,RED,RED,RED,RED,NNN,
  000,NNN,RED,RED,RED,RED,NNN,000,
  000,000,NNN,NNN,NNN,NNN,000,000);

  EventOnClick = $00;
  EventOnPush  = $01;
  TextLight    = $02;
  Bouton       = $04;
  CursorMain   = $08;
  BarreH       = $10;
  BarreV       = $20;
  Cadran       = $40;

  { Pour les nombres }
  AfficheNombre: array['0'..'9'] of Byte =
  ($77, $24, $5D, $6D, $2E, $6B, $7B, $25, $7F, $6F);

  FileMusic: TypeNom = ('DESERT',
                         'GROTTE',
                         'MENU',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????',
                         '????');


procedure InitColor;
procedure InitGraph (Mode: Byte);

{ Initilise la souris }
function InitMouse: Byte;

{ S‚l‚ctionne la surface de la souris }
procedure SetWindowMouse (x1, y1, x2, y2: Word);

{ Actualise la souris }
procedure UpdateMouse;

{ Dessine un quart de cercle }
procedure BordCircle (Page, X, Y, Rayon, Partie: Word);

{ Dessine un quart de cercle avec les couleurs inverses }
procedure BordCircleI (Page, X, Y, Rayon, Partie: Word);

{ Dessine un quart de cercle de couleur Color }
procedure BordCircleC (Page, X, Y, Rayon, Partie: Word; Color: Byte);

{ Dessine un quart de cercle plein }
procedure FillCircle (Page, X, Y, Rayon, Partie: Word; Color: Byte);

{ Fait un classeur }
procedure MakeClasseur (Handle, PageActive: Byte; Xd, Yd, Xf, Yf: Word; StrPage: String; Action: TypeEvent);

{ Cr‚e un classeur }
procedure MakeBouton (Handle: Byte; X, Y: Word; Name: String; Col: Byte; Action: TypeEvent);

{ Dessine une barre horizontale }
procedure DrawBarreH (Handle: Word);

{ Dessine une barre verticale }
procedure DrawBarreV (Handle: Word);

{ Pour les boutons au bord des barres }
procedure DecVar(Sender: Word); far;
procedure IncVar(Sender: Word); far;

{ Cr‚e une barre horizontale }
procedure MakeBarreH (Handle: Byte; X, Y, Largeur: Word; var Valeur, Max: Word;
                      Tps1, Tps2: Byte; Ecart: Word; Action: TypeEvent);

{ Cr‚e une barre verticale }
procedure MakeBarreV (Handle: Byte; X, Y, Hauteur: Word; var Valeur, Max: Word;
                      Tps1, Tps2: Byte; Ecart: Word; Action: TypeEvent);

{ Dessine un carr‚ en relief }
procedure MakeRelief (X1, Y1, X2, Y2: Word; Txt: String; Color: Byte);

{ Dessine une boite }
procedure DrawBox (Handle, Xd, Yd, Xf, Yf: Word; Col: Byte);

{ Cr‚e une boite }
procedure MakeBox (Handle, Xd, Yd, Xf, Yf: Word; Col, Option: Byte; Action, Action1: TypeEvent);

{ Cr‚e une boite pour cocher }
procedure MakeSelBox (Handle, X, Y: Word; var B: WordBool; Action: TypeEvent);

{ Entre une valeur }
procedure Input (Handle: Word);

{ Cr‚e un cadran }
procedure MakeValeur (Handle, X, Y: Word; var Valeur, Max: Word; Col, Col1: Byte; Action: TypeEvent);

{ Inverse un bouton }
procedure InverseBouton (Handle: Byte);

{ Remet un bouton normal }
procedure ReInverseBouton (Handle: Byte);

{ Supprime des objets }
procedure ClearObjet(D,F:Word);

{ Copie en 32-Bits }
procedure moved (var Src, Dst; Nbr: Word);

{ Remplit en 32-Bits }
procedure filld (var Src; Nbr: Word);

procedure EcritNombre (Page: Byte; x, y: Word; Nombre: string; CouleurNb, CouleurFond, Tx, Ty, Ex, Ey: byte);

procedure MakeWindow(Largeur, Hauteur: Word; Titre: String);

{ Affiche un message }
function MessageBox(Titre, Message, Boutons: String): Byte;

{ Affiche une boite d'ouverture }
function SelectFile(FileName: TypeNom; Titre: String; SelectInit, Option: Byte): Byte;

procedure Update;

implementation

{$S-}
procedure PutPixelX; assembler;
asm
	PUSH	DI
        PUSH	DX
	PUSH	CX
        PUSH	AX
        MOV	CX,DI
        AND	CX,3
        SHR	DI,2
        MOV	DX,$3C4
        MOV	AX,$0102
        SHL	AH,CL
        OUT	DX,AX
        POP	AX
	MOV	CL,AH
	JCXZ	@@2
@@1:	ADD	DI,16000
        LOOP	@@1
@@2:	STOSB
        POP	CX
        POP	DX
        POP	DI
        INC	DI
end;
{$S+}

procedure InitColor;
begin
  { Initialise les couleurs }
  SetPaletteV (255, 19, 35, 63);
  SetPaletteV (254, 15, 31, 59);
  SetPaletteV (253, 05, 21, 53);
  SetPaletteV (252, 07, 23, 51);
  SetPaletteV (251, 03, 19, 47);
  SetPaletteV (250, 00, 00, 00);
  SetPaletteV (249, 63, 63, 63);
  SetPaletteV (248, 63, 00, 00);
  SetPaletteV (247, 00, 48, 32);
  SetPaletteV (246, 48, 48, 00);
  SetPaletteV (245, 00, 32, 16);
  SetPaletteV (244, 63, 32, 16);
  SetPaletteV (243, 00, 48, 16);
  SetPaletteV (242, 00, 00, 63);
  SetPaletteV (241, 00, 00, 42);
  SetPaletteV (240, 32, 32, 32);
  SetPaletteV (000, 11, 27, 55);
end;

procedure InitGraph;
var
  i: Byte;
  p: PtrBuffer;
begin
  { Passe en mode texte }
  InitTexte;

  { Fixe la proc‚dure de fin du programme }
  ExitProc := @Fin;

  { Installe le compteur }
  CounterOn;

  { Installe la nouvelle interruption du clavier }
  KBHon;

  { Affiche le titre }
Print (CenterText ('- Mister Patate -'), $4F);
Print (CenterText ('Attention, ne pas confier ce jeu aux fast-food!'), $12);

PrintR ('Chargement des configurations.', 7);
  LoadConfig;

  if Mode and 1 = 0 then begin
PrintR ('Chargement des sprites.', 7);
   LoadSprite;
   end;

  if Mode and 2 = 0 then begin
PrintR ('Allocation de la m‚moire.', 7);
  TestAlloue (1); GetMem (p, 1);
  if LongInt (p) and 15 <> 0 then begin
    release (p);
    GetMem (p, 15 - (LongInt (p) and 15));
  end else release (p);
  AlloueBuffer (Decor);
  AlloueBuffer (P);
  Plan[0] := Ptr (Seg(P^),0);
  Plan[1] := Ptr (Seg(P^)+$800,0);
  AlloueBuffer (P);
  Plan[2] := Ptr (Seg(P^),0);
  Plan[3] := Ptr (Seg(P^)+$800,0);
  end;
  AlloueBuffer (BufferTemp);

PrintR ('Initialisation de la carte son.', 7);
  if not InitSound then begin
    PrintR ('Carte son non pr‚sente ou driver non install‚.', 14);
    inc (InitError);
  end else  { S‚lectionne les instruments }
    for i := 4 to 8 do SetChannelIns (i, InsChannel[i]);


  if InitError > 0 then Pause (InitError * 200);

  { Passe en mode VGA }
  InitVga;


  { Initialise la souris }
  case InitMouse of
    NoDriver: Erreur ('l''initialisation de la souris','driver non pr‚sent.');
    NoMouse : Erreur ('l''initialisation de la souris','souris non pr‚sente.');
  end;

  InitColor;
  if Mode and 1 = 0 then OutPalette(0,255)
  else begin
    OutPalette(0,0);
    OutPalette(240,255);
  end;
  Cls (2, 0);
end;

{ Initilise la souris }
function InitMouse; assembler;
asm
{ -* V‚rifie la pr‚sence du driver *- }
	XOR	AX,AX
        MOV	ES,AX
        MOV	AL,NoDriver
DB $66; TEST	ES:WORD PTR [00CCh],$FFFF; DW $FFFF
        JZ	@Fin
{ -* V‚rifie la pr‚sence de la souris -* }
        XOR	AX,AX
        INT	33h
        OR	AX,AX
        MOV	AL,NoMouse
        JE	@Fin { Si il n'y a pas de souris, on quitte }
        XOR	AL,AL
@Fin:
end;

procedure SetWindowMouse; assembler;
asm
        XOR	AL,AL
	MOV	AX,0007h
        MOV	CX,[x1]
        SHL	CX,1
        MOV	DX,[x2]
        SHL	DX,1
        INC	DX
        INT	33h
        MOV	AX,0008h
        MOV	CX,[y1]
        MOV	DX,[y2]
        INT	33h
end;

procedure UpdateMouse;
begin
  asm
	MOV	AX,$0003
        INT	$33
        MOV	AL,BL
        AND	AL,1
        MOV	[MouseBL],AL
        MOV	AL,BL
        AND	AL,2
        MOV	[MouseBR],AL
        AND	BL,4
        MOV	[MouseBC],BL
        SHR	CX,1
        MOV	[MouseX],CX
        MOV	[MouseY],DX
  end;
  HandleNow := GetPixel (2, MouseX, MouseY);
  MouseXr := MouseX - ObjetInfo[HandleNow].X1;
  MouseYr := MouseY - ObjetInfo[HandleNow].Y1;
end;

procedure BordCircle;
var
  angle: Word;
  Perimetre: Word;
begin
  { Calcul le quart du perimetre }
  Perimetre := Round (Rayon * Pi / 2);
  { Trace les parties du cerle }
  if Partie and 1 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 252 - (angle shl 1) div (Perimetre+1));
  if Partie and 2 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 254 - ((angle shl 1) div (Perimetre+1)) * 3);
  if Partie and 4 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 254 + (angle shl 1) div (Perimetre+1));
  if Partie and 8 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 252 + ((angle shl 1) div (Perimetre+1)) * 3);
end;

procedure BordCircleI;
var
  angle: Word;
  Perimetre: Word;
begin
  { Calcul le quart du perimetre }
  Perimetre := Round (Rayon * Pi / 2);
  { Trace les parties du cerle }
  if Partie and 1 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 254 + (angle shl 1) div (Perimetre+1));
  if Partie and 2 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 252 + ((angle shl 1) div (Perimetre+1)) * 3);
  if Partie and 4 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 252 - (angle shl 1) div (Perimetre+1));
  if Partie and 8 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), 254 - ((angle shl 1) div (Perimetre+1)) * 3);
end;

procedure BordCircleC;
var
  angle: Word;
  Perimetre: Word;
begin
  { Calcul le quart du perimetre }
  Perimetre := Round (Rayon * Pi / 2);
  { Trace les parties du cerle }
  if Partie and 1 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), Color);
  if Partie and 2 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), Color);
  if Partie and 4 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), Color);
  if Partie and 8 <> 0 then for angle := 0 to Perimetre do
    PutPixel (Page, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon)
                  , Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon), Color);
end;

procedure FillCircle;
var
  angle: Word;
  Perimetre: Word;
begin
  { Calcul le quart du perimetre }
  Perimetre := Round (Rayon * Pi / 2);
  { Trace les parties du cerle }
  if Partie and 1 <> 0 then for angle := 0 to Perimetre do
    LineH (Page, Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon)
            , X, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon), Color);
  if Partie and 2 <> 0 then for angle := 0 to Perimetre do
    LineH (Page, Y + Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon)
            , X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon), X, Color);
  if Partie and 4 <> 0 then for angle := 0 to Perimetre do
    LineH (Page, Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon)
            , X - Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon), X, Color);
  if Partie and 8 <> 0 then for angle := 0 to Perimetre do
    LineH (Page, Y - Round (Sin (angle * Pi / (Perimetre * 2)) * Rayon)
            , X, X + Round (Cos (angle * Pi / (Perimetre * 2)) * Rayon), Color);
end;

procedure MakeClasseur;
var
  PosPage, i: Byte;
  TmpStr: String[40];
begin
  BordCircle (1, Xd + 7, Yf - 7, 7, 2);
  BordCircle (1, Xf - 7, Yf - 7, 7, 1);
  LineV (1, Xd, Yd + 16, Yf - 8, 254);
  LineH (1, Yf, Xd + 8, Xf - 8, 251);
  if PageActive <> 1 then BordCircle (1, Xd + 7, Yd + 23, 7, 4);
  PosPage := 1;
  repeat
    i := Pos ('/', StrPage);
    if i = 0 then TmpStr := StrPage
    else begin
      TmpStr := Copy (StrPage, 1, i - 1);
      Delete (StrPage, 1, i);
    end;
    BordCircle (1, Xd + 7, Yd + 7, 7, 4);
    BordCircle (1, Xd + 8 + Length (TmpStr) shl 3, Yd + 7, 7, 8);
    LineV (1, Xd, Yd + 8, Yd + 15, 254);
    LineH (1, Yd, Xd + 8, Xd + 7 + Length (TmpStr) shl 3, 255);
    if Xd  + 15 + Length (TmpStr) shl 3 = Xf then
      LineV (1, Xd + 15 + Length (TmpStr) shl 3, Yd + 8, Yf - 8, 252)
    else LineV (1, Xd + 15 + Length (TmpStr) shl 3, Yd + 8, Yd + 16, 252);
    if PosPage <> PageActive then begin
      if Xd  + 15 + Length (TmpStr) shl 3 = Xf then begin
        LineH (1, Yd + 16, Xd, Xd + 7 + Length (TmpStr) shl 3, 255);
        BordCircle (1, Xd + 8 + Length (TmpStr) shl 3, Yd + 23, 7, 8);
      end else if PosPage = 1 then begin
        LineH (1, Yd + 16, Xd + 8, Xd + 16 + Length (TmpStr) shl 3, 255);
        BordCircle (1, Xd + 7, Yd + 23, 7, 4);
      end else LineH (1, Yd + 16, Xd, Xd + 16 + Length (TmpStr) shl 3, 255);
    end;
    FillCircle (2, Xd + 7, Yd + 7, 6, 4, Handle+PosPage-1);
    FillCircle (2, Xd + 8 + Length (TmpStr) shl 3, Yd + 7, 6, 8, Handle+PosPage-1);
    FillBox (2, Xd + 8, Yd + 1, Xd + 7 + Length (TmpStr) shl 3, Yd + 7, Handle+PosPage-1);
    FillBox (2, Xd + 1, Yd + 8, Xd + 14 + Length (TmpStr) shl 3, Yd + 15, Handle+PosPage-1);
    if GetPixel (2, MouseX, MouseY) = Handle + PosPage - 1 then
      OutText8 (1, Xd + 8, Yd + 6, TmpStr, 247,Tsp,false)
    else OutText8 (1, Xd + 8, Yd + 6, TmpStr, 246,Tsp,false);
    with ObjetInfo[Handle+PosPage-1] do begin
      TxtX := Xd + 8;
      TxtY := Yd + 6;
      Text := TmpStr;
      Color := 246;
      Attribut := TextLight + CursorMain + EventOnPush;
      Event := Action;
      Pas1 := 255;
      Pas2 := 255;
      PtrOn := @ObjetAble;
    end;
    inc (PosPage);
    inc (Xd, 16 + Length (TmpStr) shl 3);
  until i = 0;
  if Xd - 1 < Xf then begin
    LineH (1, Yd + 16, Xd, Xf - 8, 255);
    LineV (1, Xf, Yd + 24, Yf - 8, 252);
    BordCircle (1, Xf - 7, Yd + 23, 7, 8);
  end;
end;

procedure MakeBouton;
begin with ObjetInfo[Handle] do begin
  X1 := X;
  Y1 := Y;
  X2 := X + 7 + Length (Name) shl 3;
  Y2 := Y + 15;
  Text := Name;
  Color := Col;
  TxtX := X + 4;
  TxtY := Y + 4;
  Attribut := TextLight + CursorMain + EventOnClick + Bouton;
  Event := Action;
  PtrOn := @ObjetAble;
  BordCircle (1, X1 + 7, Y1 + 7, 7, 4);
  BordCircle (1, X1 + 7, Y2 - 7, 7, 2);
  BordCircle (1, X2 - 7, Y1 + 7, 7, 8);
  BordCircle (1, X2 - 7, Y2 - 7, 7, 1);
  FillCircle (2, X1 + 7, Y1 + 7, 6, 4, Handle);
  FillCircle (2, X1 + 7, Y2 - 7, 6, 2, Handle);
  FillCircle (2, X2 - 7, Y1 + 7, 6, 8, Handle);
  FillCircle (2, X2 - 7, Y2 - 7, 6, 1, Handle);
  if Length (Name) > 1 then begin
    LineH (1, Y1, X1 + 8, X2 - 8, 255);
    LineH (1, Y2, X1 + 8, X2 - 8, 251);
    FillBox (2, X1 + 8, Y1 + 1, X2 - 8, Y2 - 1, Handle);
  end;
  OutText8 (1, TxtX, TxtY, Text, Color,Tsp,false);
end; end;

procedure DrawBarreH;
begin with ObjetInfo[Handle] do begin
  FillBox (1, X1 + 4, Y1 + 4, X2 - 4, Y2 - 4, 0);
  BordCircleI (1, X1 + 7, Y1 + 7, 3, 4);
  BordCircleI (1, X1 + 7, Y2 - 7, 3, 2);
  BordCircleI (1, X2 - 7, Y1 + 7, 3, 8);
  BordCircleI (1, X2 - 7, Y2 - 7, 3, 1);
  LineH (1, Y1 + 4, X1 + 7, X2 - 7, 251);
  LineH (1, Y2 - 4, X1 + 7, X2 - 7, 255);
  PutSprite (1, X1 + Round ((X2 - X1 - 15) / PtrMax^ * PtrVar^) + 4, Y1 + 4, 0, BarreCursor);
end; end;

procedure DrawBarreV;
begin with ObjetInfo[Handle] do begin
  FillBox (1, X1 + 4, Y1 + 4, X2 - 4, Y2 - 4, 0);
  BordCircleI (1, X1 + 7, Y1 + 7, 3, 4);
  BordCircleI (1, X1 + 7, Y2 - 7, 3, 2);
  BordCircleI (1, X2 - 7, Y1 + 7, 3, 8);
  BordCircleI (1, X2 - 7, Y2 - 7, 3, 1);
  LineV (1, X1 + 4, Y1 + 7, Y2 - 7, 252);
  LineV (1, X2 - 4, Y1 + 7, Y2 - 7, 254);
  PutSprite (1, X1 + 4, Y1 + Round ((Y2 - Y1 - 15) / PtrMax^ * PtrVar^) + 4, 0, BarreCursor);
end; end;

procedure DecVar;
begin with ObjetInfo[Sender-1] do begin
  if PtrVar^ > 0 then begin
    if PtrVar^ >= Step then Dec (PtrVar^, Step) else PtrVar^ := 0;
    if Attribut and BarreH <> 0 then DrawBarreH (Sender-1) else DrawBarreV (Sender-1);
    if @Event <> nil then Event (Sender-1);
  end;
end; end;

procedure IncVar;
begin with ObjetInfo[Sender-2] do begin
  if PtrVar^ < PtrMax^ then begin
    if PtrVar^ <= PtrMax^ - Step then Inc (PtrVar^, Step) else PtrVar^ := PtrMax^;
    if Attribut and BarreH <> 0 then DrawBarreH (Sender-2) else DrawBarreV (Sender-2);
    if @Event <> nil then Event (Sender-2);
  end;
end; end;

procedure MakeBarreH;
begin with ObjetInfo[Handle] do begin
  X1 := X + 16;
  Y1 := Y;
  X2 := X + Largeur - 16;
  Y2 := Y + 15;
  Attribut := CursorMain + EventOnPush + BarreH;
  Event := Action;
  PtrVar := @Valeur;
  PtrMax := @Max;
  Pas1 := Tps1;
  Pas2 := Tps2;
  Step := Ecart;
  PtrOn := @ObjetAble;
  BordCircle (1, X1 + 7, Y1 + 7, 7, 4);
  BordCircle (1, X1 + 7, Y2 - 7, 7, 2);
  BordCircle (1, X2 - 7, Y1 + 7, 7, 8);
  BordCircle (1, X2 - 7, Y2 - 7, 7, 1);
  FillCircle (2, X1 + 7, Y1 + 7, 3, 4, Handle);
  FillCircle (2, X1 + 7, Y2 - 7, 3, 2, Handle);
  FillCircle (2, X2 - 7, Y1 + 7, 3, 8, Handle);
  FillCircle (2, X2 - 7, Y2 - 7, 3, 1, Handle);
  FillBox (2, X1 + 4, Y1 + 4, X2 - 4, Y2 - 4, Handle);
  LineH (1, Y1, X1 + 8, X2 - 8, 255);
  LineH (1, Y2, X1 + 8, X2 - 8, 251);
  DrawBarreH (Handle);
  MakeBouton (Handle + 1, X, Y1, #246, 249, DecVar);
  with ObjetInfo[Handle+1] do begin
    Attribut :=Attribut or 1;
    Pas1 := Tps1;
    Pas2 := Tps2;
  end;
  MakeBouton (Handle + 2, X + Largeur - 15, Y1, #247, 249, IncVar);
  with ObjetInfo[Handle+2] do begin
    Attribut :=Attribut or 1;
    Pas1 := Tps1;
    Pas2 := Tps2;
  end;
end; end;

procedure MakeBarreV;
begin with ObjetInfo[Handle] do begin
  X1 := X;
  Y1 := Y + 16;
  X2 := X + 15;
  Y2 := Y + Hauteur - 16;
  Attribut := CursorMain + EventOnPush + BarreV;
  Event := Action;
  PtrVar := @Valeur;
  PtrMax := @Max;
  Pas1 := Tps1;
  Pas2 := Tps2;
  Step := Ecart;
  PtrOn := @ObjetAble;
  BordCircle (1, X1 + 7, Y1 + 7, 7, 4);
  BordCircle (1, X1 + 7, Y2 - 7, 7, 2);
  BordCircle (1, X2 - 7, Y1 + 7, 7, 8);
  BordCircle (1, X2 - 7, Y2 - 7, 7, 1);
  FillCircle (2, X1 + 7, Y1 + 7, 3, 4, Handle);
  FillCircle (2, X1 + 7, Y2 - 7, 3, 2, Handle);
  FillCircle (2, X2 - 7, Y1 + 7, 3, 8, Handle);
  FillCircle (2, X2 - 7, Y2 - 7, 3, 1, Handle);
  FillBox (2, X1 + 4, Y1 + 4, X2 - 4, Y2 - 4, Handle);
  LineV (1, X1, Y1 + 8, Y2 - 8, 254);
  LineV (1, X2, Y1 + 8, Y2 - 8, 252);
  DrawBarreV (Handle);
  MakeBouton (Handle + 1, X1, Y, #244, 249, DecVar);
  with ObjetInfo[Handle+1] do begin
    Attribut :=Attribut or 1;
    Pas1 := Tps1;
    Pas2 := Tps2;
  end;
  MakeBouton (Handle + 2, X1, Y + Hauteur - 15, #245, 249, IncVar);
  with ObjetInfo[Handle+2] do begin
    Attribut :=Attribut or 1;
    Pas1 := Tps1;
    Pas2 := Tps2;
  end;
end; end;

procedure MakeRelief;
begin
  LineH (1, Y1    , X1 + 1, X2    , 251);
  LineH (1, Y1 + 1, X1 + 2, X2 - 1, 255);
  LineH (1, Y2    , X1    , X2 - 1, 255);
  LineH (1, Y2 - 1, X1 + 1, X2 - 2, 251);
  LineV (1, X1    , Y1    , Y2 - 1, 252);
  LineV (1, X1 + 1, Y1 + 1, Y2 - 2, 254);
  LineV (1, X2    , Y1 + 1, Y2    , 254);
  LineV (1, X2 - 1, Y1 + 2, Y2 - 1, 252);
  OutText8 (1, X1 + 4, Y1 - 4, Txt, Color, 0,false);
end;

procedure DrawBox;
begin
  FillBox (1, Xd + 1, Yd + 1, Xf - 1, Yf - 1, Col);
  LineV (1, Xd, Yd, Yf - 1, 252);
  LineH (1, Yd, Xd + 1, Xf, 251);
  LineV (1, Xf, Yd + 1, Yf, 254);
  LineH (1, Yf, Xd, Xf - 1, 255);
  if Handle > 0 then FillBox (2, Xd + 1, Yd + 1, Xf - 1, Yf - 1, Handle);
end;

procedure MakeBox;
begin with ObjetInfo[Handle] do begin
  X1 := Xd + 1;
  Y1 := Yd + 1;
  X2 := Xf - 1;
  Y2 := Yf - 1;
  Color := Col;
  Attribut := Option;
  Event  := Action;
  Event1 := Action1;
  PtrOn := @ObjetAble;
  FillBox (1, Xd + 1, Yd + 1, Xf - 1, Yf - 1, Col);
  FillBox (2, Xd + 1, Yd + 1, Xf - 1, Yf - 1, Handle);
  LineV (1, Xd, Yd, Yf - 1, 252);
  LineH (1, Yd, Xd + 1, Xf, 251);
  LineV (1, Xf, Yd + 1, Yf, 254);
  LineH (1, Yf, Xd, Xf - 1, 255);
end; end;

procedure SelVar(Sender: Word); far;
var
  action: TypeEvent;
begin with ObjetInfo[Sender] do begin
  if PtrVar^ <> 0 then begin
    PtrVar^ := 0;
    OutText8 (1, X1-1, Y1-1, #241, 249,Tsp,false);
  end else begin
    PtrVar^ := $FFFF;
    OutText8 (1, X1-1, Y1-1, #241, 243,Tsp,false);
  end;
  move (Text, action, 4);
  if @action <> nil then action (Sender);
end; end;

procedure MakeSelBox;
begin
  MakeBox (Handle, x, y, x + 7, y + 7, 249, CursorMain+EventOnPush, SelVar, nil);
  with ObjetInfo[Handle] do begin
    PtrVar := @B;
    move (Action, Text, 4);
    Pas1 := 255;
    Pas2 := 255;
  end;
  if B then OutText8 (1, X, Y, #241, 243,Tsp,false) else OutText8 (1, X, Y, #241, 249,Tsp,false);
end;

procedure Input;
var
  Key: Char;
  S: String[10];
  T: LongInt;
  Curseur: Char;
  LenMax: Word;
begin with ObjetInfo[Handle] do begin
  T := Timer + 4;
  Curseur := #255;
  S := Str (PtrVar^, 0);
  LenMax := Length (Str (PtrMax^, 0));
  repeat
    { Affiche le nombre }
    PCopy (1, Page_not_display);
    FillBox (Page_not_display, X1, Y1, X2+8, Y2, Color1);
    OutText8 (Page_not_display, X1, Y1, S + Curseur, Color,Tsp,false);
    ShowPage;
    { Test si on change le curseur }
    if Timer > T then begin
      T := Timer+4;
      Curseur := Char (not Ord (Curseur));
    end;
    { Traite la frappe d'une touche }
    Key := inkey;
    case Key of
      '0'..'9': if Length (S) < LenMax then S := S + Key;
      CharEntree: begin
        FillBox (1, X1, Y1, X2+8, Y2, Color1);
        PtrVar^ := Val (S);
        if PtrVar^ > PtrMax^ then PtrVar^ := PtrMax^;
        exit;
      end;
      CharEchap: begin
        FillBox (1, X1, Y1, X2+8, Y2, Color1);
        exit;
      end;
      CharDel: if Length (S) > 0 then S[0] := Char (Ord (S[0]) - 1);
    end;
  until false;
end; end;

procedure MakeValeur;
var
  LenMax: Word;
begin with ObjetInfo[Handle] do begin
  LenMax := Length (Str (Max, 0));
  X1 := X;
  Y1 := Y;
  X2 := X + LenMax shl 3 - 1;
  Y2 := Y + 7;
  Color := Col;
  Color1 := Col1;
  Attribut := CursorMain or EventOnClick or Cadran;
  Event := Action;
  PtrVar := @Valeur;
  PtrMax := @Max;
  PtrOn := @ObjetAble;
  FillBox (1, X1, Y1, X2, Y2, Col1);
  FillBox (2, X1, Y1, X2, Y2, Handle);
end; end;

procedure InverseBouton;
begin with ObjetInfo[Handle] do begin
  BordCircleI (1, X1 + 7, Y1 + 7, 7, 4);
  BordCircleI (1, X1 + 7, Y2 - 7, 7, 2);
  BordCircleI (1, X2 - 7, Y1 + 7, 7, 8);
  BordCircleI (1, X2 - 7, Y2 - 7, 7, 1);
  FillCircle (1, X1 + 7, Y1 + 7, 6, 4, 253);
  FillCircle (1, X1 + 7, Y2 - 7, 6, 2, 253);
  FillCircle (1, X2 - 7, Y1 + 7, 6, 8, 253);
  FillCircle (1, X2 - 7, Y2 - 7, 6, 1, 253);
  if Length (Text) > 1 then begin
    LineH (1, Y1, X1 + 8, X2 - 8, 251);
    LineH (1, Y2, X1 + 8, X2 - 8, 255);
    FillBox (1, X1 + 8, Y1 + 1, X2 - 8, Y2 - 1, 253);
  end;
  OutText8(1, TxtX, TxtY, Text, 245,Tsp,false);
end; end;

procedure ReInverseBouton;
begin with ObjetInfo[Handle] do begin
  BordCircle (1, X1 + 7, Y1 + 7, 7, 4);
  BordCircle (1, X1 + 7, Y2 - 7, 7, 2);
  BordCircle (1, X2 - 7, Y1 + 7, 7, 8);
  BordCircle (1, X2 - 7, Y2 - 7, 7, 1);
  FillCircle (1, X1 + 7, Y1 + 7, 6, 4, 0);
  FillCircle (1, X1 + 7, Y2 - 7, 6, 2, 0);
  FillCircle (1, X2 - 7, Y1 + 7, 6, 8, 0);
  FillCircle (1, X2 - 7, Y2 - 7, 6, 1, 0);
  if Length (Text) > 1 then begin
    LineH (1, Y1, X1 + 8, X2 - 8, 255);
    LineH (1, Y2, X1 + 8, X2 - 8, 251);
    FillBox (1, X1 + 8, Y1 + 1, X2 - 8, Y2 - 1, 0);
  end;
  if (Attribut and TextLight <> 0) and (Handle = HandleNow) then begin
    OutText8 (1, TxtX, TxtY, Text, 247,Tsp,false);
    HandleLight := Handle;
  end else OutText8 (1, TxtX, TxtY, Text, Color,Tsp,false);
end; end;

procedure ClearObjet;
begin
  FillChar (ObjetInfo[D], SizeInfo * (F - D + 1), 0);
end;

procedure moved; assembler;
asm
	PUSH	DS
        LDS	SI,Src
        LES	DI,Dst
        MOV	CX,Nbr
DB $66; REP	MOVSW
	POP	DS
end;

procedure filld; assembler;
asm
	LES	DI,Src
        MOV	CX,Nbr
DB $66; XOR	AX,AX
DB $66; REP	STOSW
end;

procedure EcritNombre;
var
   P   : Byte;
   Aff : Byte;
begin;
  for P := 1 to Length(Nombre) do begin
    if not (Nombre[P] in ['0'..'9']) then begin
      Inc( x, Ey shl 1 + Ey + Tx);
      Continue;
    end else Aff := AfficheNombre[NomBre[P]];

    if (Aff and $01) = $01 then
       FillBox (1, x + Ey , y , x + Ey + Tx -1, y + Ex -1, CouleurNb)
    else
       FillBox (1, x + Ey , y , x + Ey + Tx -1, y + Ex -1, CouleurFond);

    if (Aff and $02) = $02 then
       FillBox (1, x , y + Ex , x + Ey -1, y + Ex + Ty -1, CouleurNb)
    else
       FillBox (1, x , y + Ex , x + Ey -1, y + Ex + Ty -1, CouleurFond);

    if (Aff and $04) = $04 then
       FillBox (1, x + Ey + Tx , y + Ex , x + Ey shl 1 + Tx -1, y + Ex + Ty -1, CouleurNb)
    else
       FillBox (1, x + Ey + Tx , y + Ex , x + Ey shl 1 + Tx -1, y + Ex + Ty -1, CouleurFond);

    if (Aff and $08) = $08 then
       FillBox (1, x + Ey , y + Ex + Ty , x + Ey + Tx -1, y + Ex shl 1 + Ty -1, CouleurNb)
    else
       FillBox (1, x + Ey , y + Ex + Ty , x + Ey + Tx -1, y + Ex shl 1 + Ty -1, CouleurFond);

    if (Aff and $10) = $10 then
       FillBox (1, x , y + Ex shl 1 + Ty , x + Ey -1, y + Ex shl 1 + Ty shl 1 -1, CouleurNb)
    else
       FillBox (1, x , y + Ex shl 1 + Ty , x + Ey -1, y + Ex shl 1 + Ty shl 1 -1, CouleurFond);

    if (Aff and $20) = $20 then
       FillBox (1, x + Ey + Tx , y + Ex shl 1 + Ty , x + Ey shl 1 + Tx -1, y + Ex shl 1 + Ty shl 1 -1, CouleurNb)
    else
       FillBox (1, x + Ey + Tx , y + Ex shl 1 + Ty , x + Ey shl 1 + Tx -1, y + Ex shl 1 + Ty shl 1 -1, CouleurFond);

    if (Aff and $40) = $40 then
       FillBox (1, x + Ey , y + Ex shl 1 + Ty shl 1 , x + Ey + Tx -1, y + Ex shl 1 + Ex + Ty shl 1 -1, CouleurNb)
    else
       FillBox (1, x + Ey , y + Ex shl 1 + Ty shl 1 , x + Ey + Tx -1, y + Ex shl 1 + Ex + Ty shl 1 -1, CouleurFond);

    Inc(x, Ey shl 1 + Ey + Tx);
  end;

end;

procedure MakeWindow;
var
  X1, Y1, X2, Y2: Word;
begin
  FillChar (ObjetInfo, SizeOf(ObjetInfo), 0);
  Cls(2, 0);
  X1 := 160-Largeur shr 1;
  Y1 := 100-Hauteur shr 1;
  X2 := X1 + Largeur;
  Y2 := Y1 + Hauteur;
  FillCircle (1, X1 + 7, Y1 + 7, 7, 4, 242);
  FillCircle (1, X2 - 7, Y1 + 7, 7, 8, 242);
  FillCircle (1, X1 + 7, Y2 - 7, 7, 2, 0);
  FillCircle (1, X2 - 7, Y2 - 7, 7, 1, 0);
  FillBox(1, X1+8, Y1+1, X2-8, Y1+9, 242);
  FillBox(1, X1+1, Y1+8, X2-1, Y1+9, 242);
  FillBox(1, X1+1, Y1+10, X2-1, Y2-8, 0);
  FillBox(1, X1+8, Y2-7, X2-8, Y2-1, 0);
  BordCircle (1, X1 + 7, Y1 + 7, 7, 4);
  BordCircle (1, X1 + 7, Y2 - 7, 7, 2);
  BordCircle (1, X2 - 7, Y1 + 7, 7, 8);
  BordCircle (1, X2 - 7, Y2 - 7, 7, 1);
  LineH (1, Y1, X1 + 8, X2 - 8, 255);
  LineH (1, Y2, X1 + 8, X2 - 8, 251);
  LineV (1, X1, Y1 + 8, Y2 - 8, 254);
  LineV (1, X2, Y1 + 8, Y2 - 8, 252);
  OutText8 (1, X1+8, Y1+2, Titre, 249, Tsp,false);
end;


procedure OkSelect(Sender: Word); far;
begin
  Choice := FileSelected;
end;
procedure AnnulerSelect(Sender: Word); far;
begin
  Choice := 16;
end;

procedure SelectFileInBox(Sender: Word); far;
begin
  FileSelected := MouseYr shr 3;
end;
procedure messagerep(Sender: Word); far;
begin
  Choice := Sender;
end;
function MessageBox;
var
  p: Byte;
  x,h: Word;
begin
  Choice := -1;
  MakeWindow(Length(Message) shl 3+6,51,Titre);
  OutText8(1,Centre,Centre,Message,246,tsp,true);
  p := Pos('/',Boutons);
  x := 159 - Length(Message) shl 2;
  h := 1;
  while p <> 0 do begin
    MakeBouton(h, x, 109, copy(boutons,1,p-1), 246, messagerep);
    inc(x,(p+1)shl 3);
    delete(boutons,1,p);
    p := Pos('/',Boutons);
  end;
  repeat
    update;
  until choice <> -1;
  MessageBox := Choice;
end;

function SelectFile;
var
  i: Byte;
  St: String[31];
begin
  FileSelected := SelectInit;
  Choice := -1;
  MakeWindow(254, 160, Titre);
  MakeBouton(1, 35, 163, ' OK ', 246, OkSelect);
  if Option and 1 = 0 then MakeBouton(2, 83, 163, 'Annuler', 246, AnnulerSelect);
  MakeBox(3, 35, 32, 284, 161, 242, CursorMain+EventOnPush, SelectFileInBox, nil);
  repeat
    Update;
    with ObjetInfo[3] do
    for i := 0 to 15 do begin
      St := FileName[i];
      if Length(St) < 31 then St := St + StrChar(' ', 31-Length(St));
      if i = FileSelected then
           OutText8(1, X1, Y1+i shl 3, St, 249, 9, false)
      else OutText8(1, X1, Y1+i shl 3, St, 250, 249, false);
    end;
  until Choice <> -1;
  SelectFile := Choice;
end;

procedure Update;
begin
    { Actualise la souris }
    UpdateMouse;

    { Traite les evennements }
    with ObjetInfo[HandleNow] do begin

      PCopy (1, Page_not_display);

      if TexteSp <> '' then begin
        OutText8 (Page_not_display, MouseX+10, MouseY, TexteSp, 246, tsp, true);
        TexteSp := '';
      end;

      { Affiche la souris }
      if not PtrOn^ then PutSprite (Page_not_display, MouseX, MouseY, 0, CursorNot)
      else if Attribut and CursorMain <> 0 then
        PutSprite (Page_not_display, MouseX, MouseY, 0, MainCursor)
      else PutSprite (Page_not_display, MouseX, MouseY, 0, MouseCursor);

      { Affiche … l'‚cran }
      ShowPage;

      { Si un texte doit s'‚teindre }
      if (HandleLight <> HandleNow) and (HandleLight <> 0) then begin
        with ObjetInfo[HandleLight] do OutText8 (1, TxtX, TxtY, Text, Color,Tsp, false);
        HandleLight := 0;
      end;

      { Si un texte doit s'allumer }
      if (Attribut and TextLight <> 0) and (HandleLight <> HandleNow) then begin
        OutText8 (1, TxtX, TxtY, Text, 247,Tsp, false);
        HandleLight := HandleNow;
      end;

      { Si un bouton doit s'‚teindre }
      if HandlePush <> HandleNow then with ObjetInfo[HandlePush] do begin
        if ObjetInfo[HandlePush].Attribut and Bouton <> 0 then ReInverseBouton (HandlePush);
        HandlePush := 0;
      end;

      { Si un bouton est enfonc‚ }
      if MouseBL and PtrOn^ then begin
        { Si c'est une barre horizontale }
        if Attribut and BarreH <> 0 then begin
          { Calcul de la position du curseur de la barre }
          if MouseX < X1 + 7 then PtrVar^ := 0
          else PtrVar^ := Round ((MouseX-X1-7) / (X2 - X1 - 15) * PtrMax^ );
          if PtrVar^ > PtrMax^ then PtrVar^ := PtrMax^;
          { Tracage de la barre }
          DrawBarreH (HandleNow);
          { D‚clenche l'‚vennement }
          if (@Event <> nil) then Event (HandleNow);
        { Si c'est une barre verticale }
        end else if Attribut and BarreV <> 0 then begin
          { Calcul de la position du curseur de la barre }
          if MouseY < Y1 + 7 then PtrVar^ := 0
          else PtrVar^ := Round ((MouseY-Y1-7) / (Y2 - Y1 - 15) * PtrMax^ );
          if PtrVar^ > PtrMax^ then PtrVar^ := PtrMax^;
          { Tracage de la barre }
          DrawBarreV (HandleNow);
          { D‚clenche l'‚vennement }
          if (@Event <> nil) then Event (HandleNow);
        { Si l'objet n'est pas encore appuy‚ }
        end else if HandlePush <> HandleNow then begin
          HandlePush := HandleNow;
          { SI c'est un bouton, on l'inverse }
          if Attribut and Bouton <> 0 then InverseBouton (HandleNow);
          { Si l'‚vennement se d‚clenche lorsque }
	  { l'on clique, alors on l'appel        }
          if Attribut and 1 = EventOnPush then begin
	    if (@Event <> nil) then Event (HandleNow);
            { Sauvergarde du timer pour le d‚lai d'attente }
            PushTimer := Timer + Pas1;
          end;
          { Si l'‚vennement se d‚clenche lorsque   }
	  { l'on clique et que le d‚lai est pass‚, }
	  { alors on l'appel                       }
        end else if Attribut and 1 = EventOnPush then if Timer >= PushTimer then begin
          if (@Event <> nil) then Event (HandleNow);
          { Sauvergarde du timer pour ralentir }
          PushTimer := Timer + Pas2;
        end;
      { Si un bouton est appuy‚ est que l'on ne clique plus }
      end else if HandlePush <> 0 then begin
        { Si l'‚vennement se d‚clenche lorsque }
        { l'on clique et que l'on relache,     }
	{ alors on l'appel                     }
        if (HandlePush = HandleNow) and (Attribut and 1 = EventOnClick) then begin
          if Attribut and Cadran <> 0 then Input(HandleNow);
	  if (@Event <> nil) then Event (HandleNow);
        end;
        { Si c'est un bouton, on le r‚inverse }
        if Attribut and Bouton <> 0 then ReInverseBouton (HandlePush);
        HandlePush := 0;
      end;
      if MouseBR and PtrOn^ and (@Event1 <> nil) then Event1(HandleNow);
  end;
end;

end.
