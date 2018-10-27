
{ Chargement des sprites et niveaux }
unit MrpLoad;

interface

type
  { Taille d'un buffer de sprite }
  Buffer = array[0..$FFFE] of Byte;
  PtrBuffer = ^Buffer;

  { Taille d'un Buffer de niveau }
  BufferStage = array[0..$7FFF] of Byte;
  PtrBufferStage = ^Buffer;

  { Dimmension des sprites }
  Dimmension = record
    Largeur, Hauteur: Byte;
  end;

  { Pour les sprites }
  TypeObjet = array[0..255] of Word;

  { Pour les noms }
  TypeNom = array[0..15] of String[31];

const
  { Nom des niveaux }
  Nom: TypeNom = (
    'LE MEXIQUE',
    'LA PLANQUE DES BRIGANTS',
    'LE DESERT DE LA SOIF',
    'LE VILLAGE COW-BOYS',
    'LE TRAIN',
    'ATENTION! BIG MAISON!',
    'LA CAVE HUMIDE',
    'A TRVERS LA FORET',
    'LA GRANDE TRAVERSEE',
    'AU FOND DE LA MINE',
    'A L''ASSAULT DE LA MEGA PLANQUE',
    'ALERTE ROUGE!',
    '????',
    '????',
    '????',
    'NIVEAU BONNUS');

var
  { Buffer de sprite }
  Decor: PtrBuffer;

  { Tableau contenant le niveau }
  Plan: array[0..3] of PtrBufferStage;

  { Information sur les sprites }
  DimSprite: array[0..511] of Dimmension;
  PtrSprite: array[0..511] of Pointer;

  { Informations sur les objets }
  ObjetX     : TypeObjet;
  ObjetY     : TypeObjet;
  ObjetSprite: TypeObjet;
  ObjetAttr  : TypeObjet;
  ObjetStatut: TypeObjet;
  ObjetElan  : TypeObjet;
  ObjetHSize : TypeObjet;
  ObjetVSize : TypeObjet;
  ObjetAttr2 : TypeObjet;
  ObjetLim1  : TypeObjet;
  ObjetLim2  : TypeObjet;
  ObjetProc  : TypeObjet;
  ObjetGetSp : TypeObjet;
  ObjetStat2 : TypeObjet;
  ObjetCount : TypeObjet;
  SaveObjet  : array[0..10] of TypeObjet;

  { Position de la t‚l‚portation d'un passage secret }
  SecretX: array[0..7] of Word;
  SecretY: array[0..7] of Word;

  { PremiŠre position de mister patate }
  FirstPosX, FirstPosY: Word;

  { Niveau actuel }
  Niveau: Byte;

  { Decalage binaire … eff‚ctuer pour le calcul       }
  { de l'offset d'une case dans les buffers du niveau }
  ShiftLargeur: Byte;

  { Code Actuel }
  Code: Word;

  { Option }
  SonOn       : Boolean;
  MusicOn     : Boolean;
  VolumeSon   : Byte;
  VolumeMusic : Byte;
  StatutPerm  : Boolean;
  Center      : Boolean;
  KeyMrp: record
    Droite, Gauche, Haut, Bas, Saute, Action, Lance, Statut, Menu: Word;
  end;
  Screen: record
    Zone: array[1..2] of record
      H, V: Word;
    end;
    SpeedH, SpeedV: Word;
  end;
  { Pour le scrolling }
  LimZone: array[1..2] of record
    X1, X2: Word;
    Y1, Y2: Word;
  end;

  { Pour sauvergarder les configurations en quitant }
  ModifConfig: Boolean;

{ Charge le niveau actuel en m‚moire avec ses d‚cors }
function Load: Boolean;

{ Charge une musique }
function LoadMusic (MusicFile: Word): Boolean;

{ Charge le fond du menu }
procedure LoadFont;

{ Charge les configuration }
procedure LoadConfig;

{ Sauve les configuration }
procedure SaveConfig;

{ Charge les sprites }
procedure LoadSprite;

{ Sauve les objets }
procedure PushObjet;

{ Restore les objets }
procedure PopObjet;

{ Calcul la zone de mrp }
procedure CalculScroll;

procedure SetVolumeSon;
procedure SetVolumeMusique;

implementation

uses MrpVga, MrpStr, MrpPal, MrpInit, MrpText, MrpSon;

function Lit(var F: file; var Buffer; Qte: Word): Boolean;
var
  NB: Word;
begin
  BlockRead(F, Buffer, Qte, NB);
  Lit := NB = Qte;
end;

function Load;
var
  F: file;
  i: Byte;
label LoadError;
begin
  { Ouvre le fichier du niveau }
  if not Ouvre ('STAGE\MRPSTG' + Str (Niveau, 2) + '.SQZ', F, 1) then
  begin
    ShowError('! ERREUR !/LE FICHIER CONTENANT/LE NIVEAU '+Str(Niveau,0)+'/EST INTROUVABLE/');
    Load := False;
    exit;
  end;
  { Lit les informations }
  if not Lit(F, ShiftLargeur, 1) then goto LoadError;
  if not Lit(F, i, 1) then goto LoadError;
  if not Lit(F, Plan[0]^, 32768) then goto LoadError;
  if not Lit(F, Plan[1]^, 32768) then goto LoadError;
  if not Lit(F, Plan[2]^, 32768) then goto LoadError;
  if not Lit(F, Plan[3]^, 32768) then goto LoadError;
  if not Lit(F, Decor^, 32768) then goto LoadError;
  if not Lit(F, Decor^[32768], 32768) then goto LoadError;
  if not Lit(F, Palette[112], 112 * 3) then goto LoadError;
  if not Lit(F, ObjetX, 512*11) then goto LoadError;
  if not Lit(F, SecretX, 32) then goto LoadError;
  if not Lit(F, Code, 2) then goto LoadError;
  close (F);
  LoadMusic (i);
  Load := True;
  exit;
LoadError:
  ShowError('! ERREUR !/LE FICHIER CONTENANT/LE NIVEAU '+Str(Niveau,0)+'/EST INVALIDE/');
  Load := False;
end;

function LoadMusic;
var
  F: file;
  i: Byte;
label MusicError;
begin
  { Ouvre le fichier des musiques }
  if not Ouvre ('MUSIQUE\MRPMSQ' + Str(MusicFile, 2) + '.SQZ', F, 1) then
  begin
    ShowError('! ERREUR !/LE FICHIER CONTENANT/LA MUSIQUE '+Str(MusicFile,0)+'/EST INTROUVABLE/');
    LoadMusic := False;
    exit;
  end;
  { Lit les musiques }
  if not Lit(F, Music.pas, 1) then goto MusicError;
  if not Lit(F, InsMusic, SizeOf (InsMusic)) then goto MusicError;
  if not Lit(F, MusicNote, SizeOf (MusicNote)) then goto MusicError;
  close (F);
  SetVolumeMusique;
  LoadMusic := True;
  exit;
MusicError:
  ShowError('! ERREUR !/LE FICHIER CONTENANT/LA MUSIQUE '+Str(MusicFile,0)+'/EST INVALIDE/');
  LoadMusic := False;
end;

procedure LoadFont;
var
  F: file;
  x, y: Word;
label FontError;
begin
  { Ouvre le fichier de l'image }
  if not Ouvre ('MRPIMG.SQZ', F, 1) then
  begin
    Cls(2, 246);
    OutText(2, Centre, 30, 'MISTER PATATE', 242, 243, true);
    OutText8(2, Centre, 180, 'Fichier "MRPIMG.SQZ" introuvable', 242, tsp, true);
    exit;
  end;
  { Lit la palette }
  if not Lit(F, Palette[112], 128*3) then goto FontError;
  { Et le copie dans la page nø2 }
  if not Lit(F, Plan[0]^, 64000) then goto FontError;
  close (F);
  Cls(2, 0);
  ConvertX (Addr(Plan[0]^), 2);
  exit;
FontError:
  Cls(2, 246);
  OutText(2, Centre, 30, 'MISTER PATATE', 242, 243, true);
  OutText8(2, Centre, 180, 'Fichier "MRPIMG.SQZ" invalide', 242, tsp, true);
end;

procedure LoadDefault;
begin
  ModifConfig := TRUE;
  SonOn := True;
  MusicOn := True;
  StatutPerm := False;
  with KeyMrp do begin
    DROITE := 205;
    GAUCHE := 203;
    HAUT   := 200;
    BAS    := 208;
    SAUTE  := 56;
    ACTION := 57;
    LANCE  := 29;
    STATUT := 28;
    MENU   := 1;
  end;
  Center := True;
  Screen.SpeedH := 8;
  Screen.SpeedV := 8;
  VolumeSon := 10;
  VolumeMusic := 7;
end;

procedure LoadConfig;
var
  F: Text;
  TmpS10: String[10];
  TmpS9: String[9];
  TmpS3: String[3];
  i: Byte;
label ErrorConfig;
begin
  assign (F, 'MRP.INI');
  { Ouvre le fichier de configuration }
  {$I-}
  reset (F);
  {$I+}
  if IOResult <> 0 then begin
    PrintR ('Fichier "MRP.CFG" non trouv‚, chargement des configurations par d‚fault.', 14);
    Inc (InitError);
    LoadDefault;
  end;
  { Lit les configuration }
  {$I-}
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  with KeyMrp do begin
    ReadLn (F, TmpS9, Droite);if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Gauche);if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Haut);  if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Bas);   if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Saute); if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Action);if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Lance); if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Statut);if IOResult <> 0 then goto ErrorConfig;
    ReadLn (F, TmpS9, Menu);  if IOResult <> 0 then goto ErrorConfig;
  end;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F, TmpS10, TmpS3); SonOn := StrLower (TmpS3) = 'oui';  if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F, TmpS10, VolumeSon); if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F, TmpS10, TmpS3); MusicOn := StrLower (TmpS3) = 'oui';if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F, TmpS10, VolumeMusic); if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F);if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F, TmpS9, TmpS3); StatutPerm := StrLower (TmpS3) = 'oui';if IOResult <> 0 then goto ErrorConfig;
  ReadLn (F, TmpS9, TmpS3); Center     := StrLower (TmpS3) = 'oui';if IOResult <> 0 then goto ErrorConfig;
  with Screen do
  begin
    ReadLn(F, TmpS9, Zone[1].H);if IOResult <> 0 then goto ErrorConfig;
    ReadLn(F, TmpS9, Zone[1].V);if IOResult <> 0 then goto ErrorConfig;
    ReadLn(F, TmpS9, Zone[2].H);if IOResult <> 0 then goto ErrorConfig;
    ReadLn(F, TmpS9, Zone[2].V);if IOResult <> 0 then goto ErrorConfig;
    ReadLn(F, TmpS9, SpeedH);if IOResult <> 0 then goto ErrorConfig;
    ReadLn(F, TmpS9, SpeedV);if IOResult <> 0 then goto ErrorConfig;
  end;
  {$I+}
  Close (F);
  CalculScroll;
  exit;
