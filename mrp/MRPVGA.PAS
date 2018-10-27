
{ Utilisation du mode graphique pour Mister Patate }
unit MrpVga;

interface

var
  { Page affich‚ et prochaine page }
  Page_display: Word;
  Page_not_display: Word;

  { couleur des Bordures }
  Tour: Byte;

const
  Centre        = $1000;
  Inverse       = 1;
  Tsp           = 239;

  HautScr = 200;
  Out240: array[0..7] of Word = ($2C11, $0D06, $3E07, $EA10, $AC11, $DF12, $E715, $0616);

{ Passe en mode VGA }
procedure InitVga;

{ Copie une page }
procedure PCopy (Src, Dst: Word);

{ Copie des lignes }
procedure LCopy (PageSrc, Ysrc, PageDst, Ydst, Nombre: Word);

{ Copie un rectangle de 8x5 }
procedure CopyBox8x5(x,y,nx,ny:Word);

{ Dessine un rectangle de 8x5 }
procedure FillBox8x5(x,y,nx,ny:Word;color:Byte);

{ Attend que l'‚cran ait finit de travailler }
procedure Wait;

{ Efface l'‚cran }
procedure Cls (Page: Word; Col: Byte);

{ Dessine un carr‚ plein }
procedure FillBox (Page: Word; X1, Y1, X2, Y2: Word; Color: Byte);

{ Dessine un carr‚ }
procedure Box (Page: Word; X1, Y1, X2, Y2: Word; Color: Byte);

{ Dessine une ligne horizontale }
procedure LineH (Page: Word; Y, X1, X2: Word; Color: Byte);

{ Dessine une ligne verticale }
procedure LineV (Page: Word; X, Y1, Y2: Word; Color: Byte);

{ Dessine un point }
procedure PutPixel (Page: Word; X, Y: Word; Color: Byte);

{ Renvoie la couleur d'un point }
function GetPixel (Page: Word; X, Y: Word): Byte;

{ Ecrit en 12x12 }
procedure OutText (Page: Word; X, Y: Integer; Txt: String; Color1, Color2: Byte; Bordure: Boolean);

{ Ecrit en 12x12 en relief }
procedure OutTextR (Page: Word; X, Y: Integer; Txt: String; Color1, Color2: Byte; Bordure: Boolean);

{ Ecrit en gros }
procedure BigText (Page, X, Y: Word; Txt: String; Color1, Color2, COlor3: Byte);

{ Ecrit en 8x8 }
procedure OutText8 (Page: Word; X, Y: Integer; Txt: String; Color1, Color2: Byte; Bordure: Boolean);

{ Convertit une page normal vers le mode X }
procedure ConvertX (p: Pointer; page: Word);

{ Affiche la page Page_not_display }
procedure ShowPage;

{ Affiche un objet }
procedure PutObjet (Page, X, Y, Option, Handle: Integer);

{ Affiche un sprite }
procedure PutSprite (Page, X, Y, Option: Integer;var Sprite);

{ Affiche un decor }
procedure PutDecor (Page, X, Y, Num: Word);

{ Affiche un sprite }
procedure Put (Page, X, Y, Largeur, Hauteur, Option: Integer;var Src);

{ Affiche un gros sprite }
procedure BigPut (Page, X, Y: Word; Sprite: array of Byte);

{ Fenˆtre pour PutXXX }
procedure SetSpriteWindow (X1, Y1, X2, Y2: Word);
procedure ResetSpriteWindow;

procedure ShowError(Message: String);

{ Pour la police }
Const
  Police12x12: array[0..2015] of Byte = (
$40,$6A,$00,$90,$AA,$01,$A4,$80,$06,$24,$00,$06,$29,$00,$1A,$29,$00,$1A,
$AA,$AA,$2A,$AA,$AA,$2A,$2A,$00,$2A,$29,$00,$2A,$29,$00,$1A,$29,$00,$1A,
$A9,$1A,$00,$A9,$6A,$01,$0A,$80,$06,$06,$00,$1A,$06,$00,$1A,$AA,$AA,$2A,
$AA,$AA,$2A,$0A,$00,$2A,$0A,$00,$1A,$0A,$80,$1A,$A9,$AA,$06,$A9,$AA,$01,
$40,$6A,$00,$90,$AA,$05,$A4,$80,$1A,$29,$00,$1A,$09,$00,$09,$0A,$00,$00,
$0A,$00,$00,$0A,$00,$00,$29,$00,$18,$A9,$00,$1A,$94,$AA,$06,$40,$AA,$01,
$A9,$6A,$00,$A9,$AA,$05,$0A,$00,$1A,$0A,$00,$18,$0A,$00,$28,$0A,$00,$28,
$0A,$00,$28,$0A,$00,$28,$0A,$00,$18,$0A,$00,$1A,$A9,$AA,$06,$A9,$AA,$01,
$A9,$AA,$1A,$A9,$AA,$1A,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$AA,$AA,$01,
$AA,$AA,$01,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$A9,$AA,$1A,$A9,$AA,$1A,
$A9,$AA,$1A,$A9,$AA,$1A,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$AA,$6A,$00,
$AA,$6A,$00,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$09,$00,$00,$09,$00,$00,
$40,$6A,$00,$90,$AA,$05,$A4,$00,$1A,$29,$00,$18,$09,$00,$00,$0A,$00,$00,
$0A,$90,$0A,$09,$A0,$2A,$29,$00,$1A,$A4,$80,$1A,$90,$AA,$05,$40,$6A,$00,
$09,$00,$18,$09,$00,$18,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,$6A,$A9,$2A,
$AA,$AA,$2A,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,$09,$00,$18,$09,$00,$18,
$A9,$AA,$1A,$A9,$AA,$1A,$00,$19,$00,$00,$19,$00,$00,$2A,$00,$00,$2A,$00,
$00,$2A,$00,$00,$2A,$00,$00,$19,$00,$00,$19,$00,$A9,$AA,$1A,$A9,$AA,$1A,
$A9,$AA,$1A,$A9,$AA,$1A,$00,$A0,$00,$00,$A0,$00,$00,$A0,$00,$00,$A0,$00,
$00,$A0,$00,$06,$60,$00,$0A,$68,$00,$29,$28,$00,$A4,$1A,$00,$90,$06,$00,
$09,$00,$18,$09,$80,$1A,$0A,$A8,$01,$8A,$1A,$00,$AA,$01,$00,$AA,$00,$00,
$AA,$02,$00,$4A,$2A,$00,$0A,$A4,$02,$0A,$40,$2A,$09,$00,$18,$09,$00,$18,
$09,$00,$00,$09,$00,$00,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,
$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$A9,$AA,$1A,$A9,$AA,$1A,
$29,$00,$1A,$A9,$80,$1A,$AA,$80,$2A,$4A,$6A,$28,$0A,$19,$28,$0A,$00,$28,
$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,$09,$00,$18,$09,$00,$18,
$09,$00,$18,$29,$00,$18,$AA,$00,$28,$9A,$02,$28,$4A,$0A,$28,$0A,$29,$28,
$0A,$A4,$28,$0A,$90,$2A,$0A,$40,$2A,$0A,$00,$29,$09,$00,$18,$09,$00,$18,
$00,$69,$00,$90,$AA,$01,$A4,$00,$06,$29,$00,$06,$09,$00,$18,$0A,$00,$28,
$0A,$00,$28,$0A,$00,$28,$29,$00,$18,$A9,$40,$1A,$A4,$AA,$06,$40,$AA,$01,
$A9,$AA,$01,$A9,$AA,$06,$0A,$00,$1A,$0A,$00,$28,$0A,$00,$1A,$6A,$A9,$06,
$AA,$AA,$01,$0A,$00,$00,$0A,$00,$00,$0A,$00,$00,$09,$00,$00,$09,$00,$00,
$40,$6A,$00,$90,$AA,$01,$A4,$80,$06,$29,$00,$1A,$09,$00,$18,$0A,$00,$28,
$0A,$24,$28,$0A,$A8,$18,$09,$A0,$19,$29,$90,$0A,$A4,$6A,$2A,$40,$AA,$18,
$A9,$AA,$01,$A9,$AA,$06,$0A,$00,$1A,$0A,$00,$28,$0A,$00,$1A,$AA,$AA,$06,
$6A,$A9,$01,$0A,$90,$02,$0A,$80,$0A,$0A,$00,$2A,$09,$00,$1A,$09,$00,$1A,
$90,$6A,$00,$A4,$AA,$06,$24,$00,$1A,$09,$00,$00,$0A,$00,$00,$A9,$AA,$01,
$A4,$AA,$06,$00,$00,$1A,$00,$00,$28,$29,$00,$2A,$A9,$AA,$1A,$90,$AA,$06,
$A9,$AA,$16,$A9,$AA,$16,$00,$2A,$00,$00,$29,$00,$00,$29,$00,$00,$2A,$00,
$00,$1A,$00,$00,$2A,$00,$00,$2A,$00,$00,$2A,$00,$00,$19,$00,$00,$19,$00,
$09,$00,$18,$09,$00,$18,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,
$0A,$00,$28,$0A,$00,$28,$09,$00,$18,$29,$00,$1A,$A4,$AA,$06,$90,$AA,$01,
$09,$00,$18,$09,$00,$18,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,$0A,$00,$28,
$09,$00,$28,$29,$00,$28,$A4,$00,$28,$90,$02,$18,$40,$AA,$1A,$00,$A9,$06,
$09,$00,$18,$09,$00,$18,$0A,$00,$28,$0A,$24,$28,$0A,$24,$28,$0A,$28,$28,
$0A,$28,$28,$0A,$28,$28,$29,$29,$28,$A9,$6A,$1A,$A4,$A2,$1A,$90,$80,$06,
$09,$00,$18,$09,$00,$18,$0A,$00,$28,$2A,$00,$2A,$A4,$80,$06,$80,$AA,$00,
$A0,$AA,$02,$68,$40,$0A,$1A,$00,$29,$0A,$00,$28,$09,$00,$18,$09,$00,$18,
$09,$00,$18,$09,$00,$18,$0A,$00,$28,$0A,$00,$28,$29,$00,$1A,$28,$00,$0A,
$A4,$80,$06,$90,$AA,$01,$40,$6A,$00,$00,$2A,$00,$00,$19,$00,$00,$19,$00,
$A9,$AA,$1A,$69,$A9,$1A,$00,$80,$06,$00,$A0,$01,$00,$68,$00,$00,$1A,$00,
$80,$06,$00,$A0,$01,$00,$68,$00,$00,$2A,$00,$00,$A9,$5A,$1A,$A9,$5A,$1A,
$00,$69,$00,$90,$AA,$01,$A4,$00,$06,$29,$00,$06,$09,$00,$18,$0A,$00,$28,
$0A,$00,$28,$0A,$00,$28,$29,$00,$18,$A9,$40,$1A,$A4,$AA,$06,$40,$AA,$01,
$00,$24,$00,$00,$2A,$00,$80,$2A,$00,$90,$2A,$00,$24,$28,$00,$00,$18,$00,
$00,$18,$00,$00,$28,$00,$00,$28,$00,$00,$28,$00,$A9,$AA,$1A,$A9,$AA,$1A,
$40,$1A,$00,$A0,$AA,$01,$24,$80,$0A,$09,$00,$1A,$0A,$00,$18,$00,$00,$28,
$00,$00,$2A,$00,$A9,$06,$90,$2A,$00,$A8,$00,$00,$A9,$AA,$1A,$A9,$AA,$1A,
$90,$AA,$00,$A8,$AA,$0A,$29,$80,$1A,$09,$00,$18,$00,$00,$2A,$00,$A9,$0A,
$00,$A9,$0A,$00,$00,$2A,$09,$00,$28,$29,$80,$1A,$A8,$AA,$0A,$90,$6A,$00,
$00,$60,$00,$00,$68,$00,$00,$A9,$00,$80,$A2,$00,$90,$A0,$00,$24,$A0,$00,
$0A,$A0,$00,$A9,$A5,$1A,$A9,$AA,$1A,$00,$A0,$00,$00,$60,$00,$00,$60,$00,
$A9,$AA,$1A,$A9,$AA,$1A,$0A,$00,$00,$0A,$00,$00,$0A,$6A,$00,$A9,$AA,$01,
$A9,$80,$0A,$00,$00,$1A,$00,$00,$28,$09,$00,$28,$A9,$AA,$1A,$90,$AA,$01,
$00,$A4,$02,$00,$AA,$06,$90,$0A,$06,$A8,$00,$00,$29,$00,$00,$A9,$6A,$00,
$AA,$AA,$0A,$0A,$00,$1A,$09,$00,$28,$29,$00,$18,$A8,$AA,$0A,$40,$AA,$01,
$A9,$AA,$1A,$A9,$AA,$1A,$00,$00,$2A,$00,$80,$0A,$00,$90,$01,$00,$A8,$00,
$00,$29,$00,$00,$09,$00,$00,$0A,$00,$00,$0A,$00,$00,$06,$00,$00,$06,$00,
$90,$AA,$0A,$A8,$AA,$1A,$29,$00,$28,$0A,$00,$18,$18,$00,$0A,$A0,$AA,$02,
$A8,$AA,$0A,$09,$00,$19,$0A,$00,$28,$29,$00,$1A,$A8,$AA,$0A,$40,$AA,$01,
$90,$6A,$00,$A8,$AA,$0A,$29,$00,$1A,$0A,$00,$28,$0A,$00,$18,$28,$00,$19,
$A0,$AA,$0A,$40,$AA,$02,$00,$A8,$00,$00,$1A,$00,$80,$0A,$00,$90,$02,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$64,$00,$00,$00,$00,
$00,$00,$00,$00,$64,$00,$00,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$64,$00,$00,$A8,$00,$00,$A8,$00,$00,$A8,$00,$00,$A8,$00,$00,$64,$00,
$00,$64,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$68,$00,$00,$64,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$A8,$00,$00,$02,$02,$00,$00,$02,$00,$A8,$00,$00,$02,$00,$00,$AA,$02,$00,
$00,$A9,$01,$80,$AA,$0A,$90,$02,$28,$90,$00,$18,$A0,$00,$0A,$00,$80,$06,
$00,$A0,$01,$00,$A8,$00,$00,$18,$00,$00,$00,$00,$00,$18,$00,$00,$18,$00,
$40,$0A,$00,$00,$2A,$00,$00,$68,$00,$00,$60,$00,$00,$A0,$00,$00,$A0,$00,
$00,$A0,$00,$00,$A0,$00,$00,$60,$00,$00,$68,$00,$00,$2A,$00,$40,$0A,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$A4,$AA,$06,$A4,$AA,$06,$00,$00,$00,
$00,$00,$00,$A4,$AA,$06,$A4,$AA,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$40,$00,$00,$A0,$01,$00,$28,$0A,$00,$09,$18,$00,$01,$10,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$90,$A6,$00,$A8,$A6,$0A,$06,$28,$28,$02,$28,$00,$0A,$18,$00,$AA,$AA,$02,
$90,$A6,$0A,$00,$24,$1A,$00,$28,$18,$09,$28,$2A,$A9,$9A,$0A,$A8,$9A,$00,
$00,$00,$00,$00,$00,$00,$80,$02,$00,$00,$28,$00,$00,$00,$00,$00,$00,$00,
$20,$80,$00,$20,$80,$00,$20,$80,$00,$20,$80,$00,$20,$A0,$00,$80,$AA,$02,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$80,$00,$20,$80,$00,
$20,$80,$00,$A0,$80,$00,$A0,$2A,$00,$20,$00,$00,$20,$00,$00,$08,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$06,$00,$00,$02,$00,$40,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,
$00,$0A,$00,$00,$00,$00,$00,$06,$00,$00,$06,$00,$00,$02,$00,$40,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$A4,$AA,$06,$A4,$AA,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$24,$00,$00,$24,$00,$00,$28,$00,
$A0,$AA,$05,$50,$AA,$0A,$00,$28,$00,$00,$18,$00,$00,$18,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$A0,$00,$00,$60,$00,$00,
$0A,$00,$00,$A0,$02,$00,$00,$A8,$02,$00,$00,$2A,$80,$AA,$00,$2A,$00,$00,
$00,$00,$2A,$80,$AA,$00,$2A,$00,$00,$A0,$0A,$00,$00,$A0,$02,$00,$00,$28,
$00,$00,$10,$00,$00,$18,$00,$00,$0A,$00,$80,$02,$00,$A0,$00,$00,$18,$00,
$00,$18,$00,$00,$0A,$00,$80,$02,$00,$A0,$00,$00,$28,$00,$00,$05,$00,$00,
$00,$00,$00,$40,$00,$00,$88,$08,$00,$A0,$02,$00,$69,$1A,$00,$A0,$02,$00,
$88,$08,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$10,$00,$00,$60,$00,$00,$A0,$01,$A5,$A6,$06,$AA,$AA,$1A,
$AA,$AA,$1A,$A5,$A6,$06,$00,$A0,$01,$00,$60,$00,$00,$10,$00,$00,$00,$00,
$00,$00,$00,$00,$01,$00,$40,$02,$00,$90,$02,$00,$A4,$A6,$16,$A9,$AA,$2A,
$A9,$AA,$2A,$A4,$A6,$16,$90,$02,$00,$40,$02,$00,$00,$01,$00,$00,$00,$00);

  Police8x8: Array[0..255,0..7] of Byte = (
{00}($00,$00,$00,$00,$00,$00,$00,$00),{01}($7E,$81,$A5,$81,$BD,$99,$81,$7E),
{02}($7E,$FF,$DB,$FF,$C3,$E7,$FF,$7E),{03}($36,$7F,$7F,$7F,$3E,$1C,$08,$00),
{04}($08,$1C,$3E,$7F,$3E,$1C,$08,$00),{05}($1C,$3E,$1C,$7F,$7F,$3E,$1C,$3E),
{06}($08,$08,$1C,$3E,$7F,$3E,$1C,$3E),{07}($00,$00,$18,$3C,$3C,$18,$00,$00),
{08}($FF,$FF,$E7,$C3,$C3,$E7,$FF,$FF),{09}($00,$3C,$66,$42,$42,$66,$3C,$00),
{0A}($FF,$C3,$99,$BD,$BD,$99,$C3,$FF),{0B}($F0,$E0,$F0,$BE,$33,$33,$33,$1E),
{0C}($3C,$66,$66,$66,$3C,$18,$7E,$18),{0D}($FC,$CC,$FC,$0C,$0C,$0E,$0F,$07),
{0E}($FE,$C6,$FE,$C6,$C6,$E6,$67,$03),{0F}($99,$5A,$3C,$E7,$E7,$3C,$5A,$99),
{10}($01,$07,$1F,$7F,$1F,$07,$01,$00),{11}($40,$70,$7C,$7F,$7C,$70,$40,$00),
{12}($18,$3C,$7E,$18,$18,$7E,$3C,$18),{13}($66,$66,$66,$66,$66,$00,$66,$00),
{14}($FE,$DB,$DB,$DE,$D8,$D8,$D8,$00),{15}($7C,$C6,$1C,$36,$36,$1C,$33,$1E),
{16}($00,$00,$00,$00,$7E,$7E,$7E,$00),{17}($18,$3C,$7E,$18,$7E,$3C,$18,$FF),
{18}($18,$3C,$7E,$18,$18,$18,$18,$00),{19}($18,$18,$18,$18,$7E,$3C,$18,$00),
{1A}($00,$18,$30,$7F,$30,$18,$00,$00),{1B}($00,$0C,$06,$7F,$06,$0C,$00,$00),
{1C}($00,$00,$03,$03,$03,$7F,$00,$00),{1D}($00,$24,$66,$FF,$66,$24,$00,$00),
{1E}($00,$18,$3C,$7E,$FF,$FF,$00,$00),{1F}($00,$FF,$FF,$7E,$3C,$18,$00,$00),
{20}($00,$00,$00,$00,$00,$00,$00,$00),{21}($38,$38,$38,$18,$00,$18,$18,$00),
{22}($36,$36,$36,$00,$00,$00,$00,$00),{23}($36,$36,$7F,$36,$7F,$36,$36,$00),
{24}($0C,$3E,$03,$1E,$30,$1F,$0C,$00),{25}($00,$63,$33,$18,$0C,$66,$63,$00),
{26}($1C,$36,$1C,$6E,$3B,$33,$6E,$00),{27}($06,$06,$03,$00,$00,$00,$00,$00),
{28}($18,$0C,$06,$06,$06,$0C,$18,$00),{29}($06,$0C,$18,$18,$18,$0C,$06,$00),
{2A}($00,$66,$3C,$FF,$3C,$66,$00,$00),{2B}($00,$18,$18,$7E,$7E,$18,$18,$00),
{2C}($00,$00,$00,$00,$00,$18,$08,$00),{2D}($00,$00,$00,$7E,$7E,$00,$00,$00),
{2E}($00,$00,$00,$00,$00,$18,$18,$00),{2F}($60,$30,$18,$0C,$06,$03,$01,$00),
{30}($18,$24,$66,$66,$66,$66,$3C,$00),{31}($18,$1C,$18,$18,$18,$18,$18,$00),
{32}($3C,$66,$60,$3C,$06,$66,$7E,$00),{33}($38,$6C,$60,$30,$66,$66,$3C,$00),
{34}($30,$38,$34,$32,$72,$7E,$30,$00),{35}($7E,$66,$06,$3E,$60,$66,$3C,$00),
{36}($70,$18,$0C,$3E,$66,$66,$3C,$00),{37}($7E,$60,$30,$38,$18,$18,$18,$00),
{38}($3C,$66,$66,$3C,$66,$66,$3C,$00),{39}($3C,$66,$66,$7C,$30,$18,$0E,$00),
{3A}($00,$00,$18,$18,$00,$18,$18,$00),{3B}($00,$00,$18,$18,$00,$18,$08,$00),
{3C}($18,$0C,$06,$03,$06,$0C,$18,$00),{3D}($00,$00,$3F,$00,$00,$3F,$00,$00),
{3E}($06,$0C,$18,$30,$18,$0C,$06,$00),{3F}($3C,$66,$60,$38,$18,$00,$18,$00),
{40}($3E,$63,$7B,$7B,$7B,$03,$1E,$00),{41}($18,$3C,$24,$66,$7E,$66,$66,$00),
{42}($1E,$26,$66,$7E,$66,$66,$3E,$00),{43}($38,$64,$06,$06,$66,$66,$3C,$00),
{44}($1E,$36,$66,$46,$46,$46,$3E,$00),{45}($7E,$06,$06,$1E,$06,$06,$7E,$00),
{46}($7E,$06,$06,$1E,$06,$06,$06,$00),{47}($38,$64,$06,$76,$66,$66,$3C,$00),
{48}($66,$66,$66,$7E,$66,$66,$66,$00),{49}($3C,$18,$18,$18,$18,$18,$3C,$00),
{4A}($7E,$30,$30,$30,$36,$36,$1C,$00),{4B}($66,$66,$36,$1E,$7E,$66,$66,$00),
{4C}($06,$06,$06,$06,$06,$06,$7E,$00),{4D}($66,$7E,$7E,$7E,$66,$66,$66,$00),
{4E}($66,$66,$6E,$7E,$76,$66,$66,$00),{4F}($18,$24,$66,$66,$66,$66,$3C,$00),
{50}($3E,$66,$66,$3E,$06,$06,$06,$00),{51}($3C,$66,$66,$66,$76,$76,$7C,$00),
{52}($3E,$66,$66,$3E,$76,$66,$66,$00),{53}($3C,$66,$06,$3C,$60,$66,$3C,$00),
{54}($7E,$18,$18,$18,$18,$18,$18,$00),{55}($66,$66,$66,$66,$66,$66,$3C,$00),
{56}($66,$66,$66,$66,$7E,$3C,$18,$00),{57}($66,$66,$66,$7E,$7E,$7E,$66,$00),
{58}($66,$66,$3C,$3C,$3C,$66,$66,$00),{59}($66,$66,$66,$7E,$3C,$18,$18,$00),
{5A}($7E,$7E,$30,$18,$0C,$7E,$7E,$00),{5B}($1E,$06,$06,$06,$06,$06,$1E,$00),
{5C}($03,$06,$0C,$18,$30,$60,$40,$00),{5D}($1E,$18,$18,$18,$18,$18,$1E,$00),
{5E}($08,$1C,$36,$63,$00,$00,$00,$00),{5F}($00,$00,$00,$00,$00,$7E,$7E,$00),
{60}($0C,$0C,$18,$00,$00,$00,$00,$00),{61}($00,$00,$1E,$30,$3E,$33,$6E,$00),
{62}($07,$06,$06,$3E,$66,$66,$3B,$00),{63}($00,$00,$1E,$33,$03,$33,$1E,$00),
{64}($38,$30,$30,$3E,$33,$33,$6E,$00),{65}($00,$00,$1E,$33,$3F,$03,$1E,$00),
{66}($1C,$36,$06,$0F,$06,$06,$0F,$00),{67}($00,$00,$6E,$33,$33,$3E,$30,$1F),
{68}($07,$06,$36,$6E,$66,$66,$67,$00),{69}($0C,$00,$0E,$0C,$0C,$0C,$1E,$00),
{6A}($30,$00,$30,$30,$30,$33,$33,$1E),{6B}($07,$06,$66,$36,$1E,$36,$67,$00),
{6C}($0E,$0C,$0C,$0C,$0C,$0C,$1E,$00),{6D}($00,$00,$33,$7F,$7F,$6B,$63,$00),
{6E}($00,$00,$1F,$33,$33,$33,$33,$00),{6F}($00,$00,$1E,$33,$33,$33,$1E,$00),
{70}($00,$00,$3B,$66,$66,$3E,$06,$0F),{71}($00,$00,$6E,$33,$33,$3E,$30,$78),
{72}($00,$00,$3B,$6E,$66,$06,$0F,$00),{73}($00,$00,$3E,$03,$1E,$30,$1F,$00),
{74}($08,$0C,$3E,$0C,$0C,$2C,$18,$00),{75}($00,$00,$33,$33,$33,$33,$6E,$00),
{76}($00,$00,$33,$33,$33,$1E,$0C,$00),{77}($00,$00,$63,$6B,$7F,$7F,$36,$00),
{78}($00,$00,$63,$36,$1C,$36,$63,$00),{79}($00,$00,$33,$33,$33,$3E,$30,$1F),
{7A}($00,$00,$3F,$19,$0C,$26,$3F,$00),{7B}($38,$0C,$0C,$07,$0C,$0C,$38,$00),
{7C}($18,$18,$18,$00,$18,$18,$18,$00),{7D}($07,$0C,$0C,$38,$0C,$0C,$07,$00),
{7E}($6E,$3B,$00,$00,$00,$00,$00,$00),{7F}($00,$08,$1C,$36,$63,$63,$7F,$00),
{80}($1E,$33,$03,$33,$1E,$18,$30,$1E),{81}($00,$33,$00,$33,$33,$33,$7E,$00),
{82}($38,$00,$1E,$33,$3F,$03,$1E,$00),{83}($7E,$C3,$3C,$60,$7C,$66,$FC,$00),
{84}($33,$00,$1E,$30,$3E,$33,$7E,$00),{85}($07,$00,$1E,$30,$3E,$33,$7E,$00),
{86}($0C,$0C,$1E,$30,$3E,$33,$7E,$00),{87}($00,$00,$1E,$03,$03,$1E,$30,$1C),
{88}($7E,$C3,$3C,$66,$7E,$06,$3C,$00),{89}($33,$00,$1E,$33,$3F,$03,$1E,$00),
{8A}($07,$00,$1E,$33,$3F,$03,$1E,$00),{8B}($33,$00,$0E,$0C,$0C,$0C,$1E,$00),
{8C}($3E,$63,$1C,$18,$18,$18,$3C,$00),{8D}($07,$00,$0E,$0C,$0C,$0C,$1E,$00),
{8E}($63,$1C,$36,$63,$7F,$63,$63,$00),{8F}($0C,$0C,$00,$1E,$33,$3F,$33,$00),
{90}($03,$0F,$3F,$FF,$FF,$3F,$0F,$03),{91}($66,$66,$66,$66,$66,$66,$66,$66),
{92}($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF),{93}($1E,$33,$00,$1E,$33,$33,$1E,$00),
{94}($00,$33,$00,$1E,$33,$33,$1E,$00),{95}($00,$07,$00,$1E,$33,$33,$1E,$00),
{96}($1E,$33,$00,$33,$33,$33,$7E,$00),{97}($00,$07,$00,$33,$33,$33,$7E,$00),
{98}($00,$33,$00,$33,$33,$3E,$30,$1F),{99}($C3,$18,$3C,$66,$66,$3C,$18,$00),
{9A}($33,$00,$33,$33,$33,$33,$1E,$00),{9B}($18,$18,$7E,$03,$03,$7E,$18,$18),
{9C}($1C,$36,$26,$0F,$06,$67,$3F,$00),{9D}($33,$33,$1E,$3F,$0C,$3F,$0C,$0C),
{9E}($1F,$33,$33,$5F,$63,$F3,$63,$E3),{9F}($70,$D8,$18,$3C,$18,$18,$1B,$0E),
{A0}($38,$00,$1E,$30,$3E,$33,$7E,$00),{A1}($1C,$00,$0E,$0C,$0C,$0C,$1E,$00),
{A2}($00,$38,$00,$1E,$33,$33,$1E,$00),{A3}($00,$38,$00,$33,$33,$33,$7E,$00),
{A4}($00,$1F,$00,$1F,$33,$33,$33,$00),{A5}($3F,$00,$33,$37,$3F,$3B,$33,$00),
{A6}($3C,$36,$36,$7C,$00,$7E,$00,$00),{A7}($1C,$36,$36,$1C,$00,$3E,$00,$00),
{A8}($0C,$00,$0C,$06,$03,$33,$1E,$00),{A9}($00,$00,$00,$3F,$03,$03,$00,$00),
{AA}($00,$00,$00,$3F,$30,$30,$00,$00),{AB}($C3,$63,$33,$7B,$CC,$66,$33,$F0),
{AC}($C3,$63,$33,$DB,$EC,$F6,$F3,$C0),{AD}($18,$18,$00,$18,$18,$18,$18,$00),
{AE}($00,$CC,$66,$33,$66,$CC,$00,$00),{AF}($00,$33,$66,$CC,$66,$33,$00,$00),
{B0}($44,$11,$44,$11,$44,$11,$44,$11),{B1}($AA,$55,$AA,$55,$AA,$55,$AA,$55),
{B2}($DB,$EE,$DB,$77,$DB,$EE,$DB,$77),{B3}($18,$18,$18,$18,$18,$18,$18,$18),
{B4}($18,$18,$18,$18,$1F,$18,$18,$18),{B5}($18,$18,$1F,$18,$1F,$18,$18,$18),
{B6}($6C,$6C,$6C,$6C,$6F,$6C,$6C,$6C),{B7}($00,$00,$00,$00,$7F,$6C,$6C,$6C),
{B8}($00,$00,$1F,$18,$1F,$18,$18,$18),{B9}($6C,$6C,$6F,$60,$6F,$6C,$6C,$6C),
{BA}($6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C),{BB}($00,$00,$7F,$60,$6F,$6C,$6C,$6C),
{BC}($6C,$6C,$6F,$60,$7F,$00,$00,$00),{BD}($6C,$6C,$6C,$6C,$7F,$00,$00,$00),
{BE}($18,$18,$1F,$18,$1F,$00,$00,$00),{BF}($00,$00,$00,$00,$1F,$18,$18,$18),
{C0}($18,$18,$18,$18,$F8,$00,$00,$00),{C1}($18,$18,$18,$18,$FF,$00,$00,$00),
{C2}($00,$00,$00,$00,$FF,$18,$18,$18),{C3}($18,$18,$18,$18,$F8,$18,$18,$18),
{C4}($00,$00,$00,$00,$FF,$00,$00,$00),{C5}($18,$18,$18,$18,$FF,$18,$18,$18),
{C6}($18,$18,$F8,$18,$F8,$18,$18,$18),{C7}($6C,$6C,$6C,$6C,$EC,$6C,$6C,$6C),
{C8}($6C,$6C,$EC,$0C,$FC,$00,$00,$00),{C9}($00,$00,$FC,$0C,$EC,$6C,$6C,$6C),
{CA}($6C,$6C,$EF,$00,$FF,$00,$00,$00),{CB}($00,$00,$FF,$00,$EF,$6C,$6C,$6C),
{CC}($6C,$6C,$EC,$0C,$EC,$6C,$6C,$6C),{CD}($00,$00,$FF,$00,$FF,$00,$00,$00),
{CE}($6C,$6C,$EF,$00,$EF,$6C,$6C,$6C),{CF}($18,$18,$FF,$00,$FF,$00,$00,$00),
{D0}($6C,$6C,$6C,$6C,$FF,$00,$00,$00),{D1}($00,$00,$FF,$00,$FF,$18,$18,$18),
{D2}($00,$00,$00,$00,$FF,$6C,$6C,$6C),{D3}($6C,$6C,$6C,$6C,$FC,$00,$00,$00),
{D4}($18,$18,$F8,$18,$F8,$00,$00,$00),{D5}($00,$00,$F8,$18,$F8,$18,$18,$18),
{D6}($00,$00,$00,$00,$FC,$6C,$6C,$6C),{D7}($6C,$6C,$6C,$6C,$FF,$6C,$6C,$6C),
{D8}($18,$18,$FF,$18,$FF,$18,$18,$18),{D9}($18,$18,$18,$18,$1F,$00,$00,$00),
{DA}($00,$00,$00,$00,$F8,$18,$18,$18),{DB}($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF),
{DC}($00,$00,$00,$00,$FF,$FF,$FF,$FF),{DD}($0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F),
{DE}($F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0),{DF}($FF,$FF,$FF,$FF,$00,$00,$00,$00),
{E0}($00,$00,$6E,$3B,$13,$3B,$6E,$00),{E1}($00,$1E,$33,$1F,$33,$1F,$03,$03),
{E2}($00,$3F,$33,$03,$03,$03,$03,$00),{E3}($00,$7F,$36,$36,$36,$36,$36,$00),
{E4}($3F,$33,$06,$0C,$06,$33,$3F,$00),{E5}($00,$00,$7E,$1B,$1B,$1B,$0E,$00),
{E6}($00,$66,$66,$66,$66,$3E,$06,$03),{E7}($00,$6E,$3B,$18,$18,$18,$18,$00),
{E8}($3F,$0C,$1E,$33,$33,$1E,$0C,$3F),{E9}($1C,$36,$63,$7F,$63,$36,$1C,$00),
{EA}($1C,$36,$63,$63,$36,$36,$77,$00),{EB}($38,$0C,$18,$3E,$33,$33,$1E,$00),
{EC}($00,$00,$7E,$DB,$DB,$7E,$00,$00),{ED}($60,$30,$7E,$DB,$DB,$7E,$06,$03),
{EE}($1C,$06,$03,$1F,$03,$06,$1C,$00),{EF}($55,$80,$01,$80,$01,$80,$01,$AA),
{F0}($0C,$12,$12,$0C,$00,$00,$00,$00),{F1}($00,$40,$60,$62,$36,$3C,$18,$00),
{F2}($3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C),{F3}($00,$00,$3C,$3C,$3C,$3C,$00,$00),
{F4}($18,$3C,$7E,$FF,$3C,$3C,$3C,$3C),{F5}($3C,$3C,$3C,$3C,$FF,$7E,$3C,$18),
{F6}($08,$0C,$FE,$FF,$FF,$FE,$0C,$08),{F7}($10,$30,$7F,$FF,$FF,$7F,$30,$10),
{F8}($00,$00,$00,$18,$18,$00,$00,$00),{F9}($00,$00,$00,$FF,$FF,$00,$00,$00),
{FA}($FF,$81,$81,$81,$81,$81,$81,$FF),{FB}($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF),
{FC}($3C,$66,$C3,$81,$81,$C3,$66,$3C),{FD}($3C,$7E,$FF,$FF,$FF,$FF,$7E,$3C),
{FE}($10,$30,$7F,$FF,$FF,$7F,$30,$10),{FF}($07,$02,$02,$02,$02,$02,$07,$00));

type
  SpriteWindowType = record
    X1, Y1: Word;
    X2, Y2: Word;
  end;

const
  { Fenetre pour PutXXX }
  SpriteWindow: SpriteWindowType = (X1:0; Y1:0; X2:320; Y2:HautScr);

implementation

uses MrpLoad, MrpPal, MrpSon, MrpKey;

procedure InitVga; assembler;
asm
        { * Lance le mode 13h -> 320x200x8 * }
	MOV	AX,$0013
        INT	$10
        { * Passe dans le mode X * }
	CLI
	MOV	DX,$3C4
        MOV	AX,$0604
        OUT	DX,AX
        MOV	DX,$3D4
        MOV	AL,$14
        OUT	DX,AL
        INC	DX
        IN	AL,DX
        AND	AL,$BF
        OUT	DX,AL
        DEC	DX
        MOV	AL,$17
        OUT	DX,AL
        INC	DX
        IN	AL,DX
        OR	AL,$40
        OUT	DX,AL
        MOV	AL,HautScr
        CMP	AL,200
        JE	@1
        MOV	DL,$C2
  	MOV	AL,$E3
        OUT	DX,AL
        MOV	DL,$D4
  	MOV	SI,OFFSET [Out240]
        MOV	CX,8
        REP	OUTSW
@1:	STI
        { * Efface la m‚moire vid‚o * }
	MOV	AX,$0F02
        MOV	DX,$3C4
        OUT	DX,AX
        MOV	AX,$A000
        MOV	ES,AX
        XOR	DI,DI
DB $66; XOR	AX,AX
	MOV	CX,16384
DB $66; REP	STOSW
	MOV	[Page_display],0
        MOV	[Page_not_display],1
	MOV	[Tour],4
	MOV	SI,OFFSET [PalInit]
        MOV	AX,DS
        MOV	ES,AX
        MOV	DI,OFFSET [Palette]+240*3
        MOV	CX,16*3
	REP	MOVSB
end;

procedure PCopy; assembler;
asm
        PUSH	DS
        MOV	AX,$A000
        MOV	DS,AX
        MOV	ES,AX
        IMUL	SI,[Src],80*HautScr
        IMUL	DI,[Dst],80*HautScr
	MOV	DX,$3CE
        MOV	AX,8
        OUT	DX,AX
        MOV	DL,$C4
        MOV	AL,$02
        OUT	DX,AL
        INC	DL
        MOV	AL,$0F
        OUT	DX,AL
        MOV	CX,80*HautScr
	REP	MOVSB
        MOV	DL,$CF
        MOV	AL,$FF
        OUT	DX,AL
	POP	DS
end;

procedure LCopy; assembler;
asm
        PUSH	DS
        IMUL	AX,[PageSrc],HautScr*5
        OR	AX,$A000
        MOV	DS,AX
        IMUL	AX,[PageDst],HautScr*5
        OR	AX,$A000
        MOV	ES,AX
        IMUL	SI,[Ysrc],80
        IMUL	DI,[Ydst],80
	MOV	DX,$3CE
        MOV	AX,8
        OUT	DX,AX
        MOV	DL,$C4
        MOV	AL,$02
        OUT	DX,AL
        INC	DL
        MOV	AL,$0F
        OUT	DX,AL
	IMUL	CX,[Nombre],80
	REP	MOVSB
        MOV	DL,$CF
        MOV	AL,$FF
        OUT	DX,AL
	POP	DS
end;

procedure CopyBox8x5; assembler;
asm
        PUSH	DS
 	IMUL	DI,[Page_display],80*HautScr
 	IMUL	SI,[Page_not_display],80*HautScr
        MOV	AX,$A000
        MOV	ES,AX
        MOV	DS,AX
        MOV	AX,[X]
        SHL	AX,1
        IMUL	BX,[Y],2*HautScr
        ADD	BX,AX
        ADD	DI,BX
        ADD	SI,BX
	MOV	DX,$3CE
        MOV	AX,8
        OUT	DX,AX
        MOV	DL,$C4
        MOV	AL,$02
        OUT	DX,AL
        INC	DL
        MOV	AL,$0F
        OUT	DX,AL
        IMUL	BX,[ny],HautScr/40
	MOV	AX,[nx]
        SHL	AX,1
@LoopCopy:
        MOV	CX,AX
        REP	MOVSB
        ADD	DI,80
        ADD	SI,80
        SUB	DI,AX
        SUB	SI,AX
        DEC	BX
        JNZ	@LoopCopy
        MOV	DL,$CF
        MOV	AL,$FF
        OUT	DX,AL
        POP	DS
end;

procedure FillBox8x5; assembler;
asm
 	IMUL	AX,[Page_display],HautScr*5
        OR	AX,$A000
        MOV	ES,AX
        MOV	AX,[X]
        SHL	AX,1
        IMUL	DI,[Y],2*HautScr
        ADD	DI,AX
	MOV	DX,$3C4
        MOV	AX,$0F02
        OUT	DX,AX
        IMUL	BX,[ny],HautScr/40
        MOV	DX,[nx]
	MOV	AL,[Color]
        MOV	AH,AL
@LoopFill:
	MOV	CX,DX
        REP	STOSW
        ADD	DI,80
	SUB	DI,DX
        SUB	DI,DX
        DEC	BX
        JNZ	@LoopFill
end;

procedure Wait; assembler;
asm
	MOV	DX,3DAh { DX = Port de l'‚cran }
@@1:	IN	AL,DX
	TEST	AL,8
	JNZ	@@1
@@2:	IN	AL,DX
	TEST	AL,8
	JZ	@@2
end;

procedure Cls; assembler;
asm
        MOV	AX,$A000
        MOV	ES,AX
        IMUL	DI,[Page],80*HautScr
	MOV	AX,$0F02
        MOV	DX,$3C4
        OUT	DX,AX
	MOV	AL,Col
        MOV	AH,AL
        MOV	BX,AX
DB $66; SHL	AX,16
        MOV	AX,BX
        MOV	CX,20*HautScr
DB $66; REP	STOSW
end;

procedure FillBox; assembler;
var
  TmpBX: Word;
asm
	MOV	AX,$A000
        MOV	ES,AX
	MOV	SI,[Y2]
        MOV	AX,[Y1]
        SUB	SI,AX
        INC	SI
        MOV	BX,AX
        SHL	BX,6
        SHL	AX,4
        ADD	BX,AX
        IMUL	DI,[Page],80*HautScr
        ADD	DI,BX
        MOV	AX,[X1]
        MOV	BX,[X2]
        SUB	BX,AX
        INC	BX
        MOV	CX,AX
        AND	CX,3
        SHR	AX,2
        ADD	DI,AX
        MOV	DX,$3C4
        JCXZ	@Line1
	PUSH	SI
        PUSH	DI
        MOV	[TmpBX],BX
@Line4: MOV	AX,$0102
        SHL	AH,CL
	MOV	CH,[Color]
        MOV	BX,[TmpBX]
@Line0: OUT	DX,AX
        MOV	ES:[DI],CH
        DEC	BX
        JZ	@Line6
	SHL	AH,1
        TEST	AH,16
        JZ	@Line0
@Line6: ADD	DI,80
        DEC	SI
        JNZ	@Line4
	POP	DI
        POP	SI
	INC	DI
@Line1:	TEST	BX,$FFFC
	JZ	@Line2
        MOV	AX,$0F02
        OUT	DX,AX
        MOV	AL,[Color]
        PUSH	SI
	PUSH	BX
        PUSH	DI
	SHR	BX,2
@Line5: MOV	CX,BX
        REP	STOSB
        ADD	DI,80
        SUB	DI,BX
        DEC	SI
        JNZ	@Line5
        POP	DI
        ADD	DI,BX
        POP	BX
        POP	SI
	AND	BX,3
@Line2: OR	BX,BX
	JZ	@exit
	MOV	CL,[Color]
        MOV	BH,BL
@Line7: MOV	BL,BH
        MOV	AX,$0102
@Line3: OUT	DX,AX
	MOV	ES:[DI],CL
        SHL	AH,1
        DEC	BL
        JNZ	@Line3
        ADD	DI,80
        DEC	SI
        JNZ	@Line7
@exit:
end;

procedure Box;
begin
  LineH (Page, Y1, X1, X2, Color);
  LineH (Page, Y2, X1, X2, Color);
  LineV (Page, X1, Y1, Y2, Color);
  LineV (Page, X2, Y1, Y2, Color);
end;

procedure LineH; assembler;
asm
	MOV	AX,$A000
        MOV	ES,AX
        MOV	AX,[Y]
        MOV	BX,AX
        SHL	BX,6
        SHL	AX,4
        ADD	BX,AX
        IMUL	DI,[Page],80*HautScr
        ADD	DI,BX
        MOV	AX,[X1]
        MOV	BX,[X2]
        SUB	BX,AX
        INC	BX
        MOV	CX,AX
        AND	CX,3
        SHR	AX,2
        ADD	DI,AX
        MOV	DX,$3C4
        JCXZ	@Line1
        MOV	AX,$0102
        SHL	AH,CL
	MOV	CL,[Color]
@Line0: OUT	DX,AX
        MOV	ES:[DI],CL
        DEC	BX
        JZ	@exit
	SHL	AH,1
        TEST	AH,16
        JZ	@Line0
	INC	DI
@Line1:	TEST	BX,$FFFC
	JZ	@Line2
        MOV	AX,$0F02
        OUT	DX,AX
        MOV	CX,BX
        SHR	CX,2
        MOV	AL,[Color]
        REP	STOSB
	AND	BX,3
@Line2: OR	BX,BX
	JZ	@exit
	MOV	CL,[Color]
        MOV	AX,$0102
@Line3: OUT	DX,AX
	MOV	ES:[DI],CL
        SHL	AH,1
        DEC	BX
        JNZ	@Line3
@exit:
end;

procedure LineV; assembler;
asm
        MOV	AX,$A000
        MOV	ES,AX
        MOV	BX,[Y2]
	MOV	AX,[Y1]
        SUB	BX,AX
        INC	BX
        MOV	DX,AX
        SHL	DX,6
        SHL	AX,4
        ADD	DX,AX
        IMUL	DI,[Page],80*HautScr
        ADD	DI,DX
        MOV	AX,[X]
        MOV	CX,AX
        SHR	AX,2
        ADD	DI,AX
        AND	CX,3
        MOV	AX,$0102
        SHL	AH,CL
        MOV	DX,$3C4
        OUT	DX,AX
        MOV	CX,BX
        MOV	AL,[Color]
@LoopPixel:
	STOSB
        ADD	DI,79
        LOOP	@LoopPixel
end;

procedure PutPixel; assembler;
asm
        MOV	AX,$A000
        MOV	ES,AX
	MOV	AX,[Y]
        MOV	BX,AX
        SHL	AX,6
        SHL	BX,4
        ADD	BX,AX
        IMUL	DI,[Page],80*HautScr
        ADD	DI,BX
        MOV	AX,[X]
        MOV	CX,AX
        AND	CX,3
        SHR	AX,2
        ADD	DI,AX
        MOV	AX,$0102
        SHL	AH,CL
	MOV	DX,$3C4
        OUT	DX,AX
	MOV	AL,[Color]
        STOSB
end;

function GetPixel; assembler;
asm
        MOV	AX,$A000
        MOV	ES,AX
	MOV	AX,[Y]
        MOV	BX,AX
        SHL	AX,6
        SHL	BX,4
        ADD	BX,AX
        IMUL	DI,[Page],80*HautScr
        ADD	DI,BX
        MOV	AX,[X]
        MOV	CL,AL
        AND	CL,3
        SHR	AX,2
        ADD	DI,AX
        MOV	AL,$04
        MOV	AH,CL
	MOV	DX,$3CE
        OUT	DX,AX
	MOV	AL,ES:[DI]
end;

procedure OutText; assembler;
var
  LengthStr: Byte;
  FirstOfs: Word;
asm
        MOV	AX,$A000
        MOV	ES,AX
        MOV	DX,$3C4
        MOV	AL,$02
        OUT	DX,AL
        INC	DX
        TEST	[Bordure],$FF
        JZ	@OUTT8
	PUSH	[X]
        PUSH	WORD PTR [Txt]
@OUTT8: MOV	BX,DS
	LDS	SI,[Txt]
        LODSB
        MOV	DS,BX
        MOV	[LengthStr],AL
	MOV	WORD PTR [Txt],SI
	CMP	[X],Centre-320
        JL	@OUTT3
	MOV     BL,AL
        XOR	BH,BH
        MOV	CX,BX
        SHL	BX,3
        SUB	BX,CX
        DEC	BX
        SUB	BX,160
        NEG	BX
        SUB	BX,Centre
        ADD	[X],BX
@OUTT3: CMP	[Y],Centre-HautScr
        JL	@LoopChar
	ADD	[Y],(HautScr-12)/2-Centre
@LoopChar:
        IMUL	DI,[Page],80*HautScr
        MOV	AX,[Y]
        MOV	BX,AX
        SHL	AX,6
        SHL	BX,4
        ADD	BX,AX
        ADD	DI,BX
        MOV	AX,[X]
        MOV	CX,AX
        SHR	AX,2
        ADD	DI,AX
        MOV	[FirstOfs],DI
        AND	CL,3
        MOV	AH,$11
        ROL	AH,CL
        MOV	BX,DS
	LDS	SI,[Txt]
        LODSB
	MOV	WORD PTR [Txt],SI
        MOV	DS,BX
        CMP	AL,' '
        JE	@OUTTA
        CMP	AL,':'
        JNE	@OUTTB
        MOV	SI,36*36
        JMP	@OUTTC
@OUTTB: CMP	AL,'!'
        JNE	@OUTTD
        MOV	SI,37*36
        JMP	@OUTTC
@OUTTD:	CMP	AL,'ý'
        JNE	@OUTTF
        MOV	SI,38*36
        JMP	@OUTTC
@OUTTF:	CMP	AL,'?'
        JNE	@OUTT10
        MOV	SI,39*36
        JMP	@OUTTC
@OUTT10:CMP	AL,')'
        JNE	@OUTT11
        MOV	SI,40*36
        JMP	@OUTTC
@OUTT11:CMP	AL,'='
        JNE	@OUTT12
        MOV	SI,41*36
        JMP	@OUTTC
@OUTT12:CMP	AL,'^'
        JNE	@OUTT13
        MOV	SI,42*36
        JMP	@OUTTC
@OUTT13:CMP	AL,'$'
        JNE	@OUTT14
        MOV	SI,43*36
        JMP	@OUTTC
@OUTT14:CMP	AL,'—'
        JNE	@OUTT15
        MOV	SI,44*36
        JMP	@OUTTC
@OUTT15:CMP	AL,'æ'
        JNE	@OUTT16
        MOV	SI,45*36
        JMP	@OUTTC
@OUTT16:CMP	AL,','
        JNE	@OUTT17
        MOV	SI,46*36
        JMP	@OUTTC
@OUTT17:CMP	AL,';'
        JNE	@OUTT18
        MOV	SI,47*36
        JMP	@OUTTC
@OUTT18:CMP	AL,'-'
        JNE	@OUTT19
        MOV	SI,48*36
        JMP	@OUTTC
@OUTT19:CMP	AL,'+'
        JNE	@OUTT1A
        MOV	SI,49*36
        JMP	@OUTTC
@OUTT1A:CMP	AL,'.'
        JNE	@OUTT1B
        MOV	SI,50*36
        JMP	@OUTTC
@OUTT1B:CMP	AL,'>'
        JNE	@OUTT1C
        MOV	SI,51*36
        JMP	@OUTTC
@OUTT1C:CMP	AL,'\'
        JNE	@OUTT1D
        MOV	SI,52*36
        JMP	@OUTTC
@OUTT1D:CMP	AL,'*'
        JNE	@OUTT1E
        MOV	SI,53*36
        JMP	@OUTTC
@OUTT1E:CMP	AL,''
        JNE	@OUTT20
        MOV	SI,54*36
        JMP	@OUTTC
@OUTT20:CMP	AL,''
        JNE	@OUTT21
        MOV	SI,55*36
        JMP	@OUTTC
@OUTT21:MOV	BL,AL
        XOR	BH,BH
	CMP	AL,'A'
	JB	@OUTTE
        SUB	BL,'A'
        JMP	@OUTT1F
@OUTTE:	SUB	BL,'0'-26
@OUTT1F:MOV	SI,BX
        SHL	BX,5
        SHL	SI,2
        ADD	SI,BX
@OUTTC: ADD	SI,OFFSET [Police12x12]
	MOV	CX,$0C0C
	MOV	AL,AH
@LoopOctet:
        MOV	BL,[SI]
        MOV	BH,4
        INC	SI
@LoopPixel:
	MOV	AH,BL
        AND	AH,3
        JZ	@OUTT0
        TEST	[Bordure],$FF
        JZ	@OUTT4
        MOV	AH,[Tour]
        OUT	DX,AL
        MOV	ES:[DI-80],AH
        MOV	ES:[DI+80],AH
	ROR	AL,1
        SBB	DI,0
	OUT	DX,AL
	MOV	ES:[DI],AH
        ROL	AL,1
        ADC	DI,0
        ROL	AL,1
        ADC	DI,0
	OUT	DX,AL
	MOV	ES:[DI],AH
	JMP	@OUTT9
@OUTT4: CMP	AH,1
        JA	@Col2
        MOV	AH,[Color1]
        JMP	@Pixel
@Col2:  MOV	AH,[Color2]
@Pixel: OUT	DX,AL
	MOV	ES:[DI],AH
@OUTT0:	ROL	AL,1
        ADC	DI,0
@OUTT9: SHR	BL,2
        DEC	CL
        JNZ	@OUTT2
        ROL	AL,4
        MOV	DI,[FirstOfs]
        ADD	DI,80
        MOV	[FirstOfs],DI
        MOV	CL,$0C
	DEC	CH
        JNZ	@OUTT2
@OUTTA: DEC	[LengthStr]
        JZ	@OUTT7
        ADD	[X],14
        JMP	@LoopChar
@OUTT2: DEC	BH
	JNZ	@LoopPixel
	JMP	@LoopOctet
@OUTT7:	TEST    [Bordure],$FF
	JZ	@exit
        MOV	[Bordure],0
        POP	WORD PTR [Txt]
        POP	[X]
	JMP	@OUTT8
@exit:
end;

function PixelChar (charact, x, y: word): Byte; assembler;
asm
	mov	ax,[charact]
	mov	si,ax
        shl	ax,5
        shl	si,2
        add	si,ax
        mov	ax,[y]
        mov	bx,ax
        shl	ax,3
        shl	bx,2
        add	bx,ax
        add	bx,[x]
        mov	cl,bl
        and	cl,3
        shl	cl,1
        shr	bx,2
        mov	al,byte ptr [Police12x12+bx+si]
        shr	al,cl
        and	al,3
end;

procedure OutTextR;
var
  SaveTour: Byte;
begin
  SaveTour := Tour;
  Tour := 2;
  OutText (Page, X-2, Y-2, Txt,      2,      2, Bordure);
  Tour := SaveTour;
  OutText (Page,   X,   Y, Txt, Color1, Color2, Bordure);
end;


procedure BigText;
var
  PosChar: Word;
  CharX: Word;
  xr, yr: Word;
  Ch: Word;
  col: Byte;
begin
  CharX := 134 - Length (Txt) * 14 + X;
  for PosChar := 1 to Length (Txt) do begin
    inc (CharX, 28);
    case Txt[PosChar] of
      ' ': Continue;
      ':': Ch := 36;
      '!': Ch := 37;
      'ý': Ch := 38;
      '?': Ch := 39;
      ')': Ch := 40;
      '=': Ch := 41;
      '^': Ch := 42;
      '$': Ch := 43;
      '—': Ch := 44;
      'æ': Ch := 45;
      ',': Ch := 46;
      ';': Ch := 47;
      '-': Ch := 48;
      '+': Ch := 49;
      '.': Ch := 50;
      '>': Ch := 51;
      '\': Ch := 52;
      '*': Ch := 53;
      '': Ch := 54;
      '': Ch := 55;
      'A'..'Z': Ch := Ord(Txt[PosChar]) - 65;
      '0'..'9': Ch := Ord(Txt[PosChar]) - 22;
    end;
    for yr := 0 to 11 do for xr := 0 to 11 do begin
      case PixelChar (Ch, xr, yr) of
        0: Continue;
        1: col := Color1;
        2: col := Color2;
      end;
      if (yr=0 ) or (PixelChar(Ch,xr  ,yr-1)=0) then LineH(Page,Y-1+yr shl 1,CharX+xr shl 1,CharX+xr shl 1+1,Color3);
      if (yr=11) or (PixelChar(Ch,xr  ,yr+1)=0) then LineH(Page,Y+2+yr shl 1,CharX+xr shl 1,CharX+xr shl 1+1,Color3);
      if (xr=0 ) or (PixelChar(Ch,xr-1,yr  )=0) then LineV(Page,CharX+xr shl 1-1,Y+yr shl 1,Y+1+yr shl 1,Color3);
      if (xr=11) or (PixelChar(Ch,xr+1,yr  )=0) then LineV(Page,CharX+xr shl 1+2,Y+yr shl 1,Y+1+yr shl 1,Color3);
      FillBox (Page, CharX + xr shl 1, Y + yr shl 1,
                     CharX + xr shl 1+1, Y+1 + yr shl 1, col);
    end;
  end;
end;

procedure OutText8; assembler;
var
  LengthStr: Byte;
  FirstOfs: Word;
asm
        MOV	AX,$A000
        MOV	ES,AX
        MOV	DX,$3C4
        MOV	AL,$02
        OUT	DX,AL
        INC	DX
        TEST	[Bordure],$FF
        JZ	@OUTT8
	PUSH	[X]
        PUSH	WORD PTR [Txt]
@OUTT8: MOV	BX,DS
	LDS	SI,[Txt]
        LODSB
        MOV	DS,BX
        MOV	[LengthStr],AL
	MOV	WORD PTR [Txt],SI
	CMP	[X],Centre-320
        JL	@OUTT3
	MOV     BL,AL
        XOR	BH,BH
        SHL	BX,2
        SUB	BX,160
        NEG	BX
        SUB	BX,Centre
        ADD	[X],BX
@OUTT3: CMP	[Y],Centre-HautScr
        JL	@LoopChar
	ADD	[Y],(HautScr-8)/2-Centre
@LoopChar:
        IMUL	DI,[Page],80*HautScr
        MOV	AX,[Y]
        MOV	BX,AX
        SHL	AX,6
        SHL	BX,4
        ADD	BX,AX
        ADD	DI,BX
        MOV	AX,[X]
        MOV	CX,AX
        SHR	AX,2
        ADD	DI,AX
        MOV	[FirstOfs],DI
        AND	CL,3
        MOV	CH,$11
        SHL	CH,CL
        MOV	BX,DS
	LDS	SI,[Txt]
        LODSB
	MOV	WORD PTR [Txt],SI
        MOV	DS,BX
	XOR	AH,AH
        MOV	SI,AX
        SHL	SI,3
        ADD	SI,OFFSET [Police8x8]
	MOV	AL,CH
	MOV	CX,8
@LoopOctet:
        MOV	BL,[SI]
        MOV	BH,1
        INC	SI
@LoopPixel:
        TEST	[Bordure],$FF
        JZ	@OUTT4
        TEST	BL,BH
        JZ	@OUTT0
        OUT	DX,AL
        MOV	ES:BYTE PTR [DI-80],4
        MOV	ES:BYTE PTR [DI+80],4
	ROR	AL,1
        SBB	DI,0
	OUT	DX,AL
	MOV	ES:BYTE PTR [DI],4
        ROL	AL,1
        ADC	DI,0
        ROL	AL,1
        ADC	DI,0
	OUT	DX,AL
	MOV	ES:BYTE PTR [DI],4
	JMP	@OUTT9
@OUTT4: TEST	BL,BH
	JZ	@Col2
        MOV	AH,[Color1]
        JMP	@Pixel
@Col2:  MOV	AH,[Color2]
@Pixel: CMP	AH,Tsp
	JE	@OUTT0
        OUT	DX,AL
	MOV	ES:[DI],AH
@OUTT0:	ROL	AL,1
	ADC	DI,0
@OUTT9: SHL	BH,1
        JNC	@LoopPixel
        MOV	DI,[FirstOfs]
        ADD	DI,80
        MOV	[FirstOfs],DI
        LOOP	@LoopOctet
        DEC	[LengthStr]
        JZ	@OUTT7
        ADD	[X],8
        JMP	@LoopChar
@OUTT7:	TEST    [Bordure],$FF
	JZ	@exit
        MOV	[Bordure],0
        POP	WORD PTR [Txt]
        POP	[X]
	JMP	@OUTT8
@exit:
end;

procedure ConvertX; assembler;
asm
        MOV	AX,$A000
        MOV	ES,AX
        IMUL	DI,[Page],80*HautScr
        ADD	DI,(HautScr-200)*40
        MOV	DX,$3C4
        MOV	AX,$0102
	PUSH	DS
        LDS	SI,[p]
@LoopConvert:
	OUT	DX,AX
        MOV	CX,80*200
@LoopPixel:
	MOVSB
        ADD	SI,3
        LOOP	@LoopPixel
        SUB	SI,63999
        SUB	DI,80*200
        SHL	AH,1
        TEST	AH,16
        JZ	@LoopConvert
        POP	DS
end;

procedure ShowPage; assembler;
asm
        MOV	DX,$3DA
@WaitX0:IN	AL,DX
	TEST	AL,1
        JNZ	@WaitX0
	IMUL	BX,[Page_not_display],80*HautScr
        MOV	AH,BH
        MOV	DL,$D4
        MOV	AL,$0C
        OUT	DX,AX
        INC	AL
        MOV	AH,BL
        OUT	DX,AX
        MOV	DL,$DA
@WaitX1:IN	AL,DX
	TEST	AL,8
        JZ	@WaitX1
	MOV	AX,[Page_display]
        XCHG	[Page_not_display],AX
	MOV	[Page_display],AX
end;

procedure Put; assembler;
var
  Sens: Integer;
asm
        PUSH	DS
        MOV	DX,[Hauteur]
        MOV	BX,[Largeur]
        MOV	[Sens],1
        TEST	[Option],Inverse
        JZ	@Put8
        NEG	[Sens]
@Put8:	MOV	SI,WORD PTR [Src] { DS:SI -> Addresse du Sprite }
	MOV	AX,[Y]
        MOV	CX,AX
        ADD	CX,DX
        DEC	CX
        CMP	CX,[SpriteWindow.Y1] { Si le sprite n'est pas sur l'‚cran }
	JL	@ExitPutSprite       { alors on quitte                    }
	CMP	AX,[SpriteWindow.Y2] { Si le sprite n'est pas sur l'‚cran }
	JGE	@ExitPutSprite       { alors on quitte                    }
@Put1:  CMP	AX,[SpriteWindow.Y1] { Test si le sprite d‚pase sur le haut }
	JGE	@Put2
	INC	AX
        ADD	SI,BX
        DEC	DX
	JMP	@Put1
@Put2:  MOV	DI,AX
        ADD	AX,DX
        DEC	AX
        SUB	AX,[SpriteWindow.Y2]
        JC	@Put3 { Test si le sprite d‚passe sur le bas }
        INC	AX
        SUB	DX,AX
@Put3:  MOV	AX,DI
        SHL	AX,8
        SHL	DI,6
        ADD	DI,AX
        MOV	AX,[X]
	CMP	AX,[SpriteWindow.X2] { Si le sprite n'est pas sur l'‚cran }
	JGE	@ExitPutSprite       { alors on quitte                    }
	CMP	AX,[SpriteWindow.X1]
        JGE	@Put4
        SUB	AX,[SpriteWindow.X1]
        NEG	AX
        SUB	BX,AX
        TEST	[Sens],2
        JNZ	@PutA
        ADD	SI,AX
@PutA:  MOV	AX,[SpriteWindow.X1]
@Put4:  ADD	DI,AX
	ADD	AX,BX
        DEC	AX
	CMP	AX,[SpriteWindow.X1] { Si le sprite n'est pas sur l'‚cran }
	JL	@ExitPutSprite       { alors on quitte                    }
        SUB	AX,[SpriteWindow.X2]
        JC	@Put5
        INC	AX
        SUB	BX,AX
	TEST	[Sens],2
        JZ	@Put5
        ADD	SI,AX
@Put5:  MOV	[Hauteur],DX
        TEST	[Option],Inverse
        JZ	@Put9
	ADD	SI,BX
        DEC	SI
@Put9:	XCHG	[Largeur],BX
        IMUL	AX,[Page],HautScr*5
        OR	AX,$A000
	MOV	ES,AX
        MOV	DS,WORD PTR [Src+2]
	MOV	DX,$3C4
        MOV	AL,$02
        OUT	DX,AL
        MOV	DL,$CE
        MOV	AL,$04
        OUT	DX,AL
        MOV	CX,DI
        SHR	DI,2
        MOV	AL,$11
        AND	CL,3
        MOV	AH,CL
        SHL	AL,CL
@LoopRowSprite:
        MOV	DX,$3C5
        OUT	DX,AL
        MOV	DL,$CF
        ROL	AX,8
        OUT	DX,AL
        ROL	AX,8
        MOV	CX,[Hauteur]
	PUSH	SI
        PUSH	DI
@LoopPoint:
        MOV	DL,[SI]
        OR	DL,DL
        JZ	@Put6
        MOV	ES:[DI],DL
@Put6:	ADD	SI,BX
	ADD	DI,80
        LOOP	@LoopPoint
        POP	DI
        POP	SI
        ADD	SI,[Sens]
        ROL	AL,1
        ADC	DI,CX
        INC	AH
        DEC	[Largeur]
        JNZ	@LoopRowSprite
@ExitPutSprite:
	POP	DS
end;

procedure PutObjet; assembler;
asm
	PUSH	[Page]
        PUSH	[X]
        PUSH	[Y]
        MOV	SI,[Handle]
        SHL	SI,1
        ADD	SI,OFFSET [DimSprite]
        XOR	AH,AH
        LODSB
        PUSH	AX
        LODSB
        PUSH	AX
        PUSH	[Option]
        SUB	SI,OFFSET [DimSprite+2]
	SHL	SI,1
DB $66; PUSH	WORD PTR [PtrSprite+SI]
	CALL	Put
end;

procedure PutSprite; assembler;
asm
	PUSH	[Page]
        PUSH	[X]
        PUSH	[Y]
	LDS	SI,[Sprite]
        XOR	AH,AH
        LODSB
        PUSH	AX
        LODSB
        PUSH	AX
        PUSH	[Option]
	PUSH	DS
        PUSH	SI
        CALL	Put
end;

procedure PutDecor; assembler;
asm
	IMUL	AX,[Page],HautScr*5
        OR	AX,$A000
        MOV	ES,AX
        MOV	DI,[Y]
        MOV	AX,DI
        SHL	AX,6
        SHL	DI,4
        ADD	DI,AX
        MOV	CX,[X]
        MOV	AX,CX
        SHR	AX,2
        ADD	DI,AX
	MOV	AL,$02
        MOV	DX,$3C4
        OUT	DX,AL
        INC	DX
        MOV	AL,$11
        AND	CL,3
        ROL	AL,CL
        PUSH	DS
        MOV	DS,WORD PTR [Decor+2]
        MOV	SI,[Num]
        SHL	SI,8
        MOV	BX,16
@LoopRow:
	MOV	CX,16
        OUT	DX,AL
@LoopPixel:
        MOVSB
        ADD	SI,15
	ADD	DI,79
	LOOP	@LoopPixel
        SUB	SI,255
        ROL	AL,1
        CMC
        SBB	DI,80*16-1
        DEC	BX
        JNZ	@LoopRow
        POP	DS
end;

procedure SetSpriteWindow;
begin
  SpriteWindow.X1 := X1;
  SpriteWindow.Y1 := Y1;
  SpriteWindow.X2 := X2+1;
  SpriteWindow.Y2 := Y2+1;
end;

procedure ResetSpriteWindow;
begin
  SpriteWindow.X1 := 0;
  SpriteWindow.Y1 := 0;
  SpriteWindow.X2 := 320;
  SpriteWindow.Y2 := HautScr;
end;

procedure BigPut;
var
  xr, yr: Word;
begin
  for yr := 0 to 15 do for xr := 0 to 15 do if Sprite[yr shl 4 or xr] <> 0 then
    FillBox (Page, x + xr shl 1, y + yr shl 1,
    	           x + xr shl 1+1, y + yr shl 1+1, Sprite[yr shl 4 or xr]);
end;

procedure ShowError;
var
  P, L: Byte;
  TmpS: array[0..5] of String[22];
begin
  CLS(Page_not_display, 252);
  OutPalette(240, 255);
  P := Pos('/', Message);
  if P = 0 then exit;
  L := 0;
  while P <> 0 do
  begin
    TmpS[L] := Copy(Message, 1, P-1);
    Delete(Message, 1, P);
    Inc(L);
    P := Pos('/', Message);
  end;
  for P := 0 to L-1 do OutText(Page_not_display, 159-Length(TmpS[P])*7, 100-L shl 3+P shl 4, TmpS[P], 242, 243, True);
  ShowPage;
  Beep;
  Sleep;
end;

end.