ErrorConfig:
  Close(F);
  PrintR ('Fichier "MRP.CFG" invalide, chargement des configurations par d‚fault.', 14);
  Inc (InitError);
  LoadDefault;
  CalculScroll;
end;

procedure SaveConfig;
var
  F: Text;
begin
  assign (F, 'MRP.INI');
  { Ouvre le fichier de configuration en ‚criture }
  rewrite (F);
  { Ecrit les configuration }
  WriteLn (F, '----------------------------------------');
  WriteLn (F, '---- Configuration de Mister Patate ----');
  WriteLn (F, '----------------------------------------');
  WriteLn (F);
  WriteLn (F, '[ Option / Clavier ]');
  with KeyMrp do begin
    WriteLn (F, 'Droite = ', Droite);
    WriteLn (F, 'Gauche = ', Gauche);
    WriteLn (F, 'Haut   = ', Haut);
    WriteLn (F, 'Bas    = ', Bas);
    WriteLn (F, 'Saute  = ', Saute);
    WriteLn (F, 'Action = ', Action);
    WriteLn (F, 'Lance  = ', Lance);
    WriteLn (F, 'Statut = ', Statut);
    WriteLn (F, 'Menu   = ', Menu);
  end;
  WriteLn (F);
  WriteLn (F, '[ Option / Son ]');
  WriteLn (F, 'Son     = ', StrOk (SonOn));
  WriteLn (F, 'VolumeS = ', VolumeSon);
  WriteLn (F, 'Musique = ', StrOk (MusicOn));
  WriteLn (F, 'VolumeM = ', VolumeMusic);
  WriteLn (F);
  WriteLn (F, '[ Option / Ecran ]');
  WriteLn (F, 'Statut = ', StrOk (StatutPerm));
  WriteLn (F, 'Centr‚ = ', StrOk (Center));
  with Screen do
  begin
    WriteLn(F, 'Zone1H = ', Zone[1].H);
    WriteLn(F, 'Zone1V = ', Zone[1].V);
    WriteLn(F, 'Zone2H = ', Zone[2].H);
    WriteLn(F, 'Zone2V = ', Zone[2].V);
    WriteLn(F, 'SpeedH = ', SpeedH);
    WriteLn(F, 'SpeedH = ', SpeedV);
  end;
  Close (F);
end;

procedure LoadSprite;
var
  F: File;
  i: Word;
  D: Word;
label SpriteError;
begin
  if not Ouvre ('MRPSPR.SQZ', F, 1) then Erreur('l''ouverture du ficher des sprites','Fichier "MRPSPR.SQZ" introuvable.');
  if not Lit(F, DimSprite, SizeOf (DimSprite)) then goto SpriteError;
  if not Lit(F, Palette[1], 333) then goto SpriteError;
  for i := 0 to 511 do begin
    D := DimSprite[i].Largeur * DimSprite[i].Hauteur;
    if D <> 0 then begin
      TestAlloue (D);
      GetMem (PtrSprite[i], D);
      if not Lit(F, PtrSprite[i]^, D) then goto SpriteError;
    end;
  end;
  Close (F);
  exit;
SpriteError:
  Erreur('la lecture du fichier de sprite','Fichier "MRPSPR.SQZ" invalide.');
end;

procedure PushObjet; assembler;
asm
	mov	ax,ds
        mov	es,ax
        mov	si,offset [ObjetX]
        mov	di,offset [SaveObjet]
        mov	cx,128*11
db $66; rep	movsw
end;

procedure PopObjet; assembler;
asm
	mov	ax,ds
        mov	es,ax
        mov	si,offset [SaveObjet]
        mov	di,offset [ObjetX]
        mov	cx,128*11
db $66; rep	movsw
end;

procedure CalculScroll;
var
  i: Byte;
begin
  for i := 1 to 2 do
  begin
    LimZone[i].X1 := 160 - Screen.Zone[i].H;
    LimZone[i].X2 := 160 + Screen.Zone[i].H;
    LimZone[i].Y1 := HautScr shr 1 - Screen.Zone[i].V;
    LimZone[i].Y2 := HautScr shr 1 + Screen.Zone[i].V;
  end;
end;

procedure SetVolumeMusique;
var
  i: Byte;
begin
  for i := 0 to 3 do begin
    InsMusic[i,3] := (InsMusic[i,3] and $C0) or (63-VolumeMusic);
    SetChannelIns(i, InsMusic[i]);
  end;
end;

procedure SetVolumeSon;
var
  i: Byte;
begin
  for i := 4 to 8 do begin
    InsChannel[i,3] := (InsChannel[i,3] and $C0) or (63-VolumeSon);
    SetChannelIns(i, InsChannel[i]);
  end;
end;

end.