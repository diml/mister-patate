
{$G+,N+}
{ Moteur du jeu }
unit MrpJeu;

interface

uses MrpVga, MrpLoad, MrpPal, MrpKey, MrpStr, MrpTps, MrpMenu, MrpSon, MrpCode;

const

  { Pour la position des personnages }
  Droite = $0000;
  Gauche = $0001;
  Marche = $0002;
  Freine = $0004;
  Sourit = $0008;
  Tombe  = $0010;
  Saute  = $0020;
  Petit  = $0040;
  Action = $0080;
  Porte  = $0100;
  Lance  = $0200;
  Echelle= $0400;
  Bouge  = $0800;
  Frappe = $1000;
  KO     = $2000;
  PerdVie= $4000;

  { Pour les types informations sur les objets }
  ObjetEnMvt   = $0002;
  ObjetStop    = $0004;
  ObjetTsp     = $0200;
  ObjetPara    = $0400;
  ObjetPris    = $0800;
  ObjetTire    = $1000;
  ObjetPasTombe= $4000;
  ObjetPerso   = $8000;

  ObjetPosBit   = $0003;
  ObjetRien     = $0004;
  ObjetPiquant  = $0008;
  ObjetQuiTire  = $0010;
  ObjetAmi      = $0020;
  ObjetKO       = $0040;
  ObjetPeurVide = $0080;
  ObjetSpeedBit = $0700;

  { Messages }
  Message: array[0..255] of char =
{00}  'BEURK!õ'+
{01}  'C''EST TOI LE BOSS MAINTENANT!õ'+
{02}  'ALORS, ON FAIT MOINS LE MALINõ'+
{03}  'SALUT, C''EST MOI LE PLUS BEAUõ'+
{04}  'COUCOU!õ'+
{05}  'ALORS, TU T''BOUGE!õ'+
{06}  'YEAH!õ'+
{07}  'AIIE!!õ'+
{08}  'BOBO!!õ'+
{09}  'CA SE FINIT EN PUREE!õ'+
{10}  'ET HOP! PRET POUR LE FAST-FOOD!õ';

  { Texte de triche }
  TxtTriche: array[0..11] of Char = 'TVQFSQBUBUFõ';

  { Musique des bonnus }
  MusFin = 15;
  MusicPiece  : array[0..3] of Byte = ( 6, $49,$51,MusFin);
  MusicVie    : array[0..5] of Byte = (20, $30,$3B,$25,$26,MusFin);
  MusicCadenas: array[0..5] of Byte = (20, $30,$3B,$25,$26,MusFin);
  MusicCode   : array[0..5] of Byte = (20, $30,$3B,$25,$26,MusFin);
  MusicSecret : array[0..5] of Byte = (20, $30,$3B,$25,$26,MusFin);
  MusicBoss   : array[0..5] of Byte = (20, $30,$3B,$25,$26,MusFin);
  MusicFin    : array[0..24] of Byte =
  (27, $15,$FF,$FF,$15,$FF,$FF,$15,$15,$FF,$FF,$19,$FF,$17,$FF,$17,$FF,$15,$FF,$15,$FF,$14,$FF,$15,MusFin);

  { Instrument pour la musique de gamme over }
  InsGammeOver: TIns = ($C1,$C2,$05,$00,$D8,$E8,$32,$21,$06,$04,$06);

var
  { Position de Mister Patate }
  MisterPos: Word;
  { Localisation de mister }
  MisterX, MisterY: Word;
  { Sa position quand il marche }
  CountMarche: Word;
  CountMarche1: Word;
  PosMarche: Byte;
  { ‚tat et sens du freinage }
  InfoFreine: Word;
  { Ses dimmensions }
  MisterLargeur: Word;
  MisterHauteur: Word;
  { Son ‚lan lorsque il court }
  MisterElan: Word;
  { ‚tat d'avancement lorsqu'il tombe ou saute }
  EtatTombe: Word;
  EtatSaute: Word;
  EtatPosS1: Byte;
  { Amplitude de la courbe de saut }
  Amplitude: Word;
  { ‚tat maximale du saut }
  MaxSaut  : Word;
  { Attend un peu avant de sauter }
  WaitSaute: Byte;
  { s 'il ne bouge pas pendant un moment, il sourit }
  CompteurPasBouge: Word;
  { Est-ce qu'il est transform‚ en boss }
  Boss: Byte;
  CountBoss: Word;
  Transforme: Word;
  { Num‚ro de l'objet qu'il porte }
  ObjetPorte: Word;
  NotTake: Boolean;
  { ‚tat de mouvement }
  EtatLance: Byte;
  EtatFrappe: Byte;
  { Attend avant d'aller vite }
  WaitCourt: Byte;
  { s'il est sur une case glissante, il freine plus longtemps }
  Glisse: Boolean;
  { Sa position sur l'‚chelle }
  PosEchelle: Byte;
  CountEchelle: Byte;
  { S'il est oblig‚ de sauter }
  SautForce: Boolean;
  { Position maximale }
  MaxPosX, MaxPosY: Word;
  { Vitesse de Mister Patate }
  PlusMarche: Word;
  { Position de l'‚cran }
  ScreenX, ScreenY: Word;
  MaxScreenX, MaxScreenY: Word;
  { Pour les couleurs }
  EtatPalette1: Byte;
  EtatPalette2: Byte;
  { Vie et ‚nergie }
  Bonnus: Byte;
  Vie: ShortInt;
  Energie: Byte;
  EtatStatut: Word;
  { Etat des levier }
  StatutLevier: array[0..7] of Boolean;
  { Pour les pieges }
  EtatMove: Byte;
  CountKO: Byte;
  TypeFin: Word;
  OpenTheScreen: Boolean;
  avancement: Byte;
  NiveauFinit: Byte;
  SuperBonnus: Byte;

{ Lance le jeu }
procedure Jouer;

{ Moteur du jeu }
procedure Jeu;

implementation

procedure CloseScreen(Color: Byte);
var
  i: Byte;
begin
  for i := 0 to 19 do begin
    Counter := 0;
    Wait;
    FillBox8x5 (   i,    i, 40-i shl 1, 1, color);
    FillBox8x5 (   i, 39-i, 40-i shl 1, 1, color);
    FillBox8x5 (   i,    i, 1, 40-i shl 1, color);
    FillBox8x5 (39-i,    i, 1, 40-i shl 1, color);
    while Counter = 0 do;
  end;
end;

procedure OpenScreen;
var
  i: Byte;
begin
  for i := 19 downto 0 do begin
    Counter := 0;
    Wait;
    CopyBox8x5 (   i,    i, 40-i shl 1, 1);
    CopyBox8x5 (   i, 39-i, 40-i shl 1, 1);
    CopyBox8x5 (   i,    i, 1, 40-i shl 1);
    CopyBox8x5 (39-i,    i, 1, 40-i shl 1);
    while Counter = 0 do;
  end;
end;

procedure InverseScreen;
var
  i: Byte;
begin
  for i := 0 to 19 do begin
    Counter := 0;
    Wait;
    CopyBox8x5 (   i,    i, 40-i shl 1, 1);
    CopyBox8x5 (   i, 39-i, 40-i shl 1, 1);
    CopyBox8x5 (   i,    i, 1, 40-i shl 1);
    CopyBox8x5 (39-i,    i, 1, 40-i shl 1);
    while Counter = 0 do;
  end;
end;

{ Affiche le code }
procedure ShowCode;
var
  i: Byte;
  w: Word;
begin
  Cls (Page_not_display, 7);
  OutTextR (Page_not_display, Centre, Centre-24, 'CODE DU NIVEAU', 242, 243, True);
  w := Round (Sqrt (LongInt(Code) shl 8));
  for i := 0 to 3 do
    BigPut (Page_not_display, 93 + i * 34, 116, SpriteCode[(w shr ((3-i)* 3)) and 7]);
  InverseScreen;
  Sleep;
  OpenTheScreen := true;
end;

procedure ShowTitre;
begin
  Music.EnAble := False;
  Music.OfsSound := Ofs (MusicNote);
  Music.EnAble := True;
  Cls (Page_not_display, 7);
  if Length (Nom[Niveau]) > 20 then begin
    OutTextR (Page_not_display,  Centre, Centre-45, StrPart1 (Nom[Niveau]), 242, 243, true);
    OutTextR (Page_not_display,  Centre, Centre-25, StrPart2 (Nom[Niveau]), 242, 243, true);
  end else begin
    OutTextR (Page_not_display,  Centre, Centre-35, Nom[Niveau], 242, 243, true);
  end;
  OutTextR (Page_not_display, centre, Centre+20, '   VIE : ' + StrE (Vie, 3), 242, 243, True);
  OutTextR (Page_not_display, centre, Centre+40, 'BONNUS : ' + StrE (Bonnus, 3), 242, 243, True);
  if avancement = 1 then InverseScreen
  else begin
    ShowPage;
    PaletteFadeOut;
    avancement := 1;
  end;
  ClearKey;
  Sleep;
  OpenTheScreen := True;
end;

procedure StartMusicGammeOver;
begin
  Music.EnAble := False;
  BonnusMusic.EnAble := False;
  InsGammeOver[3] := VolumeMusic;
  SetChannelIns (4, InsGammeOver);
  BonnusMusic.Pas := MusicFin[0];
  BonnusMusic.OfsSound := Ofs(MusicFin[1]);
  CounterSound := 1;
  BonnusMusic.EnAble := True;
end;

{ Moteur du jeu }
procedure Jeu; assembler;
var
  { Variable temporaire }
  TmpB1, TmpB2: Byte;
  TmpW1, TmpW2: Word;
  TmpSI: Word;
  { Pour l'affichage du niveau et de sprite }
  PixelX, PixelY: Word;
  Sens: Integer;
  { S‚l‚cteur de segments }
  SegmentData    : Word;
  SegmentDecor   : Word;
  SegmentPlan01  : Word;
  SegmentPlan23  : Word;
  SegmentEcran   : Word;
  { Decalage pour le calcul de l'offset }
  ShiftL: Byte;
  Next: Word;
  CounterSecret: Byte;
  { D‚placement de l'‚cran }
  MoveScrX, MoveScrY: Integer;
  { Lorsqu'un message est affich‚ }
  StatutMessage: Word;
  OffsetMessage: Word;
  LengthMessage: Word;
  PosTriche: Word;
asm
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                              {³ Initialisation ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
        { ***** Initialisation des s‚l‚cteurs de segments ***** }
	MOV	[SegmentData],DS
        MOV	AX,WORD PTR [Decor+2]
	MOV	[SegmentDecor],AX
        MOV	AX,WORD PTR [Plan+2]
	MOV	[SegmentPlan01],AX
        MOV	AX,WORD PTR [Plan+10]
	MOV	[SegmentPlan23],AX
        MOV	CL,[ShiftLargeur]
        SUB	CL,4
        MOV	[ShiftL],CL
        MOV	AX,16
        SHL	AX,CL
        MOV	[Next],AX
	MOV	[EtatPalette1],0
	MOV	[EtatPalette2],4
	MOV	[EtatMove],0
	MOV	[PosEchelle],01101110B {1,2,3,2,...}
	MOV	[CountEchelle],0
@Init:  MOV	[NiveauFinit],0
	MOV	[PosTriche],OFFSET [TxtTriche]
	CALL	ShowTitre
	CALL	PopObjet
	XOR	SI,SI
	MOV	CX,256
@Init6:	MOV	AX,ObjetSprite[SI].Word
        OR	AX,AX
        JNZ     @InitB
        MOV     AX,OFFSET @FinTestObjet
        JMP	@InitZ
@InitB: CMP	AX,265
	JE	@InitD
        CMP	AX,81
        JB	@InitE
        CMP	AX,84
        JBE	@InitD
@InitE:	CMP	AX,256
        JB	@Init7
        CMP	AX,260
        JA	@Init7
@InitD: MOV	AX,OFFSET @Caisse
	MOV	BX,OFFSET @Default
        JMP	@InitZ
@Init7:	CMP	AX,267
	JNE	@Init8
        MOV     AX,OFFSET @Mitrailleuse
	MOV	BX,OFFSET @Default
        JMP	@InitZ
@Init8:	CMP	AX,57
	JNE	@Init9
        MOV	AX,OFFSET @Marcheur
	MOV	BX,OFFSET @GetMarcheur
	JMP	@InitZ
@Init9:	CMP	AX,64
	JNE	@InitA
        MOV	AX,OFFSET @Lanceur
	MOV	BX,OFFSET @GetLanceur
	JMP	@InitZ
@InitA:	CMP	AX,74
	JNE	@InitC
        MOV	AX,OFFSET @Ascenseur
        MOV	BX,OFFSET @Default
	JMP	@InitZ
@InitC:	CMP	AX,76
	JNE	@InitY
        MOV	AX,OFFSET @Getteur
        MOV	BX,OFFSET @GetGetteur
        JMP	@InitZ
@InitY:	MOV	AX,OFFSET @FinTestObjet
	MOV	BX,OFFSET @Default
@InitZ: MOV	ObjetProc[SI].Word,AX
	MOV	ObjetGetSp[SI].Word,BX
	ADD	SI,2
        DEC	CX
        JNZ	@Init6
@Init5:	MOV	[MisterPos],0
	MOV	AX,[FirstPosX]
        MOV	[MisterX],AX
	MOV	AX,[FirstPosY]
        MOV	[MisterY],AX
        CALL	@CenterScreen
	MOV	[ObjetPorte],$FFFF
	MOV	[PlusMarche],1
        IMUL	AX,[Page_not_display],HautScr*5
	OR	AX,$A000
        MOV	[SegmentEcran],AX
	MOV	[MoveScrX],0
	MOV	[MoveScrY],0
        MOV	[CounterSecret],0
        MOV	AL,[Niveau]
        XOR	AH,AH
        SHL	AX,5
        ADD	AX,OFFSET [Nom]+1
        MOV	DI,AX
	MOV	[OffsetMessage],AX
        MOV	AL,[DI-1]
        XOR	AH,AH
        MOV	[LengthMessage],AX
        MOV	[StatutMessage],200
	MOV	[EtatStatut],255
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                            {³ Boucle principale ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@LoopJeu:
        { Remet … z‚ro le compteur }
        MOV	[Counter],0
	{ ***** Mouvement de mister patate ***** }
        TEST	[MisterPos],PerdVie
        JNZ	@MisterPerdVie
        TEST	[Transforme],$FFFF
        JNZ	@Suite5
        TEST	[MisterPos],KO
        JNZ     @TME5

        { Test si mister est sur une ‚chelle }
        MOV	DI,[MisterY]
        MOV	SI,[MisterHauteur]
        SHR	SI,1
        SUB	SI,DI
        NEG	SI
        AND	SI,$FFF0
        AND	DI,$FFF0
        MOV	CL,[ShiftL]
        SHL	DI,CL
        SHL	SI,CL
        MOV	AX,[MisterLargeur]
        SHR	AX,1
        ADD	AX,[MisterX]
        SHR	AX,4
	OR	DI,AX
	OR	SI,AX
        SHL	AX,4
	MOV	ES,[SegmentPlan01]
        MOV	BX,[KeyMrp.Bas]
        MOV	BL,BYTE PTR [GetKey+BX]
        XOR	CX,CX
	MOV	BH,ES:[DI]
        AND	BH,7
        CMP	BH,3 { Test si il marche sur une ‚chelle }
        JNE	@TMED
	NOT	CX
@TMED:	MOV	BH,ES:[SI]
        AND	BH,7
        CMP	BH,3   { Si la case en en son centre est une ‚chelle, }
        JE	@TME1  { il s'y acroche                               }
@TME2:  OR	CX,CX
	JZ	@TME5
	TEST	[MisterPos],echelle
        JNZ	@TME4
        OR	BL,BL               { Si on appuie sur la touche bas         }
        JZ	@TME5               { et que l'on n'est pas sur une ‚chelle, }
        MOV	[MisterX],AX        { on y descend                           }
        OR	[MisterPos],echelle
        CALL	@MisterGrandit
        AND	[MisterPos],NOT Tombe+Saute
        JMP	@TME4
@TME1:  OR	CX,CX
	JNZ	@TMEA
        MOV	BX,[KeyMrp.Haut]         { S'il ne marche pas sur une     }
        TEST	BYTE PTR [GetKey+BX],$FF { ‚chelle et que l'on appuie pas }
        JNZ     @TMEA                    { sur la touche haut, on ne      }
        MOV	DX,1			 { s'acroche pas                  }
        PUSH	AX
        CALL	@MisterTombeSansCaisse
        POP	AX
        OR	DX,DX
        JNZ	@TME5
	DEC	[MisterY]
@TMEA:	OR	[MisterPos],echelle         { Si oui, il se place dessus }
        CALL	@MisterGrandit
        AND	[MisterPos],NOT Tombe+Saute
@TME4:  MOV	BX,[KeyMrp.Bas]
	TEST 	BYTE PTR [GetKey+BX],$FF { si on appuie sur la touche bas, }
        JZ	@TME3                    { on descend                      }
	CALL	@IncEchelle
	CALL	@MisterTombeSansCaisse
        JMP	@SuiteA
@TME3:  MOV	BX,[KeyMrp.Haut]
	TEST	BYTE PTR [GetKey+BX],$FF { si on appuie sur la touche haut, }
        JZ	@TME8			 { on monte                         }
	CALL	@IncEchelle
	CALL	@MisterSaute
        JMP	@SuiteA
@TME8:	AND	[MisterPos],NOT Bouge
	JMP	@SuiteA
@TME5:  AND	[MisterPos],NOT echelle

	TEST	[MisterPos],Saute { Test si Mister Patate saute }
        JNZ	@SuiteB
        { * Test si Mister Patate tombe * }
@LBL02: TEST	[MisterPos],Tombe
	JNZ	@LBL34
        MOV	DX,1
        CALL	@MisterTombe
        OR	DX,DX
	JNZ	@Suite7
        MOV	BX,[MisterElan]
        ADD	BX,30
        SHR	BX,2
        INC	BX
        MOV	[Amplitude],BX
	OR	[MisterPos],Tombe
	MOV	[EtatTombe],0
@LBL34: INC	[EtatTombe]
        XOR	DX,DX
	MOV	AX,[EtatTombe]
        SHL	AX,1
        INC	AX
 	DIV	[Amplitude]
	MOV	DX,AX
        OR	AX,AX
        JZ	@SuiteA
        MOV	[Glisse],0
        CALL	@MisterTombe { Le fait tomber }
	OR	DX,DX        { Si la boucle ne c'est pas termin‚e,  }
        JZ	@SuiteA      { alors il ne peut pas tomber }
        AND	[MisterPos],NOT	Tombe
        MOV	[WaitSaute],16
        MOV	AX,[MisterPos]
        TEST	[Boss],$FF
        JZ	@LBL9A
        TEST	AX,Petit
        JZ	@LBL9A
        DEC	[Amplitude]
        JZ      @SuiteA
        MOV	BX,$0605
        CALL	@Sound
        MOV	AX,[EtatTombe]
        MOV	BX,AX
        SHR	BX,2
        INC	BX
        SUB	AX,BX
        JZ	@SuiteA
        MOV	[MaxSaut],AX
        MOV	[EtatSaute],0
        MOV	[SautForce],1
	OR	[MisterPos],Saute
	JMP	@SuiteA
@LBL9A: MOV	BX,[EtatTombe]
	SHR	BX,2
        CMP	BX,11
        JNA	@LBL9C
        MOV	BX,11
@LBL9C:	OR	BX,$0710
	CALL	@Sound
	NOT	AX
        TEST	AX,KO+Marche
        JZ	@MKO3
        JMP	@SuiteA

@SuiteB:{ * Mister Patate Saute * }
        TEST	[SautForce],$FF
        JNZ	@LBL70
	MOV	BX,[KeyMrp.Saute]
        TEST	BYTE PTR [GetKey+BX],$FF { Test si la touche saut }
        JZ	@SuiteE                  { est enfonc‚            }
@LBL70: INC	[EtatSaute]
        MOV	AX,[MaxSaut]
        SUB	AX,[EtatSaute]
        JZ      @SuiteE
        XOR	DX,DX
        SHL	AX,1
        INC	AX
        DIV	[Amplitude]
        MOV	DX,AX
        OR	AX,AX
        JZ	@SuiteA
        CALL	@MisterSaute { Le fait sauter }
	OR	DX,DX        { Si MisterY n'a pas chang‚,  }
        JZ	@SuiteA      { alors il ne peut pas sauter }
	MOV	BX,[EtatSaute]
	SHR	BX,2
        CMP	BX,11
        JNA	@LBL9D
        MOV	BX,11
@LBL9D: SUB	BX,11
	NEG	BX
	OR	BX,$0720
	CALL	@Sound
@SuiteE:AND	[MisterPos],NOT	Saute
        OR	[MisterPos],Tombe
        MOV	[EtatTombe],0
        MOV	[SautForce],0
        JMP	@LBL02

@Suite7:TEST	[MisterPos],KO
        JNZ	@MisterKO
	TEST	[WaitSaute],$FF
        JNZ	@LBL08
        TEST	[MisterPos],Echelle+Petit
        JNZ	@SuiteC
	MOV	BX,[KeyMrp.Saute]
        TEST	BYTE PTR [GetKey+BX],$FF { Test si la touche saut }
        JZ	@SuiteC                  { est enfonc‚            }
        MOV	AX,[MisterElan]
        SHR	AX,2
        ADD	AX,20
	MOV	[EtatPosS1],AL
        MOV	BX,AX
        SUB	BX,10
        SHR     BX,1
        INC	BX
        MOV	[Amplitude],BX
	TEST	[Boss],$FF
	JZ	@LBL40
        ADD	AX,10
@LBL40:	MOV	[MaxSaut],AX
	MOV	[EtatSaute],0
        OR	[MisterPos],Saute
	JMP	@SuiteB
@LBL08:	DEC	[WaitSaute]
@SuiteC:TEST	[MisterPos],echelle
	JZ	@LBL82
	MOV	[PlusMarche],1
        JMP	@LBL67
@LBL82:	MOV	[PlusMarche],2
        TEST	[Boss],$FF
        JZ	@LBL67
	INC	[PlusMarche]
@LBL67:	TEST	[WaitCourt],$FF
        JZ	@SuiteA
	DEC	[PlusMarche]
        DEC	[WaitCourt]
@SuiteA:TEST	[MisterPos],KO
        JNZ	@MisterKO
        MOV	BX,[KeyMrp.Haut]
        TEST	[MisterPos],echelle
        JNZ	@LBL41
        TEST	BYTE PTR [GetKey+BX],$FF
        JZ	@LBL81
        TEST	[MisterPos],Tombe+echelle+Saute
        JNZ	@LBL81
        MOV	[MoveScrY],-1
@LBL81:	{ * Test si mister s'abaisse * }
        MOV	BX,[KeyMrp.Bas]
        TEST	BYTE PTR [GetKey+BX],$FF
        JZ	@LBL22
        TEST	[MisterPos],Tombe+echelle+Saute
        JNZ	@LBL55
	MOV	[MoveScrY],1
@TestPassageSecret:
	MOV	DI,[MisterY]
        DEC	DI
        AND	DI,$FFF0
        MOV	CL,[ShiftL]
        SHL	DI,CL
        MOV	AX,[MisterLargeur]
        SHR	AX,1
        ADD	AX,[MisterX]
        SHR	AX,4
        OR	DI,AX
        MOV	ES,[SegmentPlan01]
        MOV	BL,ES:[DI]
        MOV	AL,BL
        AND	AL,7
        CMP	[CounterSecret],50
        JB	@LBL55
        CMP	AL,4
        JNE     @LBL55
        SHR	BX,2
        AND	BX,14
        MOV	AX,WORD PTR [SecretX+BX]
        SHL	AX,4
        MOV	[MisterX],AX
        MOV	AX,WORD PTR [SecretY+BX]
        SHL	AX,4
        ADD	AX,15
        MOV	[MisterY],AX
        MOV	SI,OFFSET [MusicSecret]
        CALL	@Music
        PUSH	7
	CALL	CloseScreen
        MOV	[OpenTheScreen],1
        CALL	@CenterScreen
@LBL55: TEST	[MisterPos],Petit
        JNZ	@LBL25
	OR	[MisterPos],Petit
        MOV	BX,9
        CALL	@SetDim
        CALL	@LacheObjet
	JMP	@LBL25
@LBL22: AND	[MisterPos],NOT Bouge
	TEST	[MisterPos],Petit { Si l'on n'appuie pas sur la touche }
	JZ	@LBL25            { bas et que mister est petit, on le }
        MOV	SI,[MisterY]      { si possible                        }
        MOV	BX,OFFSET DimSprite + 3
        TEST	[Boss],$FF
        JZ	@LBL31
        MOV	BX,OFFSET DimSprite + 55
@LBL31: XOR	DH,DH
	MOV	DL,[BX]
	SUB	DX,[MisterHauteur]
        PUSH	SI
        { * Test si mister peut se relever * }
        PUSH	[ScreenY]     { Fait monter Mister de la diff‚rence   }
        CALL	@MisterSaute  { de hauteur et observe s'il a la place }
	POP	[ScreenY]     { pour se relever                       }
        OR	DX,DX
        POP	[MisterY]
        JNZ	@LBL25
        AND	[MisterPos],NOT Petit
        MOV	BX,1
	CALL	@SetDim
@LBL25: { Test si il se met en position action }
	TEST	[MisterPos],Tombe+Saute+Petit+Marche+Echelle
	JNZ	@LBL41
	MOV	BX,[KeyMrp.Action]
        TEST	BYTE PTR [GetKey+BX],$FF
        JZ	@LBL41
        MOV	[MoveScrY],1
        TEST	[MisterPos],Action
        JNZ	@LBL42
        OR	[MisterPos],Action
        TEST	[MisterPos],Porte  { S'il porte, on ne fait rien }
        JNZ	@LBL42
	MOV	ES,[SegmentPlan01]
        MOV	DI,[MisterY]  { Cherche s'il y a un levier devant lui }
        DEC	DI
        AND	DI,$FFF0
        MOV	CL,[ShiftL]
        SHL	DI,CL
        MOV	AX,[MisterX]
        TEST	[MisterPos],1
        JNZ	@LBL43
	ADD	AX,[MisterLargeur]
        DEC	AX
@LBL43: SHR	AX,4
        OR	DI,AX
        MOV	BL,ES:[DI]
        MOV	AL,BL
        AND	AL,7
        CMP	AL,5
        JNE	@LBL42
        XOR	BL,64        { Si oui, il inverse le levier }
        MOV	ES:[DI],BL   { et le flag corespondant      }
        MOV	ES,[SegmentPlan23]
        TEST	BL,64
        JNZ	@IncLev
	DEC	ES:BYTE PTR [DI]
	JMP	@InvLev
@IncLev:INC	ES:BYTE PTR [DI]
@InvLev:SHR	BL,3
	AND	BL,7
        NOT	BYTE PTR [StatutLevier+BX]
	MOV	ES,[SegmentPlan01]
        MOV	DX,DS
        MOV	AX,ES { on inverse  les cases }
        MOV	DS,AX
        XOR	DI,DI
        XOR	SI,SI
        XOR	CX,CX
@LoopChangeCase:
	LODSB
        MOV	AH,AL
        AND	AL,7
        CMP	AL,2
        JNE	@LBL44
        SHR	AH,3
        AND	AH,7
        CMP	AH,BL
        JNE	@LBL44
	XOR	ES:BYTE PTR [DI],128
@LBL44:	INC	DI
	LOOP	@LoopChangeCase
        MOV	DS,DX
        JMP	@LBL42
@LBL41: AND	[MisterPos],NOT Action
	MOV	[NotTake],0
@LBL42: TEST	[EtatFrappe],$FF
	JZ	@LBL68
        DEC	[EtatFrappe]
        CMP	[EtatFrappe],10
        JNE	@LBL68
        AND	[MisterPos],NOT Frappe
@LBL68:	MOV	BX,[KeyMrp.Lance]        { Test si mister patate lance }
        TEST	BYTE PTR [GetKey+BX],$FF
        JZ	@LBL47
        TEST	[MisterPos],Petit
        JNZ	@LBL47
        TEST	[Boss],$FF
        JZ	@LBL63
	TEST    [MisterPos],Porte
        JNZ	@LBL64
        TEST	[EtatFrappe],$FF
        JNZ	@LBL47
	OR	[MisterPos],Frappe
        MOV	[EtatFrappe],20
        JMP	@LBL47
@LBL63:	TEST	[MisterPos],Porte
        JZ	@LBL47
@LBL64:	TEST	[MisterPos],Action
        JZ	@LBL51
        CALL	@LacheObjet
        MOV	[NotTake],1
	JMP	@LBL47
@LBL51:	OR	[MisterPos],Lance { Sinon il lance l'objet qu'il pote }
	MOV	[EtatLance],10
        MOV	BX,$FFFF
        XCHG	[ObjetPorte],BX
        MOV	AX,WORD PTR [ObjetAttr+BX]
        AND	AX,NOT ObjetPris
        OR	AX,ObjetTsp
        MOV	WORD PTR [ObjetAttr+BX],AX
        OR	WORD PTR [ObjetAttr2+BX],ObjetAmi
        MOV	AX,[MisterLargeur]
        SHR	AX,1
        ADD	AX,WORD PTR [ObjetVSize+BX]
        SUB	AX,[MisterY]
        NEG	AX
        MOV	WORD PTR [ObjetY+BX],AX
        AND	[MisterPos],NOT Porte
        MOV	ObjetProc[BX].Word,OFFSET @VoleObjet
@LBL47: MOV	SI,[MisterPos]
        { Si mister monte … une ‚chelle, il ne marche pas }
        TEST	SI,Bouge
        JNZ	@TestHaut
        { Test si mister freine }
        TEST	SI,Freine
        JNZ	@MisterFreine
        { Test si mister marche }
        TEST	SI,Marche
        JZ	@TestMarche
        TEST	SI,1
        JNZ	@MarcheVersGauche
        { Test si la touche droite est enfonc‚, sinon il freine }
        CALL	@IncMarche
        MOV	BX,[KeyMrp.Droite]
        TEST	BYTE PTR [GetKey+BX],$FF
        JZ	@StopMarche
        MOV	DX,[PlusMarche]
        CALL	@MisterMarcheDroite
        JMP	@IncElan
@MarcheVersGauche: { Test si la touche droite est enfonc‚, sinon il freine }
        CALL	@IncMarche
        MOV	BX,[KeyMrp.Gauche]
        TEST	BYTE PTR [GetKey+BX],$FF
        JZ	@StopMarche
        MOV	DX,[PlusMarche]
        CALL	@MisterMarcheGauche
@IncElan: { Augmente l'‚lan de mister patate }
        XOR	AX,AX
        OR	DX,DX
        JNZ	@Elan0
        TEST	SI,Saute+Tombe
        JNZ	@Elan0
        MOV	AX,[MisterElan]
        CMP	AX,40
        JAE	@Elan0
        ADD	AX,2
@Elan0: MOV	[MisterElan],AX
	JMP	@TestHaut
@StopMarche: { Mister patate arrˆte de marcher si l'on n'appuie plus }
        AND	SI,NOT Marche
        MOV	AX,[MisterElan]
        TEST	[Glisse],$FF
        JNZ	@StopM0
        SHR	AX,1
	CMP	AX,5
        JBE	@TestHaut
        JMP	@StopM1
@StopM0:SHL	AX,1
	ADD	AX,10
	MOV	[Glisse],0
@StopM1:OR	SI,Freine
        MOV	BX,SI
        SHL	BX,7
	OR	BX,AX
        MOV	[InfoFreine],BX
@MisterFreine: { Fait freiner mister patate }
        MOV	DX,[InfoFreine]
        MOV	BX,DX
        AND	BX,$0080
        AND	DX,$007F
	TEST	SI,Saute+Tombe
        JZ      @Frein4
        DEC	DX
        JZ	@Frein2
@Frein4:TEST	SI,Marche
	JZ	@Frein5
        DEC	DX
        JZ	@Frein2
@Frein5:DEC	DX
        JZ	@Frein2
        OR	BX,DX
        MOV	[InfoFreine],BX
        CMP	DX,20
        MOV	DX,1
        JB	@Frein3
        INC	DX
@Frein3:TEST	BX,$0080
        JZ	@Frein0
        CALL	@MisterMarcheGauche
        JMP	@Frein1
@Frein0:CALL	@MisterMarcheDroite
@Frein1:OR	DX,DX
	JZ	@TestMarche
@Frein2:AND 	SI,NOT Freine
@TestMarche: { Test si l'on appuie }
        MOV	[WaitCourt],4
	MOV	BX,[KeyMrp.Droite]
        TEST	BYTE PTR [GetKey+BX],$FF { Test si la touche droite }
        JNZ	@TestM0                  { est enfonc‚              }
	MOV	BX,[KeyMrp.Gauche]
        TEST	BYTE PTR [GetKey+BX],$FF { Test si la touche gauche }
        JZ	@TestM2                  { est enfonc‚              }
        OR	SI,Gauche
	JMP	@TestM1
@TestM0:AND	SI,$FFFE
@TestM1:TEST	SI,Marche
        JNZ     @TestM3
	OR	SI,Marche
	MOV	[MisterElan],0
        MOV	[CountMarche],0
        MOV	[CountMarche1],0
        MOV	[PosMarche],$19
        JMP	@TestHaut
@TestM3:CALL	@IncMarche
	JMP	@TestHaut
@TestM2:TEST	SI,Marche
        JZ	@TestHaut
        AND	SI,NOT Marche

@TestHaut:
        AND	[MisterPos],NOT (1+Marche+Freine)
        OR	[MisterPos],SI
        { Si on ne fait rien }
	TEST	[MisterPos],Marche + Freine
        JNZ	@Suite4
        INC	[CompteurPasBouge]
        TEST	[MisterPos],Petit
        JZ	@LBL38
        TEST	[MisterPos],Tombe+Saute
        JNZ	@LBL38
        INC	[CounterSecret]
        CMP	[CompteurPasBouge],80
        JNE     @LBL38
        MOV	DX,1
        CALL	@MisterTombeSansCaisse
        JMP	@Suite5
@LBL38:	CMP	[CompteurPasBouge],100
        JB	@Suite5
        JA	@MS0
        MOV	AX,[MisterPos]
        NOT	AL
        AND	AX,1
        SHL	AL,1
        DEC	AX
	MOV	[MoveScrX],AX
	JMP	@Suite5
@MS0:	TEST	[Boss],$FF
        JNZ	@Suite4
        TEST	[MisterPos],Porte + Tombe + Saute + Action + Echelle + Petit + KO
        JNZ	@Suite4
	CMP	[CompteurPasBouge],400
        JE	@Suite4
	CMP	[CompteurPasBouge],300
        JNE	@Suite5
@MS4:	TEST	[MisterPos],Porte + Tombe + Saute + Action + Echelle + Petit + KO
        JNZ	@Suite5
        OR	[MisterPos],Sourit
	MOV	[StatutMessage],100
        MOV	BX,$0303
        CALL    @SetRandomMessage
	JMP	@Suite5
@Suite4:MOV	[CompteurPasBouge],0
        MOV	[CounterSecret],0
	AND	[MisterPos],NOT Sourit
        JMP	@Suite5

@GameOverTxt:
	DB	9,'GAME OVER'

@MisterPerdVie:
	TEST	[MisterPos],Saute
	JZ	@MPV1
	MOV	AX,[EtatSaute]
        SHL	AX,1
        INC	AX
        SHR	AX,4
	SUB	[MisterY],AX
        DEC	[EtatSaute]
        JNZ	@Suite5
	AND     [MisterPos],NOT Saute
	OR	[MisterPos],Tombe
        CMP	[Vie],-1
        JZ	@MPV3
	MOV	[StatutMessage],-1
        MOV	BX,$0109
        CALL	@SetRandomMessage
        ADD	BX,60
        MOV	[TypeFin],BX
	JMP	@MPV1
@MPV3:	MOV	[TypeFin],272
        CALL	StartMusicGammeOver
@MPV1:  TEST	[MisterPos],Tombe
	JZ	@MPV2
	MOV	AX,[EtatSaute]
        INC	[EtatSaute]
        SHL	AX,1
        INC	AX
        SHR	AX,4
	ADD	AX,[MisterY]
        MOV	[MisterY],AX
        SUB	AX,[ScreenY]
	CMP	AX,120
        JL	@Suite5
	AND	[MisterPos],NOT Tombe
        CMP	[TypeFin],69
        JNE	@Suite5
        DEC	[TypeFin]
        JMP	@Suite5
@MPV2:  TEST	BYTE PTR [GetKey+ScanEntree],$FF
	JZ      @Suite5
	MOV	[Energie],16
        CMP	[Vie],-1
        JE	@ExitGame
        JMP	@Init

@MisterKO:
	TEST	[MisterPos],Marche
        JZ	@MKO0
	MOV	DX,3
        TEST	[MisterPos],1
        JZ	@MKO1
        CALL	@MisterMarcheGauche
        JMP	@MKO2
@MKO1:  CALL	@MisterMarcheDroite
@MKO2:	OR	DX,DX
	JZ	@MKO0
	MOV	BX,$072B
	CALL	@Sound
        AND	[MisterPos],NOT Marche
        MOV	[CountKO],70
@MKO0:  DEC	[CountKO]
        JNZ	@Suite5
@MKO3:	AND	[MisterPos],NOT KO
        TEST	[MisterPos],Marche
        JZ	@Suite5
	AND	[MisterPos],NOT Marche
        OR	[MisterPos],Freine
        MOV	AX,[MisterPos]
        XOR	[MisterPos],1
        SHL	AL,7
        OR	AL,100
        MOV	[InfoFreine],AX


@Suite5:{ ***** Objets ***** }
	XOR	SI,SI
@LoopObjet:
	JMP	ObjetProc[SI].Word

{ *** Objet pour lancer ou empiler *** }
@Caisse:TEST	ObjetAttr[SI].Word,ObjetPasTombe
	JNZ	@Cai0
	CALL	@TestObjetTombe
@Cai0:  CALL	@TestObjetPrend
        JC	@FinTestObjet
        MOV	[ObjetPorte],SI
        OR	[MisterPos],Porte
        OR	WORD PTR [ObjetAttr+SI],Objetpris
        AND	WORD PTR [ObjetAttr+SI],NOT ObjetStop
        MOV	ObjetProc[SI].Word,OFFSET @FinTestObjet
	JMP	@FinTestObjet

{ *** Mitrailleuse gaitling *** }
@Mitrailleuse:
        TEST	ObjetAttr[SI].Word,ObjetPasTombe
	JNZ	@Mit0
	CALL	@TestObjetTombe
@Mit0:  CALL	@TestObjetPrend
        JC	@FinTestObjet
        MOV	DX,WORD PTR [ObjetStatut+SI]
        INC	DX
        MOV	WORD PTR [ObjetStatut+SI],DX
        TEST	DX,3             { Effectue un tire    }
        JNZ	@FinTestObjet    { … interval r‚gulier }
        MOV	BX,$0514
        CALL	@Sound
        MOV	BX,269
        SHR	DL,1
        AND	DX,6
        SUB	DL,3
        MOV	AL,DL
        SHR	AL,1
        XOR	AL,DL
        MOV	DH,-1
        TEST	AX,2
        JZ	@TOP1
	DEC	DH
@TOP1:  CALL	@CreateObjetTire
	MOV	ObjetGetSp[DI].Word,OFFSET @CoupDeFeu
        OR	WORD PTR [ObjetAttr2+DI],ObjetAmi
        MOV	DX,WORD PTR [ObjetAttr+SI]
        AND	DX,1
        MOV	CX,[MisterPos]
        AND	CX,$FFFE
        OR	CX,DX
        MOV	[MisterPos],CX
        MOV	AX,WORD PTR [ObjetX+SI]
        TEST	CX,1
        JZ	@TOP3
        ADD	AX,WORD PTR [ObjetHSize+SI]
        JMP	@TOP4
@TOP3:	SUB	AX,[MisterLargeur]
@TOP4:	MOV	[MisterX],AX
	JMP	@FinTestObjet

{ *** Ascenseur que mister patate peut emprunter *** }
@Ascenseur:
        { Test si mister est sur l'ascenseur }
        MOV	CX,WORD PTR [ObjetAttr2+SI]
        MOV	AX,CX
        AND	CX,ObjetSpeedBit
        MOV	BX,ObjetCount[SI].Word
        OR	BX,BX
        JZ	@ASCC
	DEC	BX
        MOV	ObjetCount[SI].Word,BX
        SHR	BX,2
	SUB	CH,BL
        JC	@FinTestObjet
@ASCC:	INC	CH
        SHR	CX,9
        JNC	@ASC5
        TEST	[EtatPalette1],1
        JZ	@ASC5
	INC	CX
@ASC5:  OR	CX,CX
	JZ    	@FinTestObjet
	XOR	DX,DX
	TEST	AX,4
	MOV	AX,WORD PTR [ObjetY+SI]
        JNZ	@AscHorz
        TEST	WORD PTR [ObjetAttr2+SI],32
        JNZ	@ASC3
@ASC1:  OR	DX,DX
	JNZ	@ASC9
	CALL	@TestAsc
        JC	@ASC9
        MOV	DX,CX
@ASC9:	DEC	AX
	LOOP	@ASC1
        MOV	WORD PTR [ObjetY+SI],AX
        MOV	BX,WORD PTR [ObjetLim1+SI]
        SHL	BX,4
        CMP	AX,BX
        JA	@ASC4
	OR	WORD PTR [ObjetAttr2+SI],32
	MOV	ObjetCount[SI].Word,100
@ASC4:  OR	DX,DX
        JZ	@FinTestObjet
	CALL	@MisterSaute
       	JMP	@FinTestObjet
@ASC3:	OR	DX,DX
	JNZ	@ASCA
	CALL	@TestAsc
        JC	@ASCA
        MOV	DX,CX
@ASCA:	INC	AX
	LOOP	@ASC3
        MOV	WORD PTR [ObjetY+SI],AX
        ADD	AX,WORD PTR [ObjetVSize+SI]
        DEC	AX
        MOV	BX,WORD PTR [ObjetLim2+SI]
        SHL	BX,4
        ADD	BX,15
        CMP	AX,BX
        JB	@ASC2
	AND	WORD PTR [ObjetAttr2+SI],NOT 32
	MOV	ObjetCount[SI].Word,100
@ASC2:  OR	DX,DX
        JZ	@FinTestObjet
	CALL	@MisterTombe
	JMP	@FinTestObjet
@AscHorz:
	CALL	@TestAsc
        JC	@ASCB
	MOV	DX,CX
@ASCB:	MOV	AX,WORD PTR [ObjetX+SI]
        TEST	WORD PTR [ObjetAttr2+SI],32
        JNZ	@ASC6
        SUB	AX,CX
        MOV	WORD PTR [ObjetX+SI],AX
        MOV	BX,WORD PTR [ObjetLim1+SI]
        SHL	BX,4
        CMP	AX,BX
        JA	@ASC7
	OR	WORD PTR [ObjetAttr2+SI],32
	MOV	ObjetCount[SI].Word,100
@ASC7:  OR	DX,DX
        JZ	@FinTestObjet
	CALL	@MisterMarcheGauche
       	JMP	@FinTestObjet
@ASC6:  ADD	AX,CX
        MOV	WORD PTR [ObjetX+SI],AX
        ADD	AX,WORD PTR [ObjetHSize+SI]
        DEC	AX
        MOV	BX,WORD PTR [ObjetLim2+SI]
        SHL	BX,4
        ADD	BX,15
        CMP	AX,BX
        JB	@ASC8
	AND	WORD PTR [ObjetAttr2+SI],NOT 32
	MOV	ObjetCount[SI].Word,100
@ASC8:  OR	DX,DX
        JZ	@FinTestObjet
	CALL	@MisterMarcheDroite
	JMP	@FinTestObjet

{ *** Ennemi qui mache bˆtement *** }
@Marcheur:
	TEST	ObjetAttr[SI].Word,ObjetPasTombe
	JNZ	@Mar0
	CALL	@TestObjetTombe
@Mar0:  CALL	@ObjetMarche
        CALL	@TestAttaque
        JC	@FinTestObjet
        XOR	DI,1
        AND	DI,1
        AND	ObjetAttr[SI].Word,$FFFE
        OR	ObjetAttr[SI].Word,DI
        JMP	@FinTestObjet

{ *** Ennemi statique qui lance des objets *** }
@Lanceur:
    	TEST	ObjetAttr[SI].Word,ObjetPasTombe
	JNZ	@Lan0
	CALL	@TestObjetTombe
@Lan0:  CALL	@ObjetLanceur
	CALL	@TestAttaque
        JMP	@FinTestObjet

@MarcheurTombeKO:
	MOV	DL,BYTE PTR [ObjetStatut+1+SI]
        INC	DL                            { Incr‚mente l'‚tat du saut }
        JNZ	@MTKO0                        { si il n'est pas … son     }
	MOV	DL,255                        { maximum                   }
@MTKO0: MOV	BYTE PTR [ObjetStatut+1+SI],DL
	XOR	DH,DH  { calcul le nombre de pixel  }
        SHL	DX,1   { duquel doit tomber l'objet }
        INC	DX
        SHR	DX,4
        ADD	ObjetY[SI].Word,DX
        MOV	[TmpB1],1
        CALL	@TestObjetDelEnnemi
        JNC	@FinTestObjet
        OR	WORD PTR [ObjetAttr2+SI],ObjetKO
        MOV	WORD PTR [ObjetElan+DI],SI
        MOV	ObjetProc[SI].Word,OFFSET @FinTestObjet
	JMP	@finTestObjet

@PersoSauteKO:
	TEST	WORD PTR [ObjetAttr+SI],Saute
        JZ	@OSKO0
        MOV	AX,30
  	SUB	AX,WORD PTR [ObjetStatut+SI]
        INC	WORD PTR [ObjetStatut+SI]
	SHL	AX,1
        INC	AX
        SHR	AX,3
        SUB	WORD PTR [ObjetY+SI],AX
        MOV	DI,WORD PTR [ObjetElan+SI]
        CMP	DI,-1
        JE	@OSKO3
        SUB	WORD PTR [ObjetY+DI],AX
@OSKO3: OR	AX,AX
        JZ	@OSKO1
	JMP	@FinTestObjet
@OSKO1:	AND	WORD PTR [ObjetAttr+SI],NOT Saute
  	MOV	WORD PTR [ObjetStatut+SI],0
@OSKO0:	MOV	AX,WORD PTR [ObjetStatut+SI]
        INC	WORD PTR [ObjetStatut+SI]
	SHL	AX,1
        INC	AX
        SHR	AX,3
        MOV	BX,WORD PTR [ObjetY+SI]
        ADD	BX,AX
        MOV	WORD PTR [ObjetY+SI],BX
        MOV	DI,WORD PTR [ObjetElan+SI]
        CMP	DI,-1
        JE	@OSKO4
        ADD	WORD PTR [ObjetY+DI],AX
@OSKO4: SUB	BX,[ScreenY]
        CMP	BX,300
        JL	@FinTestObjet
        CMP	DI,-1
        JE	@DelObjet
        MOV	BX,DI
        CALL	@DeletteObjet
	JMP	@DelObjet

@VoleObjet: { Fait voler un objet }
	TEST	ObjetAttr[SI].Word,1
        JZ	@VoleDroite
        MOV	AX,WORD PTR [ObjetX+SI]
        SUB	AX,6
        MOV	BX,[ScreenX]
        SUB	BX,160
        CMP	AX,BX
        JL	@DelObjet
        MOV	WORD PTR [ObjetX+SI],AX
        JMP     @TestObjetFrappe
@VoleDroite:
        MOV	AX,WORD PTR [ObjetX+SI]
        ADD	AX,6
        MOV	BX,[ScreenX]
        ADD	BX,480
        CMP	AX,BX
        JG	@DelObjet
        MOV	WORD PTR [ObjetX+SI],AX
@TestObjetFrappe:
	TEST	WORD PTR [ObjetAttr2+SI],ObjetRien
        JNZ	@FinTestObjet
	TEST	WORD PTR [ObjetAttr2+SI],ObjetAmi
        JZ	@TOF0
        MOV	[TmpB1],0
        CALL	@TestObjetDelEnnemi
        JNC	@FinTestObjet
        OR	WORD PTR [ObjetAttr2+SI],ObjetKO
        MOV	WORD PTR [ObjetElan+DI],SI
        MOV	ObjetProc[SI].Word,OFFSET @FinTestObjet
	MOV	BX,$0040
	MOV	ES,BX
	MOV	BL,ES:[$006C]
        AND	BL,7
	OR	BX,$0510
	CALL	@Sound
        JMP	@FinTestObjet
@TOF0:  CALL	@GetDist
        CMP	AX,BX
        JA	@FinTestObjet
        CMP	CX,DX
        JA	@FinTestObjet
        TEST	[Boss],$FF
        JZ	@TOF1
        XOR	WORD PTR [ObjetAttr+SI],1
        OR	WORD PTR [ObjetAttr2+SI],ObjetAmi
        MOV	BX,$0600
        CALL	@Sound
	JMP	@FinTestObjet
@TOF1:  MOV	BX,$0040
	MOV	ES,BX
	MOV	BL,ES:[$006C]
        AND	BL,7
	OR	BX,$0510
	CALL	@Sound
	CALL	@FrappeMister
        MOV	BX,SI
        CALL	@DeletteObjet
	JMP	@FinTestObjet

{ Personnage qui guette }
@Getteur:
        TEST	ObjetAttr[SI].Word,ObjetPasTombe
	JNZ	@GETT0
	CALL	@TestObjetTombe
@GETT0: CALL	@GetDist
	TEST	ObjetAttr2[SI].Word,$0002
	JNZ	@GETT1
        CMP	CX,DX
        JA	@GETT6
        MOV	BX,ObjetLim2[SI].Word
        SHL	BX,4
        TEST	[MisterPos],Petit
        JZ	@GETT4
        MOV	CX,BX
        SHR	CX,2
        SUB	BX,CX
@GETT4: CMP	AX,BX
	JA	@GETT5
	OR      ObjetAttr2[SI].Word,$0002
        MOV	ObjetCount[SI].Word,500
        JMP	@GETT7
@GETT5:	MOV	CX,BX
	SHR	CX,1
        ADD	BX,CX
        CMP	AX,BX
        JA	@GETT6
        OR	ObjetAttr2[SI].Word,$0001
@GETT7:	MOV	CX,WORD PTR [ObjetAttr+SI]
	XOR	CX,DI
        AND	CX,1
        XOR	WORD PTR [ObjetAttr+SI],CX
	JMP	@GETT2
@GETT1: DEC	ObjetCount[SI].Word
	JNZ	@GETT3
        MOV	BX,ObjetLim2[SI].Word
        SHL	BX,4
	CMP	AX,BX
	JA	@GETT6
        CMP     CX,DX
        JNA     @GETT8
@GETT6:	AND	ObjetAttr2[SI].Word,NOT ObjetPosBit
	JMP     @GETT2
@GETT8:	MOV	ObjetCount[SI].Word,500
@GETT3:	CALL	@ObjetMarche
@GETT2:	CALL	@TestAttaque
        JC	@FinTestObjet
        XOR	ObjetAttr[SI].Word,1
        JMP	@FinTestObjet


@FinTestObjet:
        ADD	SI,2
        CMP	SI,512
        JNE	@LoopObjet { Objet suivant }
        { Met l'objet port‚ sur la tˆte de mister }
        MOV	SI,[ObjetPorte]
        CMP	SI,-1
        JE	@MoveScreen
	MOV	DX,[MisterPos]
        MOV	CX,DX
        AND	CX,1
        MOV	AX,ObjetAttr[SI].Word
        AND	AX,NOT 1
        OR	AX,CX
        MOV	ObjetAttr[SI].Word,AX
  	TEST	DX,Action
        JNZ	@MetObjetSurMain
        MOV	AX,[MisterY]
        SUB	AX,[MisterHauteur]
        SUB	AX,WORD PTR [ObjetVSize+SI]
        DEC	AX
        MOV	WORD PTR [ObjetY+SI],AX
        MOV	AX,[MisterLargeur]
        SHR	AX,1
        MOV	BX,WORD PTR [ObjetHSize+SI]
        SHR	BX,1
        TEST	[Boss],$FF
        JZ	@MOST2
        INC	BX
@MOST2: SUB	AX,BX
        TEST	[MisterPos],1
        JZ	@MOST0
        MOV	BX,[MisterX]
        ADD	BX,[MisterLargeur]
        SUB	BX,AX
        SUB	BX,WORD PTR [ObjetHSize+SI]
        MOV	AX,BX
	JMP	@MOST1
@MOST0: ADD	AX,[MisterX]
@MOST1: MOV	WORD PTR [ObjetX+SI],AX
	JMP	@MoveScreen
@MetObjetSurMain: { Si il est en action il le met devant lui }
        MOV	AX,[MisterY]
        DEC	AX
	SUB	AX,WORD PTR [ObjetVSize+SI]
        MOV	WORD PTR [ObjetY+SI],AX
	MOV	AX,[MisterX]
        TEST	DX,1
        JZ	@LBL49
	SUB	AX,WORD PTR [ObjetHSize+SI]
	INC	AX
        MOV	WORD PTR [ObjetX+SI],AX
	JMP	@MoveScreen
@LBL49:	ADD	AX,[MisterLargeur]
        DEC	AX
        MOV	WORD PTR [ObjetX+SI],AX

        { ***** D‚placement du niveau ****** }
@MoveScreen:
        TEST	[MisterPos],PerdVie
        JNZ     @DS2
	MOV	ES,[SegmentPlan01]
        TEST	[Center],$FF
        JNZ     @CenterScreenMister
        MOV	DX,[MoveScrX]
        OR	DX,DX
        JZ	@DS0
        MOV	AX,[MisterX]
        ADD	AX,8
        MOV	BX,[ScreenX]
        SUB	AX,BX
        MOV	CX,[Screen.SpeedH]
        OR	DX,DX
        JNS	@DS1
        { D‚placement vers la gauche }
        SUB	AX,CX
        CMP	AX,LimZone[0].Word
        JB	@DS4
        SUB	BX,CX
        JNC	@DS6
        XOR	BX,BX
        JMP	@DS4
@DS1:   { D‚placement vers la droite }
        ADD	AX,CX
        CMP	AX,LimZone[2].Word
        JA	@DS4
        ADD	BX,CX
        CMP	BX,[MaxScreenX]
        JNA	@DS6
	MOV	BX,[MaxScreenX]
@DS4:	MOV	[MoveScrX],0
@DS6:	MOV	[ScreenX],BX
@DS0:   MOV	DX,[MoveScrY]
        OR	DX,DX
        JZ	@DS2
        MOV	AX,[MisterY]
        SUB	AX,12
        MOV	BX,[ScreenY]
        SUB	AX,BX
        MOV	CX,[Screen.SpeedV]
        OR	DX,DX
        JNS	@DSV1
        { D‚placement vers le haut }
        SUB	AX,CX
        CMP	AX,LimZone[4].Word
        JB	@DSV4
        SUB	BX,CX
        JNC	@DSV6
        XOR	BX,BX
        JMP	@DSV4
@DSV1:   { D‚placement vers le bas }
        ADD	AX,CX
        CMP	AX,LimZone[6].Word
        JA	@DSV4
        ADD	BX,CX
        CMP	BX,[MaxScreenY]
        JNA	@DSV6
	MOV	BX,[MaxScreenY]
@DSV4:	MOV	[MoveScrY],0
@DSV6:	MOV	[ScreenY],BX
	JMP	@DS2
@CenterScreenMister:
        XOR	SI,SI
        MOV	DI,Marche+Freine
        MOV	CX,[ScreenX]
        MOV	DX,[MaxScreenX]
        MOV	AX,[MisterX]
        ADD	AX,8
@CS5:	SUB	AX,CX
        MOV	BX,AX
        SUB	BX,LimZone[SI+0].Word
        JAE	@CS1
        ADD	CX,BX
        JNS	@CS3
        XOR	CX,CX
	JMP	@CS3
@CS1:   MOV	BX,AX
        SUB	BX,LimZone[SI+2].Word
        JBE	@CS2
        ADD	CX,BX
        CMP	CX,DX
        JBE	@CS3
        MOV	CX,DX
        JMP	@CS3
@CS2:	TEST	[MisterPos],DI
	JNZ	@CS3
        MOV	BX,AX
        SUB	BX,LimZone[SI+8].Word
        JAE	@CS4
        DEC	CX
        JNS	@CS3
        INC	CX
        JMP	@CS3
@CS4:   SUB	AX,LimZone[SI+10].Word
        JBE	@CS3
        INC	CX
        CMP	CX,DX
        JBE	@CS3
        DEC	CX
@CS3:   OR	SI,SI
	JNZ	@CS6
	MOV	[ScreenX],CX
        MOV	SI,4
        MOV	DI,Tombe+Saute
	MOV	CX,[ScreenY]
        MOV	DX,[MaxScreenY]
        MOV	AX,[MisterY]
        SUB	AX,12
        JMP	@CS5
@CS6:	MOV	[ScreenY],CX
@DS2:

	test	byte ptr [getkey+scanf1],$ff
        jz  @t
	mov	ax,objetx[28].word
        mov	cx,objethsize[28].word
        shr	cx,1
        add	ax,cx
        sub	ax,160
	mov	bx,objety[28].word
        mov	dx,objetvsize[28].word
        shr	dx,1
        add	bx,dx
        sub	bx,100
        mov	[screenx],ax
        mov	[screeny],bx
@t:


	{ ***** Affichage du niveau ****** }
	MOV	DX,$3C4 { S‚lection des fonctions }
        MOV	AL,$02  { de choix des plans de   }
        OUT	DX,AL   { lecture et d'‚criture   }
	MOV	SI,[ScreenY] { Calcul de l'offset de d‚part }
	MOV	BX,SI
        AND	SI,$FFF0
        MOV	CL,[ShiftL]
        SHL	SI,CL
        MOV	AX,[ScreenX]
        MOV	DL,AL
        SHR	AX,4
        OR	SI,AX
        XOR	BH,BH
        SHL	BL,4
        AND	DL,$0F
        OR	BL,DL
        MOV	[TmpB1],BL
        MOV	[TmpB2],$11
@SS0:   PUSH	SI { * Nouveau plan * }
        MOV	DX,$3C5
        MOV	AL,[TmpB2]
        OUT	DX,AL { S‚lection du plan d'‚criture }
        XOR	DI,DI
	MOV	DH,80
        MOV	BL,[TmpB1]
        MOV	CH,BL
        SHR	CH,2
        AND	CH,3
        SUB	CH,4
        NEG	CH
@SS1:   PUSH	SI { * Nouvelle colonne * }
        MOV	DL,HautScr
@SS2:	MOV	ES,[SegmentPlan01] { * Nouvelle case * }
	XOR	AH,AH
        MOV	AL,ES:[SI]
        MOV	ES,[SegmentPlan23]
	TEST	AL,128
        JZ	@SS3
	MOV	AX,[SegmentDecor]
        JMP	@SS6
@SS3:   TEST	AL,64
	JZ	@SS4
	AND	AL,7
        CMP	AL,5
        JE	@SS4
	MOV	AL,[EtatMove]
	ADD	AL,ES:[SI]
	JMP	@SS5
@SS4:	MOV	AL,ES:[SI]
@SS5:	SHL	AX,4
	ADD	AX,[SegmentDecor]
@SS6:	DB	$8E,$E0 { MOV FS,AX }
        XOR	AH,AH
        MOV	AL,ES:[SI+32768]
        SHL	AX,4
        ADD	AX,[SegmentDecor]
        DB	$8E,$E8 { MOV GS,AX }
        ADD	SI,[Next]
        MOV	ES,[SegmentEcran]
@SS7:	{ * Affichage des pixels * }
	MOV	CL,CH
@LoopStagePixel: { Met les pixels dans EAX }
DB $64; MOV	AL,[BX] { AL = Pixel du plan 1 }
	OR	AL,AL
        JNZ	@SS8
DB $65;	MOV	AL,[BX] { AL = 0 => AL = Pixel du plan 2 }
@SS8:	DEC	CL { Pixel suivant }
	JZ	@PutStagePixel
        ADD	BL,4
DB $66;	ROR	AX,8
	JMP	@LoopStagePixel
@PutStagePixel:
        TEST	CH,4
        JZ	@SSA
DB $66;	ROR	AX,8
DB $66; STOSW
	ADD	DI,76
        ADD	BL,4
	JMP	@SSF
@SSA:	CMP	CH,2
	JE	@SSB
        JB	@SSI
DB $66;	ROR	AX,16
	STOSW
DB $66; SHR	AX,16
	STOSB
        ADD	DI,77
        ADD	BL,8
        JMP	@SSF
@SSB: DB $66;ROL AX,8
	STOSW
        ADD	DI,78
        ADD	BL,12
        JMP	@SSF
@SSI:   STOSB
	ADD	DI,79
        ADD	BL,16
@SSF:	DEC	DL
	JNZ	@SSD { Test si la colonne est finie }
        XOR	BL,(HautScr AND 8) * 16
        AND	BL,$F3
        POP	SI
        SUB	DH,CH
        JNZ	@SSC { Test si le plan est fini }
        POP	SI
        SHL	[TmpB2],1
        JC	@SSE
        MOV	AL,[TmpB1]
        SHL	AX,4
        ADD	AL,16
        JNC	@SSH
        INC	SI
@SSH:	SHR	AX,4
	MOV	[TmpB1],AL
        JMP	@SS0
@SSC:   INC	SI
	SUB     DI,HautScr*80
        XOR	AH,AH
        MOV	AL,CH
        ADD	DI,AX
        CMP	DH,4
	JA	@SSG
	MOV	CH,DH
	JMP	@SS1
@SSG:	MOV	CH,4
	JMP	@SS1
@SSD:   JNC	@SS7
	JMP	@SS2
@SSE:
        { ***** Affiche les objets ***** }
        XOR	SI,SI
@LoopPutObjet:
	MOV	[TmpSI],SI
        MOV	BX,WORD PTR [ObjetSprite+SI]
        OR	BX,BX
        JZ	@NextObjet { test si l'objet existe }
	TEST	WORD PTR [ObjetAttr+SI],ObjetPris { Si l'objet est port‚ }
        JNZ	@NextObjet                        { par mister, on passe }
	TEST	WORD PTR [ObjetAttr+SI],ObjetPerso
        JNZ	@PO0
	TEST	WORD PTR [ObjetAttr2+SI],ObjetKO
        JNZ	@NextObjet
@PO0:   MOV	AX,WORD PTR [ObjetX+SI] { test si l'objet est … l'‚cran }
        SUB	AX,[ScreenX]
        MOV	[PixelX],AX
        MOV	AX,WORD PTR [ObjetY+SI]
        SUB	AX,[ScreenY]
        ADD	AX,WORD PTR [ObjetVSize+SI]
        DEC	AX
        MOV	[PixelY],AX
        CALL	@GetSpriteObjet
	MOV	AX,WORD PTR [ObjetHSize+SI]
        TEST	WORD PTR [ObjetAttr+SI],1
        CALL	@PutSprite
        MOV	SI,[TmpSI]
        TEST	WORD PTR [ObjetAttr+SI],ObjetStop { Test si l'objet atterrit }
        JZ	@TestBoum { Si oui, on met de la poussiŠre }
        MOV	AX,[PixelX]
        SHL	AX,1
        ADD	AX,WORD PTR [ObjetHSize+SI] { AX = Largeur }
        MOV	BL,BYTE PTR [ObjetStatut+1+SI]
	XOR	BH,BH { BX = Statut }
        SHR	BX,1
        AND	BX,NOT 1
        XOR	DH,DH
        MOV	DL,BYTE PTR [DimSprite+262*2+BX] { DX = Largeur poussiŠre }
        SUB	AX,DX
        SHR	AX,1
        MOV	[PixelX],AX
	SHR	BX,1
	ADD	BX,262
        XOR	AX,AX
        CALL	@PutSprite
        JMP	@NextObjet
@TestBoum:
        TEST	WORD PTR [ObjetAttr+SI],ObjetPerso
        JZ	@NextObjet
        TEST	WORD PTR [ObjetAttr2+SI],ObjetKO
        JZ	@NextObjet
        MOV	SI,WORD PTR [ObjetElan+SI]
        CMP	SI,-1
        JE	@NextObjet
        MOV	AX,WORD PTR [ObjetX+SI]
        SUB	AX,[ScreenX]
        MOV	[PixelX],AX
        MOV	AX,WORD PTR [ObjetY+SI]
        SUB	AX,[ScreenY]
        ADD	AX,WORD PTR [ObjetVSize+SI]
        DEC	AX
        MOV	[PixelY],AX
        MOV	AX,WORD PTR [ObjetHSize+SI]
        MOV	BX,WORD PTR [ObjetSprite+SI]
        TEST	WORD PTR [ObjetAttr+SI],1
        CALL	@PutSprite
@NextObjet:
        MOV	SI,[TmpSI]
	ADD	SI,2
        CMP	SI,512
        JNE	@LoopPutObjet
        MOV	SI,[ObjetPorte]
        CMP	SI,-1
        JE	@PutMister
	MOV	AX,WORD PTR [ObjetX+SI] { Affiche le sprite port‚ }
        SUB	AX,[ScreenX]            { Par Mister Patate       }
        MOV	[PixelX],AX
	MOV	AX,WORD PTR [ObjetY+SI]
        ADD	AX,WORD PTR [ObjetVSize+SI]
        SUB	AX,[ScreenY]
        DEC	AX
        MOV	[PixelY],AX
        MOV	AX,WORD PTR [ObjetHSize+SI]
        MOV	BX,WORD PTR [ObjetSprite+SI]
        TEST	ObjetAttr[SI].Word,1
        CALL	@PutSprite

	{ ***** Affiche Mister Patate ****** }
@PutMister:
	XOR	CX,CX
        XOR	DX,DX
        MOV	AX,[MisterPos]
        MOV	SI,[Transforme]
        TEST	SI,$FFFF
        JZ	@LBL69
	DEC	SI
        MOV	[Transforme],SI
        CMP	SI,100
        JB	@TMB0
        MOV	BX,271
        JMP	@Suite2
@TMB0:  CMP	SI,40
        JB	@TMB1
        MOV	BX,271
        AND	SI,1
        ADD	DX,SI
        JMP	@Suite2
@TMB1:	MOV	BX,270
	SUB	CX,7
        JMP	@Suite2
@LBL69: TEST	AX,PerdVie
        JNZ	@SpritePerdVie
        TEST	AX,KO
        JNZ	@SpriteKO
        TEST	AX,Petit
        JNZ	@SpritePetit
        TEST	AX,Lance
        JNZ	@SpriteLance
        TEST	AX,Echelle
        JNZ	@SpriteEchelle
        TEST	AX,Action
        JNZ	@SpriteAction
        TEST	AX,Frappe
        JNZ	@SpriteFrappe
        TEST	AX,Sourit
        JNZ	@SpriteSourit
        TEST	AX,Porte
        JNZ	@SpritePorte
        TEST	AX,Saute
        JNZ	@SpriteSaute
        TEST	AX,Tombe
        JNZ	@SpriteTombe
        TEST	AX,Marche
        JNZ	@SpriteMarche
        TEST	AX,Freine
        JNZ	@SpriteFreine
        MOV	BX,2
        JMP	@Suite2
@SpritePerdVie:
        TEST	AX,Saute
        JZ	@SPV0
	MOV	BX,272
        JMP	@Suite6
@SPV0:	MOV	BX,[TypeFin]
	JMP	@Suite6
@SpriteKO:
        XOR	AX,1
	TEST	AX,Saute
        JZ	@SKO0
        MOV	BX,60
        JMP	@Suite6
@SKO0:	TEST	AX,Marche
	JZ	@SKO1
        TEST	AX,Tombe
        JZ	@SKO1
        MOV	BX,61
	JMP	@Suite6
@SKO1:	MOV	BL,[CountKO]
        SHR	BL,1
	AND	BX,1
        ADD	BX,62
	JMP	@Suite6
@SpritePorte:
        TEST	AX,Saute
        JNZ	@SpriteSautePorte
        TEST	AX,Tombe
        JNZ	@SpriteTombePorte
        TEST	AX,Marche
        JNZ	@SpriteMarchePorte
        TEST	AX,Freine
        JNZ	@SpriteFreinePorte
        MOV	BX,15
        JMP	@Suite2
@SpriteEchelle:
        TEST	[Boss],$FF
        JZ	@SE0
        MOV	CX,-4
	JMP	@SE1
@SE0:   MOV	CX,-1
@SE1:	MOV	BL,[PosEchelle]
        AND	BX,3
        CMP	BL,2
        JNE	@SpriteEchelle1
	MOV	DX,-2
@SpriteEchelle1:
        ADD	BX,22
        TEST	AX,Porte
        JZ	@Suite2
        ADD	BX,3
        JMP	@Suite2
@SpriteLance:
        MOV	BX,22
	DEC	[EtatLance]
        JNZ	@Suite2
        AND	[MisterPos],NOT Lance
        JMP	@SUite2
@SpritePetit:
        TEST	AX,Marche
        JNZ	@SpritePetitMarche
        TEST	AX,Freine
        JNZ	@SpritePetitFreine
	MOV	BX,10
        JMP	@Suite2
@SpritePetitFreine:
	MOV	BX,9
        JMP	@Suite2
@SpritePetitMarche:
        TEST	[Boss],$FF
        JNZ	@SpriteRoule
        MOV	BL,[PosMarche]
        AND	BX,3
        ADD	BX,11
        JMP	@Suite2
@SpriteRoule:
        MOV	BX,[CountMarche]
        SHR	BX,3
        AND	BX,3
        ADD	BX,10
        CMP	BX,11
        JE	@SpriteRoule1
        CMP	BX,12
        JNE	@Suite2
        DEC	CX
        JMP	@Suite2
@SpriteRoule1:
	INC	DX
        JMP	@Suite2
@SpriteMarche:
        MOV	BL,[PosMarche]
        AND	BX,3
        ADD	BX,3
        JMP	@Suite2
@SpriteFreine:
        MOV	BX,1
        JMP	@Suite2
@SpriteSourit:
        MOV	BX,6
        SUB	CX,2
        JMP	@Suite2
@SpriteFrappe:
        MOV	BX,6
        JMP	@Suite2
@SpriteSaute:
        TEST	[EtatPosS1],$FF
        JZ	@SpriteTombe
        MOV	BX,7
        JMP	@Suite2
@SpriteAction:
	MOV	BX,14
        JMP	@Suite2
@SpriteTombe:
        MOV	BX,8
	JMP	@Suite2
@SpriteMarchePorte:
        MOV	BL,[PosMarche]
        AND	BX,3
        ADD	BX,17
        JMP	@Suite2
@SpriteFreinePorte:
        MOV	BX,16
        JMP	@Suite2
@SpriteSautePorte:
        TEST	[EtatPosS1],$FF
        JZ	@SpriteTombePorte
        MOV	BX,20
        JMP	@Suite2
@SpriteTombePorte:
        MOV	BX,21
@Suite2:TEST	[Boss],$F8
	JNZ	@Suite6
	TEST	[Boss],1
	JNZ	@Suite6
	ADD	BX,28
@Suite6:TEST	AX,1
	JZ	@LBL62
	NEG	CX
@LBL62:	ADD	CX,[MisterX]
        SUB	CX,[ScreenX]
        MOV	[PixelX],CX
        ADD	DX,[MisterY]
        SUB	DX,[ScreenY]
        MOV	[PixelY],DX
        TEST	AL,1
        MOV	AX,[MisterLargeur]
        CALL	@PutSprite

        { ***** Affichage des status ***** }
        TEST	[Boss],$FF
        JZ	@LBL75
        CALL	@Mute
        CMP	AX,-1
        JE	@LBL75
        MOV	DI,(80+180*320)/4
        MOV	CX,20
        MOV	DL,[Boss]
        SHR	DL,3
	XOR	DH,DH
@LoopBoss:
	MOV	AL,242
        MOV	BL,32
        CMP	DH,DL
        JB	@LB0
        INC	AL
        MOV	BL,21
@LB0:	CALL	@PutChar
        INC	DH
	LOOP	@LoopBoss
@LBL75: TEST	[StatutPerm],$FF
	JNZ	@LBL91
	MOV	BX,[KeyMrp.Statut]
	TEST	BYTE PTR [GetKey + BX],$FF
        JZ	@LBL15
        MOV	[EtatStatut],255
@LBL15: TEST	[EtatStatut],$FFFF
        JZ	@LBL14
        DEC	[EtatStatut]
        { * Affiche les sprites pour la vie et les bonnus * }
@LBL91: MOV	DI,1446
        MOV	SI,OFFSET SpriteCode
	CALL	@PutDecor
        MOV	DS,[SegmentDecor]
	MOV	DI,1504
        MOV	SI,254*256
        CALL	@PutDecor
        MOV	DS,[SegmentData]
        { * Affiche la valeur de la vie et des bonnus * }
	MOV	DI,1770
        MOV	BL,241
        MOV	AL,[Vie]
        CALL	@PutNombre
	MOV	DI,1828
        MOV	BL,241
        MOV	AL,[Bonnus]
        CALL	@PutNombre
        { * Affiche l'‚nergie * }
        MOV	DI,(96+22*320)/4
        MOV	CX,16
        MOV	DL,[Energie]
	XOR	DH,DH
@LoopEnergie:
	MOV	AL,242
        MOV	BL,241
        CMP	DH,DL
        JB	@LE0
        INC	AL
        MOV	BL,21
@LE0:	CALL	@PutChar
        INC	DH
	LOOP	@LoopEnergie
@LBL14: TEST	[StatutMessage],$FFFF
	JZ	@LBL90
        DEC	[StatutMessage]
	MOV	SI,[OffsetMessage]
        MOV	DI,65*320/4
	CALL	@PutText
@LBL90:	CMP	[Vie],-1
	JNE	@LBL99
        TEST	[MisterPos],Saute
        JNZ	@LBL99
        PUSH	[Page_not_display]
        PUSH	0
        PUSH	HautScr/2-12
        PUSH	SEG    @GameOverTxt
        PUSH    OFFSET @GameOverTxt
        PUSH	253
        PUSH	255
        PUSH	4
        CALL	BigText
@LBL99:

        { ***** Affichage … l'‚cran ***** }
	TEST	[OpenTheScreen],$FF
        JZ	@ShowScreen
        CALL	OpenScreen
        MOV	[OpenTheScreen],0
@ShowScreen:
	MOV	DX,$3DA
@WaitX0:IN	AL,DX
	TEST	AL,1
        JNZ	@WaitX0
	MOV	AX,[SegmentEcran]
        AND	AX,HautScr*5
        SHL	AX,4
        MOV	BL,AL
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
	XOR	[SegmentEcran],HautScr*5
        XOR	[Page_display],1
        XOR	[Page_not_display],1

        { ***** Bouge les couleurs ***** }
        MOV	AL,[EtatPalette1]
        INC	AL
        MOV	[EtatPalette1],AL
        TEST	AL,$07
        JNZ	@LBL19
	INC	[EtatMove]
        AND	[EtatMove],$03
@LBL19: TEST	AL,$0F
        JNZ	@LBL10
        TEST	AL,$10
        JNZ	@LBL01
        MOV	SI,OFFSET PalAnim2+24
        JMP	@LBL21
@LBL01:	MOV	SI,OFFSET PalAnim2
@LBL21: MOV	DX,$3C8
        MOV	AL,224
        OUT	DX,AL
        INC	DX
	MOV	CX,24
        REP	OUTSB
@LBL10: MOV	AL,[EtatPalette2]
        INC	AL
        MOV	[EtatPalette2],AL
        CMP	AL,20
        JE	@LBL13
        CMP	AL,30
        JE	@LBL16
        CMP	AL,10
        JNE	@LBL12
	MOV	SI,OFFSET PalAnim3
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

	TEST	BYTE PTR [GetKey+ScanVerrouille],$FF
        JZ	@NoWait
	MOV	AX,$0040
        MOV	ES,AX
        MOV	AX,ES:[$006C]
        ADD	AX,5
@WFP:   CMP	AX,ES:[$006C]
        JA	@WFP
@NoWait:

        { Teste l'entr‚e d'un code }
        XOR	BH,BH
	MOV	BL,[PosChar]
        OR	BL,BL
        JZ	@TT0
        MOV	AL,BYTE PTR [CharPress+BX]
        DEC	BL
        MOV	[PosChar],BL
        MOV	BX,[PosTriche]
        INC	AL
        CMP	AL,[BX]
        JE	@TT4
        MOV	BX,OFFSET [TxtTriche]
        CMP	AL,[BX]
        JNE     @TT0
@TT4:	INC	BX
        CMP	[BX].Byte,'õ'
        JE	@TT2
        MOV	[PosTriche],BX
        JMP	@TT0
@TT2:	TEST	[Boss],$FF
	JZ	@TT3
	MOV	[Boss],160
        JMP	@TT1
@TT3:	CALL	@Mute
@TT1:	MOV	[PosTriche],OFFSET [TxtTriche]
@TT0:

        { ***** Ralentissement ***** }
{@WaitFrame:
	TEST	[Counter],$FF
        JZ	@WaitFrame

        { Teste si le niveau est finit }
        TEST	[NiveauFinit],$FF
        JNZ	@ExitWithOutClose

        { ***** Fin de la boucle ***** }
@Fin:	MOV	BX,[KeyMrp.Menu]
        TEST	BYTE PTR [GetKey + BX],$FF
        JZ	@LoopJeu
        PUSH	[Page_display]
        PUSH	2
        CALL	PCopy
        PUSH	PendantJeu
	CALL	Menu
        MOV	AX,[ResultMenu]
        OR	AX,AX
        JNZ	@ExitGame
        IMUL	AX,[Page_not_display],HautScr*5
        OR	AX,$A000
        MOV	[SegmentEcran],AX
	JMP	@LoopJeu
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                          {³ Affiche un personnage ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@PutSprite:
        MOV	[Sens],1
        JZ	@Put7
        NEG	[Sens]
@Put7:	MOV	SI,BX { BX = num‚ro du sprite }
        SHL	SI,2
        SHL	BX,1
        XOR	DH,DH
        MOV	DL,BYTE PTR [DimSprite+BX+1] { DX = Hauteur }
        MOV	BL,BYTE PTR [DimSprite+BX]   { BX = Largeur }
        XOR	BH,BH
        TEST	[Sens],2
        JZ	@Put8
        SUB	AX,BX
        ADD	[PixelX],AX
@Put8:  MOV	[TmpW2],BX
	LDS	SI,DWORD PTR [PtrSprite+SI] { DS:SI -> Addresse du Sprite }
	MOV	AX,[PixelY]
        CMP	AX,0           { Si le sprite n'est pas sur l'‚cran }
	JL	@ExitPutSprite { alors on quitte                    }
	SUB	AX,DX
	INC	AX    { AX = Y - Hauteur + 1 }
	CMP	AX,HautScr-1   { Si le sprite n'est pas sur l'‚cran }
	JG	@ExitPutSprite { alors on quitte                    }
@Put1:  CMP	AX,0  { Test si le sprite d‚pase sur le haut }
	JGE	@Put2
	INC	AX
        ADD	SI,BX
        DEC	DX
	JMP	@Put1
@Put2:  MOV	DI,AX
        ADD	AX,DX
        DEC	AX
        SUB	AX,HautScr
        JC	@Put3 { Test si le sprite d‚passe sur le bas }
        INC	AX
        SUB	DX,AX
@Put3:  MOV	AX,DI
        SHL	AX,8
        SHL	DI,6
        ADD	DI,AX
        MOV	AX,[PixelX]
	CMP	AX,319         { Si le sprite n'est pas sur l'‚cran }
	JG	@ExitPutSprite { alors on quitte                    }
	CMP	AX,0
        JGE	@Put4
        NEG	AX
        SUB	BX,AX
        TEST	[Sens],2
        JNZ	@PutA
        ADD	SI,AX
@PutA:  XOR	AX,AX
@Put4:  ADD	DI,AX
	ADD	AX,BX
        DEC	AX
	CMP	AX,0           { Si le sprite n'est pas sur l'‚cran }
	JL	@ExitPutSprite { alors on quitte                    }
        SUB	AX,320
        JC	@Put5
        INC	AX
        SUB	BX,AX
	TEST	[Sens],2
        JZ	@Put5
        ADD	SI,AX
@Put5:  MOV	[TmpW1],DX
        TEST	[Sens],2
        JZ	@Put9
	ADD	SI,BX
        DEC	SI
@Put9:	XCHG	[TmpW2],BX
	MOV	ES,[SegmentEcran]
        MOV	CX,DI
        SHR	DI,2
        MOV	AL,$11
        MOV	DH,3
        AND	CL,DH
        SHL	AL,CL
@LoopRowSprite:
        MOV	DL,$C5
        OUT	DX,AL
        MOV	CX,[TmpW1]
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
        DEC	[TmpW2]
        JNZ	@LoopRowSprite
@ExitPutSprite:
	MOV	DS,[SegmentData]
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                {³ Fait Marcher Mister Patate vers la gauche ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@MisterMarcheGauche:
	MOV	AX,[MisterX]
	MOV	ES,[SegmentPlan01]
@LoopGauche:
		OR	AX,AX
	        JZ	@FinGauche
                MOV	BL,AL
                AND	BL,$0F
                CMP	BL,$0F
                JNE	@OkGauche
                MOV	DI,[MisterY]
                SUB	DI,[MisterHauteur]
                ADD	DI,2
                MOV	[TmpW1],DI
                AND	DI,$FFF0
	        MOV	CL,[ShiftL]
                SHL	DI,CL
                MOV	BX,AX
                SHR	BX,4
                OR	DI,BX
                MOV	BX,[TmpW1]
                AND	BX,$000F
                ADD	BX,[MisterHauteur]
                ADD	BX,13
        	SHR	BX,4
                CALL	@TestCaseV
                JC	@FinGauche
        @OkGauche:
	        DEC	AX
	        MOV	BX,[ScreenX]
                OR	BX,BX
                JZ	@SuiteGauche
	        ADD	BX,LimZone[0].Word
	        CMP	AX,BX        { Si Mister Patate est pr‚s du bord de l'‚cran }
	        JA	@SuiteGauche { on recul l'‚cran                             }
        	MOV	[MoveScrX],-1
	@SuiteGauche:
	        DEC	DX
                JNZ	@LoopGauche
@FinGauche:
	MOV	[MisterX],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                {³ Fait Marcher Mister Patate vers la droite ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@MisterMarcheDroite:
	MOV	AX,[MisterX]
        DEC	AX
        ADD	AX,[MisterLargeur]
	MOV	ES,[SegmentPlan01]
@LoopDroite:
		CMP	AX,[MaxPosX]
		JE	@FinDroite
                TEST	AL,$0F
                JNZ	@OkDroite
                MOV	DI,[MisterY]
                SUB	DI,[MisterHauteur]
                ADD	DI,2
                MOV	[TmpW1],DI
                AND	DI,$FFF0
    	        MOV	CL,[ShiftL]
                SHL	DI,CL
                MOV	BX,AX
                SHR	BX,4
                OR	DI,BX
                MOV	BX,[TmpW1]
                AND	BX,$000F
                ADD	BX,[MisterHauteur]
                ADD	BX,13
        	SHR	BX,4
                CALL	@TestCaseV
                JC	@FinDroite
        @OkDroite:
		INC	AX
		MOV	BX,[ScreenX]
                CMP	BX,[MaxScreenX]
                JE	@SuiteDroite
		ADD	BX,LimZone[2].Word
		CMP	AX,BX        { Si Mister Patate est pr‚s du bord de l'‚cran }
	        JB	@SuiteDroite { on avance l'‚cran                            }
        	MOV	[MoveScrX],1
	@SuiteDroite:
	       	DEC	DX
                JNZ	@LoopDroite
@FinDroite:
        SUB	AX,[MisterLargeur]
        INC	AX
	MOV	[MisterX],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                        {³ Fait tomber Mister Patate ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@MisterTombe:
        PUSH	SI
	MOV	AX,[MisterY]
        MOV	BX,[MisterX]
        ADD	BX,[MisterLargeur]
        DEC	BX
DB $66; SHL	BX,16
@LoopTombe:
		CMP	AX,[MaxPosY]
		JE	@FinTombe
                MOV	DI,OFFSET [ObjetY]
                MOV	CX,256
        	MOV	ES,[SegmentData]
	@LoopFindBas:
                JCXZ	@SuiteTombe1
                REPNE	SCASW
                JNE	@SuiteTombe1
                TEST	WORD PTR [DI+510],$FFFF
                JZ	@LoopFindBas
                MOV	BX,WORD PTR [DI+1022]
                TEST	BX,ObjetPerso+ObjetPris
                JNZ	@LoopFindBas
                TEST	WORD PTR [DI+3582],ObjetPiquant
                JNZ	@LFB0
		TEST	BX,ObjetTsp
                JNZ	@LoopFindBas
        @LFB0:
        DB $66; SHR	BX,16
                CMP	BX,[DI-514]
                JAE	@SuiteMisterTombe
        DB $66; SHL	BX,16
		JMP	@LoopFindBas
        @SuiteMisterTombe:
        DB $66; SHL	BX,16
                MOV	BX,[DI+2558]
                ADD	BX,[DI-514]
                CMP	BX,[MisterX]
                JB	@LoopFindBas
                TEST	WORD PTR [DI+3582],ObjetPiquant
                JZ	@FinTombe
        	MOV	[MisterY],AX
        	CALL	@FrappeMister
                XOR	DX,DX
                POP	SI
                RETN
	@SuiteTombe1:
		MOV	DI,AX
                TEST	DI,$000F
                JNZ	@OkTombe
                AND	DI,$FFF0
		MOV	CL,[ShiftL]
                SHL	DI,CL
                MOV	BX,[MisterX]
                MOV	SI,BX
                MOV	CX,[MisterLargeur]
		SHR	CX,1
	        ADD	SI,CX
                SHR	SI,4
                OR	SI,DI
                MOV	CX,BX
                INC	CX
                SHR	CX,4
                OR	DI,CX
                INC	BX
                AND	BX,$000F
                ADD	BX,[MisterLargeur]
                ADD	BX,13
        	SHR	BX,4
        	MOV	ES,[SegmentPlan01]
                CALL	@TestCaseB
                JC	@FinTombe
        @OkTombe:
		INC	AX
		MOV	BX,[ScreenY]
                CMP	BX,[MaxScreenY]
                JE	@SuiteTombe
		ADD	BX,LimZone[6].Word
		CMP	AX,BX        { Si Mister Patate est pr‚s du bord de l'‚cran }
	        JB	@SuiteTombe { on avance l'‚cran                            }
        	MOV	[MoveScrY],1
	@SuiteTombe:
	       	DEC	DX
                JNZ	@LoopTombe
@FinTombe:
	MOV	[MisterY],AX
        POP	SI
	RETN
{ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ}
          {³ Fait tomber Mister Patate sans s'ocupper des caisses ³}
{ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ}
@MisterTombeSansCaisse:
        PUSH	SI
	MOV	AX,[MisterY]
        MOV	BX,[MisterX]
        ADD	BX,[MisterLargeur]
        DEC	BX
DB $66; SHL	BX,16
       	MOV	ES,[SegmentPlan01]
@LoopTombeSC:
		CMP	AX,[MaxPosY]
		JE	@FinTombeSC
		MOV	DI,AX
                TEST	DI,$000F
                JNZ	@OkTombeSC
                AND	DI,$FFF0
		MOV	CL,[ShiftL]
                SHL	DI,CL
                MOV	BX,[MisterX]
                MOV	SI,BX
                MOV	CX,[MisterLargeur]
                SHR	CX,1
                ADD	SI,CX
                SHR	SI,4
                MOV	CX,BX
                INC	CX
                SHR	CX,4
                OR	DI,CX
                INC	BX
                AND	BX,$000F
                ADD	BX,[MisterLargeur]
                ADD	BX,13
        	SHR	BX,4
                CALL	@TestCaseB
                JC	@FinTombeSC
        @OkTombeSC:
		INC	AX
		MOV	BX,[ScreenY]
                CMP	BX,[MaxScreenY]
                JE	@SuiteTombeSC
		ADD	BX,LimZone[6].Word
		CMP	AX,BX        { Si Mister Patate est pr‚s du bord de l'‚cran }
	        JB	@SuiteTombeSC { on avance l'‚cran                            }
        	MOV	[MoveScrY],1
	@SuiteTombeSC:
	       	DEC	DX
                JNZ	@LoopTombeSC
@FinTombeSC:
	MOV	[MisterY],AX
        POP	SI
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                        {³ Fait sauter Mister Patate ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@MisterSaute:
	MOV	AX,[MisterY]
        SUB	AX,[MisterHauteur]
        INC	AX
	MOV	ES,[SegmentPlan01]
@LoopSaute:
                OR	AX,AX
		JZ	@FinSaute
		MOV	DI,AX
                MOV	BX,DI
                AND	BL,$0F
                CMP	BL,$0F
                JNE	@OkSaute
                AND	DI,$FFF0
		MOV	CL,[ShiftL]
                SHL	DI,CL
                MOV	BX,[MisterX]
                INC	BX
                SHR	BX,4
                OR	DI,BX
                MOV	BX,[MisterX]
                INC	BX
                AND	BX,$000F
                ADD	BX,[MisterLargeur]
                ADD	BX,13
        	SHR	BX,4
                CALL	@TestCaseH
                JC	@FinSaute
        @OkSaute:
		DEC	AX
		TEST	[EtatPosS1],$FF
        	JZ	@SuiteD
        	DEC	[EtatPosS1]
	@SuiteD:MOV	BX,[ScreenY]
                OR	BX,BX
                JZ	@SuiteSaute
		ADD	BX,LimZone[4].Word
		CMP	AX,BX        { Si Mister Patate est pr‚s du bord de l'‚cran }
	        JA	@SuiteSaute  { on avance l'‚cran                            }
        	MOV	[MoveScrY],-1
	@SuiteSaute:
	       	DEC	DX
                JNZ	@LoopSaute
@FinSaute:
        DEC	AX
        ADD	AX,[MisterHauteur]
	MOV	[MisterY],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                         {³ Test une case             ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestBonnusCase:
        CMP	CL,6
        JNE	@CaseBE
        AND	CH,56
        CMP	CH,56
	JNE	@CaseB1
        MOV	[NiveauFinit],1
	JMP	@CaseBE
@CaseB1:MOV	ES:BYTE PTR [DI],0
        MOV	ES,[SegmentPlan23]
	MOV	ES:BYTE PTR [DI],0
        MOV	ES,[SegmentPlan01]
        OR	CH,CH
	JNZ	@CaseB3
	CALL	@Bonnus
	JMP	@CaseBE
@CaseB3:CMP	CH,8
	JNE	@CaseB4
        PUSH	SI
        MOV	SI,OFFSET [MusicVie]
        CALL	@Music
        POP	SI
	INC	[Vie]
        MOV	[EtatStatut],255
	JMP	@CaseBE
@CaseB4:CMP	CH,24
	JNE	@CaseB5
        PUSH	AX
        MOV	AX,[MisterX]
	MOV	[FirstPosX],AX
        MOV	AX,[MisterY]
	MOV	[FirstPosY],AX
        POP	AX
        PUSH	SI
        MOV	SI,OFFSET [MusicCadenas]
        CALL	@Music
	POP	SI
	JMP	@CaseBE
@CaseB5:CMP	CH,16
	JNE	@CaseB6
        TEST	[Boss],$FF
        JNZ	@CaseBE
        PUSH	SI
        MOV	SI,OFFSET [MusicBoss]
        CALL	@Music
	POP	SI
        CALL	@Mute
	JMP	@CaseBE
@CaseB6:CMP	CH,32
	JNE	@CaseB7
	PUSHA
        MOV	SI,OFFSET [MusicCode]
        CALL	@Music
	CALL    ShowCode
        MOV	ES,[SegmentPlan01]
        POPA
        JMP	@CaseBE
@CaseB7:CMP	CH,48
	JNE	@CaseBE
        INC	[SuperBonnus]
@CaseBE:RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                         {³ Test une case vers le bas ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestCaseB:
	MOV	CH,ES:[DI]
        MOV	CL,CH
	AND	CL,7
        JZ	@CaseB9 { Si c'est une case 0, on passe }
        TEST	CH,128
	JZ	@CaseBB
	CMP	CL,2
        JE	@CaseB9
	AND	CH,127
        MOV	ES:[DI],CH
@CaseBB:CMP	CL,2
	JA	@CaseB2
        TEST	CH,32
        JNZ	@CaseB9
	OR	BH,8 { (Bit 3 = 1) => il y a un mur }
        CMP	CL,2
        JE	@CaseB9
        TEST	CH,16
        JZ	@CaseB9
        OR	BH,16
	JMP	@CaseB9
@CaseB2:CMP	CL,3
	JNE	@CaseBA
        CMP	SI,DI
        JNE	@CaseB9
        TEST	[MisterPos],KO
	OR	BH,8
	JMP	@CaseB9
@CaseBA:CMP	CL,7
	JNE	@CaseBD
	OR	BH,4
        JMP	@CaseB9
@CaseBD:CALL	@TestBonnusCase
@CaseB9:INC	DI { augmente l'offset d'une colone }
	DEC	BL { Ligne suivante }
	JNZ	@TestCaseB
	TEST	BH,16
        JZ	@CaseBY
	MOV	[Glisse],1
        STC
	RETN
@CaseBY:TEST	BH,8
        JZ	@CaseBZ
        STC
	RETN
@CaseBZ:TEST	BH,4
	JNZ	@CaseAie
	RETN
@CaseAie:
        PUSH	AX
        MOV	[Energie],0
        CALL	@FrappeMister
        POP	AX
        XOR	DX,DX
        STC
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                         {³ Test une case vers le haut ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestCaseH:
	MOV	CH,ES:[DI]
        MOV	CL,CH
	AND	CL,7
        JZ	@CaseH9 { Si c'est une case 0, on passe }
        TEST	CH,128
	JZ	@CaseHB
	CMP	CL,2
        JE	@CaseH9
        CMP	CL,1
        JNE	@CaseH1
	TEST	CH,8
        JNZ	@CaseH9
@CaseH1:AND	CH,127
        MOV	ES:[DI],CH
@CaseHB:CMP	CL,2
	JA	@CaseH2
        JE	@CaseH3
	TEST	CH,8
        JNZ	@CaseH9
@CaseH3:OR	BH,8 { (Bit 3 = 1) => il y a un mur }
	JMP	@CaseH9
@CaseH2:CMP	CL,7
	JNE	@CaseHD
        TEST	CH,8
        JNZ     @CaseH9
        OR	BH,4
	JMP	@CaseH9
@CaseHD:CALL	@TestBonnusCase
@CaseH9:INC	DI { augmente l'offset d'une colone }
	DEC	BL { Ligne suivante }
	JNZ	@TestCaseH
	TEST	BH,8
        JZ	@CaseHZ
        STC
        RETN
@CaseHZ:TEST	BH,4
	JNZ	@CaseAie
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                        {³ Test des cases verticalement ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestCaseV:
	MOV	CH,ES:[DI]
        MOV	CL,CH
	AND	CL,7
        JZ	@CaseV9 { Si c'est une case 0, on passe }
        TEST	CH,128
	JZ	@CaseVB
	CMP	CL,2
        JE	@CaseV9
        CMP	CL,1
        JNE	@CaseV1
	TEST	CH,8
        JNZ	@CaseV9
@CaseV1:AND	CH,127
        MOV	ES:[DI],CH
@CaseVB:CMP	CL,2
	JA	@CaseV2
        JE	@CaseV3
	TEST	CH,8
        JNZ	@CaseV9
@CaseV3:OR	BH,8 { (Bit 3 = 1) => il y a un mur }
	JMP	@CaseV9
@CaseV2:CMP	CL,7
	JNE	@CaseVD
        TEST	CH,8
        JNZ     @CaseV9
	OR	BH,4
        JMP	@CaseV9
@CaseVD:CALL	@TestBonnusCase
@CaseV9:ADD	DI,[Next] { augmente l'offset d'une colone }
	DEC	BL        { Ligne suivante }
	JNZ	@TestCaseV
	TEST	BH,8
        JZ	@CaseVZ
        STC
	RETN
@CaseVZ:TEST	BH,4
	JNZ	@CaseAie
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                            {³ Augmente les bonnus ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@Bonnus:PUSH	SI
        MOV	SI,OFFSET [MusicPiece]
        CALL	@Music
        POP	SI
	MOV	[EtatStatut],255
	CMP	[Energie],16
        JE	@IncBonnus
        INC	[Energie]
        RETN
@IncBonnus:
	INC	[Bonnus]
        CMP	[Bonnus],16
        JNE	@ExitBonnus
        MOV	[Bonnus],0
        INC	[Vie]
@ExitBonnus:
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                           {³ Change les dimmensions ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@SetDim:TEST	[Boss],$FF
        JNZ	@LBL26
	ADD	BX,28
@LBL26: SHL	BX,1
	XOR	AH,AH
        MOV	AL,BYTE PTR [DimSprite+1+BX]
        MOV	[MisterHauteur],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                {³ Fait Marcher un objet vers la gauche      ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@ObjetGauche:
	MOV	AX,WORD PTR [ObjetX+SI]
	MOV	ES,[SegmentPlan01]
	MOV	CL,[ShiftL]
@LoopObjetGauche:
		OR	AX,AX
	        JZ	@FinObjetGauche
                MOV	BL,AL
                AND	BL,$0F
                CMP	BL,$0F
                JNE	@OkObjetGauche
                MOV	DI,WORD PTR [ObjetY+SI]
                INC	DI
                MOV	[TmpW1],DI
                AND	DI,$FFF0
                SHL	DI,CL
                MOV	BX,AX
                SHR	BX,4
                OR	DI,BX
                MOV	BX,[TmpW1]
                AND	BX,$000F
                ADD	BX,WORD PTR [ObjetVSize+SI]
                ADD	BX,13
        	SHR	BX,4
        @LoopTestCaseObjetGauche:
                MOV	CH,ES:[DI]
                TEST	CH,128
                JNZ	@EndTestCaseObjetGauche
                MOV	BH,CH
        	AND	CH,7
                CMP	CH,2
                JE	@FinObjetGauche
                CMP	CH,1
                JNE	@EndTestCaseObjetGauche
                TEST	BH,8
                JZ	@FinObjetGauche
        @EndTestCaseObjetGauche:
                ADD	DI,[Next]
        	DEC	BL
                JNZ	@LoopTestCaseObjetGauche
		MOV	CH,ES:[DI]
                AND	CH,7
                CMP	CH,7
                JE	@OG3
        	TEST	WORD PTR [ObjetAttr2+SI],ObjetPeurVide
                JZ	@OkObjetGauche
                TEST    ObjetAttr[SI].Word,Tombe
                JNZ	@OkObjetGauche
        	OR	CH,CH
                JNZ	@OkObjetGauche
        @OG3:	AND	WORD PTR [ObjetAttr+SI],$FFFE
        @OkObjetGauche:
	        DEC	AX
                INC	BYTE PTR [ObjetStatut+SI]
                MOV	BL,BYTE PTR [ObjetStatut+SI]
                TEST	BL,3
                JNZ	@OG0
                SHR	BL,2
                AND	BL,15
                CMP	BL,5
                JE	@OG1
                CMP	BL,13
                JNE	@OG0
        @OG1:	MOV	[TmpB1],1
        @OG0:   DEC	DX
                JNZ	@LoopObjetGauche
@FinObjetGauche:
	MOV	WORD PTR [ObjetX+SI],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                {³ Fait Marcher un objet vers la droite      ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@ObjetDroite:
	MOV	AX,WORD PTR [ObjetX+SI]
        DEC	AX
        ADD	AX,WORD PTR [ObjetHSize+SI]
	MOV	ES,[SegmentPlan01]
	MOV	CL,[ShiftL]
@LoopObjetDroite:
		CMP	AX,[MaxPosX]
		JE	@FinObjetDroite
                TEST	AL,$0F
                JNZ	@OkObjetDroite
                MOV	DI,WORD PTR [ObjetY+SI]
                INC	DI
                MOV	[TmpW1],DI
                AND	DI,$FFF0
                SHL	DI,CL
                MOV	BX,AX
                SHR	BX,4
                OR	DI,BX
                MOV	BX,[TmpW1]
                AND	BX,$000F
                ADD	BX,WORD PTR [ObjetVSize+SI]
                ADD	BX,13
        	SHR	BX,4
        @LoopTestCaseObjetDroite:
                MOV	CH,ES:[DI]
                TEST	CH,128
                JNZ	@EndTestCaseObjetDroite
                MOV	BH,CH
        	AND	CH,7
                CMP	CH,2
                JE	@FinObjetDroite
                CMP	CH,1
                JNE	@EndTestCaseObjetDroite
                TEST	BH,8
                JZ	@FinObjetDroite
        @EndTestCaseObjetDroite:
                ADD	DI,[Next]
        	DEC	BL
                JNZ	@LoopTestCaseObjetDroite
		MOV	CH,ES:[DI]
                AND	CH,7
                CMP	CH,7
                JE	@OD3
        	TEST	WORD PTR [ObjetAttr2+SI],ObjetPeurVide
                JZ	@OkObjetDroite
                TEST    ObjetAttr[SI].Word,Tombe
                JNZ	@OkObjetDroite
        	OR	CH,CH
                JNZ	@OkObjetDroite
        @OD3:	OR	WORD PTR [ObjetAttr+SI],1
        @OkObjetDroite:
		INC	AX
                INC	BYTE PTR [ObjetStatut+SI]
		MOV	BL,BYTE PTR [ObjetStatut+SI]
                TEST	BL,3
                JNZ	@OD0
                SHR	BL,2
                AND	BL,15
                CMP	BL,5
                JE	@OD1
                CMP	BL,13
                JNE	@OD0
        @OD1:	MOV	[TmpB1],1
        @OD0:   DEC	DX
                JNZ	@LoopObjetDroite
@FinObjetDroite:
        SUB	AX,WORD PTR [ObjetHSize+SI]
        INC	AX
	MOV	WORD PTR [ObjetX+SI],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                        {³ Fait tomber un objet      ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@ObjetTombe:
        MOV	AX,WORD PTR [ObjetVSize+SI]
        DEC	AX
        ADD	AX,WORD PTR [ObjetY+SI]
        MOV	BX,WORD PTR [ObjetHSize+SI]
        MOV	[TmpW2],BX
        MOV	CX,WORD PTR [ObjetX+SI]
        ADD	BX,CX
        MOV	[TmpW1],CX
        DEC	BX
DB $66; SHL	BX,16
@LoopTombeObjet:
		CMP	AX,[MaxPosY]
		JE	@FinTombeObjet
                TEST	WORD PTR [ObjetAttr],ObjetPerso
                JNZ	@SuiteTombeObjet1
                MOV	DI,OFFSET [ObjetY]
                MOV	CX,256
        	MOV	ES,[SegmentData]
	@LoopFindBasObjet:
                OR	CX,CX
                JZ	@SuiteTombeObjet1
                REPNE	SCASW
                JNE	@SuiteTombeObjet1
                TEST	WORD PTR [DI+510],$FFFF
                JZ	@LoopFindBasObjet
                MOV	BX,WORD PTR [DI+1022]
                TEST	BX,ObjetPerso+ObjetPris+ObjetTsp
                JNZ	@LoopFindBasObjet
                CMP	[DI+5118].Word,OFFSET @Ascenseur
                JE      @LoopFindBasObjet
        DB $66; SHR	BX,16
                CMP	BX,[DI-514]
                JAE	@SuiteTombeObjet
        DB $66; SHL	BX,16
		JMP	@LoopFindBasObjet
        @SuiteTombeObjet:
        DB $66; SHL	BX,16
                MOV	BX,[DI+510]
                SHL	BX,1
                MOV	BL,BYTE PTR [DimSprite+BX]
                XOR	BH,BH
                ADD	BX,[DI-514]
                CMP	BX,[TmpW1]
                JB	@LoopFindBasObjet
        	JMP	@FinTombeObjet
	@SuiteTombeObjet1:
		MOV	DI,AX
                TEST	DI,$000F
                JNZ	@OkTombeObjet
	        AND	DI,$FFF0
		MOV	CL,[ShiftL]
                SHL	DI,CL
                MOV	BX,[TmpW1]
                INC	BX
                SHR	BX,4
                OR	DI,BX
                MOV	BX,[TmpW1]
                INC	BX
                AND	BX,$000F
                ADD	BX,[TmpW2]
                ADD	BX,13
        	SHR	BX,4
        	MOV	ES,[SegmentPlan01]
        @LoopTestCaseObjet:
                MOV	CH,ES:[DI]
                TEST	CH,128
                JNZ	@EndTestCaseObjet
                TEST	CH,64
                JZ	@LTCO0
                AND	CH,7
                CMP	CH,7
                JNE	@LTCO1
                MOV	BH,1
        	JMP	@EndTestCaseObjet
        @LTCO0:	AND	CH,7
        @LTCO1:	CMP	CH,7
                JE	@FinTombeObjet
                CMP	CH,2
                JE	@FinTombeObjet
                CMP	CH,1
                JE	@FinTombeObjet
        @EndTestCaseObjet:
                INC	DI
        	DEC	BL
                JNZ	@LoopTestCaseObjet
                OR	BH,BH
                JZ	@OkTombeObjet
                ADD	SP,2
                JMP	@DelObjet
        @OkTombeObjet:
		INC	AX
	       	DEC	DX
                JNZ	@LoopTombeObjet
@FinTombeObjet:
        SUB	AX,WORD PTR [ObjetVSize+SI]
        INC	AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                        {³ Annime les pas de mister  ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@IncMarche:
	INC	[CountMarche]   { Incr‚mente les compteurs }
        INC	[CountMarche1]  { pour le faire bouger     }
        MOV	AX,[CountMarche1]
        MOV	BL,7
        TEST	[PosMarche],1 { Position 1 dure moins longtemps }
        JNZ	@LBL00
        MOV	BL,11
@LBL00:	CMP	AL,BL
        JB	@IM2
        MOV	[CountMarche1],0
        ROL	[PosMarche],2 { Position suivante }
	CMP	BL,11
        JNE	@IM2
        TEST	[MisterPos],Saute+Tombe
        JNZ	@IM2
        TEST	[MisterPos],Petit
        JZ	@IM0
        TEST	[Boss],$FF
        JNZ	@IM2
        MOV	BX,$0700
        JMP	@IM1
@IM0:   MOV	BX,$0709
@IM1:   CALL	@Sound
@IM2:	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Renvoie le premier objet vide ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@GetFreeObjet:
        MOV	AX,DS
        MOV	ES,AX
        MOV	DI,OFFSET [ObjetSprite]
        MOV	CX,256
        XOR	AX,AX
        REPNE	SCASW
        JNE     @FinTestObjet
        SUB	DI,OFFSET [ObjetSprite]+2
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Affiche un charactŠre         ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@PutChar:
        PUSH    CX
        PUSH	DX
        PUSH	SI
        XOR	AH,AH
	MOV	SI,AX
        MOV	ES,[SegmentEcran]
	SHL	SI,3
        ADD	SI,OFFSET [Police8x8]
	MOV	CX,8
        MOV	DX,$3C5
@LoopLineChar:
        LODSB
        OUT	DX,AL
	MOV	ES:[DI],BL
        INC	DI
        SHR	AL,4
        OUT	DX,AL
	MOV	ES:[DI],BL
        CMP	BL,252
        JB	@PC0
	DEC	BL
        OR	BL,$FC
@PC0:   ADD	DI,79
        LOOP	@LoopLineChar
        SUB	DI,638
        POP	SI
        POP	DX
        POP     CX
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Affiche un nombre             ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@PutNombre:
        MOV	DX,AX
	MOV	AL,'x'
        CALL	@PutChar
        MOV	AX,DX
        CMP	AL,100
        JB	@PN0
	MOV	AL,'-'
        CALL	@PutChar
	MOV	AL,'-'
        CALL	@PutChar
	RETN
@PN0:	XOR	AH,AH
        MOV	DX,10
        DIV	DL
        ADD	AX,'00'
        MOV     DL,AH
        CALL	@PutChar
        MOV	AL,DL
        CALL	@PutChar
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Affiche un texte              ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@PutText:
        MOV	AX,[LengthMessage]
        MOV	CX,AX
        ADD	DI,40
        SUB	DI,AX
@LoopText:
	MOV	BL,255
	LODSB
        CALL	@PutChar
        LOOP	@LoopText
        MOV	DS,[SegmentData]
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Affiche un d‚cor              ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@PutDecor:
        MOV	ES,[SegmentEcran]
        MOV	AL,$11
	MOV	CH,16
        MOV	DX,$3C5
@LoopLineStatut:
        MOV	CL,16
	OUT	DX,AL
@LoopPixelStatut:
        MOV	BL,[SI]
        OR	BL,BL
        JZ	@PPS0
	MOV	ES:[DI],BL
@PPS0:  ADD	DI,80
        ADD	SI,16
        DEC	CL
        JNZ	@LoopPixelStatut
        SUB	SI,255
        ROL	AL,1
        CMC
        SBB	DI,80*16-1
        DEC	CH
        JNZ	@LoopLineStatut
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Transforme mister patate      ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@Mute:  TEST	[Boss],$FF
        JNZ	@Mute0
	MOV	[Boss],160
        MOV	[Transforme],128
        MOV	[StatutMessage],50
        PUSH	BX
        XOR	BX,BX
        CALL	@SetMessage
      	MOV	BX,WORD PTR [DimSprite + 4]
        MOV	BYTE PTR [MisterHauteur],BH
        AND	[MisterPos],NOT Petit
        CALL	@LacheObjet
        POP	BX
	RETN
@Mute0: MOV	AX,[Transforme]
	OR	AX,AX
        JZ	@Mute1
        CMP	AX,39
        JNE	@Mute4
        MOV	[StatutMessage],300
        MOV	BX,1
	CALL	@SetMessage
@Mute4:	CMP	AX,1
        MOV	AX,-1
        JNE	@Mute2
        MOV	[CountBoss],15
	RETN
@Mute1: MOV	AL,[Boss]
	DEC	[CountBoss]
        JNZ	@Mute2
        DEC	AL
        MOV	[Boss],AL
	MOV	[CountBoss],15
	OR	AL,AL
        JNZ	@Mute2
        MOV	[StatutMessage],200
        MOV	BX,2
	CALL	@SetMessage
      	MOV	AX,WORD PTR [DimSprite + 4+28*2]
        MOV	BYTE PTR [MisterLargeur],AL
        MOV	BYTE PTR [MisterHauteur],AH
        AND	[MisterPos],NOT Petit
	MOV	AX,-1
@Mute2: RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                  {³ Renvoie la distance de mister … un objet ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@GetDist:
        XOR	DI,DI
	MOV	AX,[MisterX]
        SUB	AX,WORD PTR [ObjetX+SI]
        SHL	AX,1
        MOV	BX,[MisterLargeur]
        MOV	CX,WORD PTR [ObjetHSize+SI]
	ADD	AX,BX
        SUB	AX,CX
        JNS	@GD0
        NEG	AX
	MOV	DI,1
@GD0:	SHR	AX,1
        ADD	BX,CX
        SHR	BX,1
	MOV	CX,[MisterY]
        SUB	CX,WORD PTR [ObjetY+SI]
        SHL	CX,1
        MOV	DX,[MisterHauteur]
        ADD	DX,WORD PTR [ObjetVSize+SI]
	SUB	CX,DX
        JNS	@GD1
        NEG	CX
	OR	DI,2
@GD1:	SHR	CX,1
        SHR	DX,1
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                  {³ Renvoie la distance d'un objet … un objet ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@GetDistObjet:
        MOV	[TmpB2],0
	MOV	AX,WORD PTR [ObjetX+DI]
        SUB	AX,WORD PTR [ObjetX+SI]
        SHL	AX,1
        MOV	BX,WORD PTR [ObjetHSize+DI]
        MOV	CX,WORD PTR [ObjetHSize+SI]
	ADD	AX,BX
        SUB	AX,CX
        JNS	@GDO0
        NEG	AX
        MOV	[TmpB2],1
@GDO0:	SHR	AX,1
        ADD	BX,CX
        SHR	BX,1
	MOV	CX,WORD PTR [ObjetY+DI]
        SUB	CX,WORD PTR [ObjetY+SI]
        SHL	CX,1
        PUSH	AX
        MOV	DX,WORD PTR [ObjetVSize+DI]
        MOV	AX,WORD PTR [ObjetVSize+SI]
	ADD	CX,DX
        SUB	CX,AX
        JNS	@GDO1
        NEG	CX
        OR	[TmpB2],2
@GDO1:	SHR	CX,1
	ADD	DX,AX
        SHR	DX,1
        POP	AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Active un message             ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@SetMessage:
        PUSH	ES
        PUSH	DI
        PUSH	CX
        PUSH	AX
        MOV	DI,DS
        MOV	ES,DI
        MOV	DI,OFFSET [Message]
	MOV	CX,256
	MOV	AL,'õ'
@SM0:	OR	BX,BX
	JZ	@SM1
        REPNE	SCASB
        DEC	BX
        JMP	@SM0
@SM1:   MOV	[OffsetMessage],DI
	REPNE	SCASB
        SUB	DI,[OffsetMessage]
        DEC	DI
        MOV	[LengthMessage],DI
        POP	AX
        POP	CX
        POP	DI
        POP	ES
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Active un message             ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@SetRandomMessage:
        PUSH	AX
        PUSH	ES
        MOV	AX,$0040
        MOV	ES,AX
        MOV	AL,ES:[$006C]
        AND	AL,BH
        ADD	BL,AL
        XOR	BH,BH
        PUSH	BX
        CALL    @SetMessage
        POP	BX
        POP	ES
        POP	AX
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Active un objet               ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@CreateObjetTire:
        CALL	@GetFreeObjet { Demande un objet }
        MOV	WORD PTR [ObjetSprite+DI],BX { Fixe son sprite }
        SHL	BX,1
        XOR	AH,AH
        MOV	AL,BYTE PTR [DImSprite+BX]  { fixe ses dimmensions }
        MOV	WORD PTR [ObjetHSize+DI],AX
        MOV	AL,BYTE PTR [DImSprite+1+BX]
        MOV	WORD PTR [ObjetVSize+DI],AX
        MOV	CX,WORD PTR [ObjetAttr+SI] { fixe ses attributs }
        AND	CX,1
        OR	CX,ObjetTsp+ObjetTire
        MOV	WORD PTR [ObjetAttr+DI],CX
        MOV	AX,WORD PTR [ObjetY+SI] { fixe sa position }
        MOV	BX,WORD PTR [ObjetVSize+SI]
        SUB	BX,WORD PTR [ObjetVSize+DI]
        SHR	BX,1
        ADD	BX,AX
        MOV	AL,DL
        CBW
        ADD	BX,AX
        MOV	WORD PTR [ObjetY+DI],BX
        MOV	BX,WORD PTR [ObjetX+SI]
        MOV	AL,DH
        CBW
        TEST	CX,1
        JZ	@COT0
        SUB	BX,WORD PTR [ObjetHSize+DI]
        SUB	BX,AX
        JMP	@COT1
@COT0:	ADD	BX,WORD PTR [ObjetHSize+SI]
	ADD	BX,AX
@COT1:  MOV	WORD PTR [ObjetX+DI],BX
	MOV	ObjetProc[DI].Word,OFFSET @VoleObjet
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Frappe mister patate          ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@FrappeMister:
        TEST	[MisterPos],PerdVie
        JNZ	@FM0
	TEST	[Boss],$FF
        JNZ	@FM0
        { Si mister n'est pas le boss, on lui fait mal }
{        MOV	[OfsSon],OFFSET [SonAie]}
        CALL	@LacheObjet
        MOV	[StatutMessage],100
        MOV	BX,$0107
        CALL	@SetRandomMessage
	MOV	[EtatStatut],255
        { Pr‚pare le sursaut de mister patate }
        MOV	[CountKO],100
        MOV	[SautForce],1
        MOV	[EtatSaute],0
        MOV	[MaxSaut],30
        MOV	[Amplitude],15
        MOV	AX,DI
        AND	AX,1
        TEST    [MisterPos],Petit
        JZ	@FM1
        PUSH	AX
	MOV	BX,1
        CALL	@SetDim
        POP	AX
@FM1:	OR	AX,KO+Saute+Marche
	{ Diminue l'‚nnergie de mister patate }
	MOV	[MisterPos],AX
        MOV	AL,[Energie]
        OR	AL,AL
        JNZ	@FM5
        DEC	[Vie]
        OR	[MisterPos],PerdVie
        MOV	[EtatSaute],60
	MOV	[PosChar],0
	MOV	[EtatStatut],-1
@FM5:	DEC	AL
	MOV	[Energie],AL
@FM0:	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Lache l'objet qu'il porte     ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@LacheObjet:
        TEST	[MisterPos],Porte { SI Mister porte un objet }
        JZ	@LO1              { alors il le lache        }
        MOV	BX,$FFFF
        XCHG	[ObjetPorte],BX
        AND	WORD PTR [ObjetAttr+BX],NOT ObjetPris
        AND	[MisterPos],NOT Porte
        CMP	ObjetSprite[BX].Word,73
        JNE	@LO0
        MOV	ObjetProc[BX].Word,OFFSET @MarcheurTombeKO
	RETN
@LO0:	MOV	ObjetProc[BX].Word,OFFSET @Caisse
@LO1:	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Test si un objet frappe       ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestObjetDelEnnemi:
        MOV	AX,DS
        MOV	ES,AX
        MOV	DI,OFFSET [ObjetSprite]
        MOV	CX,256
@TODE1: XOR	AX,AX
	REPE	SCASW
        JE	@TODE3
        PUSH	CX
        SUB	DI,OFFSET [ObjetSprite]+2
        TEST	WORD PTR [ObjetAttr+DI],ObjetPerso
        JZ	@TODE2
        TEST	WORD PTR [ObjetAttr2+DI],ObjetKO
        JNZ	@TODE2
        CALL	@GetDistObjet
        TEST	[TmpB1],$FF
        JZ      @TODE4
        TEST	[TmpB2],2
        JZ	@TODE2
	MOV	BX,WORD PTR [ObjetHSize+SI]
        SHR	BX,1
        CMP	AX,BX
        JA	@TODE2
        JMP	@TODE5
@TODE4:	CMP	AX,BX
        JA	@TODE2
@TODE5:	CMP	CX,DX
        JA	@TODE2
	OR	WORD PTR [ObjetAttr+DI],Saute
        OR	WORD PTR [ObjetAttr2+DI],ObjetKO
        MOV	WORD PTR [ObjetStatut+DI],0
        MOV	WORD PTR [ObjetElan+DI],-1
        XCHG	DI,SI
        CALL	@GetSpriteObjet
        XCHG	DI,SI
        MOV	ObjetSprite[DI].Word,BX
        MOV	ObjetProc[DI].Word,OFFSET @PersoSauteKO
        MOV	ObjetGetSp[DI].Word,OFFSET @Default
        POP	CX
        STC
	RETN
@TODE2: ADD	DI,OFFSET [ObjetSprite]+2
	POP	CX
        OR	CX,CX
        JNZ	@TODE1
@TODE3: CLC
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ suprime un objet              ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@DeletteObjet:
        LEA	DI,WORD PTR [ObjetX+BX]
        MOV	AX,DS
        MOV	ES,AX
        MOV	CX,11
	XOR	AX,AX
@LoopDelObjet:
	STOSW
        ADD	DI,510
        LOOP	@LoopDelObjet
        MOV	ObjetProc[SI].Word,OFFSET @FinTestObjet
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Fait grandir mister patate    ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@MisterGrandit:
        TEST	[MisterPos],Petit
        JZ      @MG0
        PUSH	AX
        MOV	BX,1
        CALL	@SetDim
        POP	AX
	AND	[MisterPos],NOT Petit
@MG0:	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                      {³ Bouge sur une ‚chelle         ³}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@IncEchelle:
        MOV	[MisterX],AX
	MOV	AL,[CountEchelle]
        INC	AL
        TEST	AL,4
        JZ	@TME7
        ROL	[PosEchelle],2
        XOR	AL,AL
        CMP	[PosEchelle],01101110B
        JNE	@TME7
        PUSH	BX
        MOV	BX,$070A
        CALL	@Sound
        POP	BX
@TME7:  MOV	[CountEchelle],AL
	MOV	DX,1
        OR	[MisterPos],Bouge
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                    {³ Centre l'‚cran sur mister        ³
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@CenterScreen:
        MOV	AX,[MisterX]
        MOV	BX,[MisterLargeur]
        SHR	BX,1
        ADD	AX,BX
        SUB	AX,160
        JNC	@Init1
        XOR	AX,AX
@Init1: CMP	AX,[MaxScreenX]
	JNA	@Init2
        MOV	AX,[MaxScreenX]
@Init2: MOV	[ScreenX],AX
        MOV	AX,[MisterY]
        MOV	BX,[MisterHauteur]
        SHR	BX,1
        ADD	AX,BX
        SUB	AX,HautScr/2
        JNC	@Init3
        XOR	AX,AX
@Init3: CMP	AX,[MaxScreenY]
	JNA	@Init4
        MOV	AX,[MaxScreenY]
@Init4: MOV	[ScreenY],AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                    {³ Lance un nouvel effet sonore     ³
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@Sound:	PUSH	AX
        MOV	AL,[SonOn]
        OR	AL,[SoundEnable]
	JZ	@SND3
	PUSH	DX
        PUSH	CX
        MOV	DX,$388
        MOV	AL,BH
        OR	AL,$A0
        XOR	AH,AH
        CALL	@SND0
        OR	AL,$10
        CALL	@SND0
        MOV	AH,BL
        AND	AH,$F0
        SHR	AH,2
        AND	BX,$000F
        SHL	BX,1
        MOV	BX,WORD PTR [NoteFreq+BX]
        OR	BH,AH
        AND	AL,$AF
        MOV	AH,BL
        CALL	@SND0
        MOV	AH,BH
        OR	AL,$10
        CALL	@SND0
        POP	CX
        POP	DX
@SND3:	POP	AX
	RETN
@SND0:  PUSH	AX
	OUT	DX,AL
        MOV	CX,5
@SND1:  IN	AL,DX
	LOOP	@SND1
	MOV	AL,AH
        INC	DX
        OUT	DX,AL
        MOV	CL,35
	DEC	DX
@SND2:	IN	AL,DX
	LOOP	@SND2
        POP	AX
        RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                    {³ Lance une musique                ³
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@Music: PUSH	AX
	MOV	[BonnusMusic.EnAble],0
        MOV	[CounterSound],1
        LODSB
        MOV	[BonnusMusic.Pas],AL
	MOV	[BonnusMusic.OfsSound],SI
        MOV	[BonnusMusic.EnAble],1
@M0:    POP	AX
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                    {³ Proc‚dure de gestion des objets  ³
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestObjetTombe:
        TEST	ObjetAttr[SI].Word,Tombe
        JNZ	@ObjetTombeOk
	MOV	DX,1        { Sinon on test s'il peut tomber }
        CALL	@ObjetTombe { On le fait tomber de 1 }
        OR	DX,DX	    { Si la boucle n'est pas termin‚ }
        JZ     	@TOT0       { Il ne peut pas tomber }
        TEST	ObjetAttr[SI].Word,ObjetStop
	JZ	@RETURN { Fait atterir l'objet dans une gerbe de poussiŠre }
        CMP	BYTE PTR [ObjetStatut+1+SI],11
        JB	@LBL39
	AND	WORD PTR [ObjetAttr+SI],NOT ObjetStop
	RETN
@LBL39: INC	BYTE PTR [ObjetStatut+1+SI]
	RETN
@TOT0:  MOV	BYTE PTR [ObjetStatut+1+SI],0
        AND	ObjetAttr[SI].Word,NOT ObjetStop
	OR	WORD PTR [ObjetAttr+SI],Tombe
@ObjetTombeOk: { Fait tomber l'objet }
	MOV	DL,BYTE PTR [ObjetStatut+1+SI]
        INC	DL                            { Incr‚mente l'‚tat du saut }
        JNZ	@LBL36                        { si il n'est pas … son     }
	MOV	DL,255                        { maximum                   }
@LBL36: MOV	BYTE PTR [ObjetStatut+1+SI],DL
	XOR	DH,DH  { calcul le nombre de pixel  }
        SHL	DX,1   { duquel doit tomber l'objet }
        INC	DX
        SHR	DX,4
	OR	DX,DX
        JZ      @RETURN
        CALL	@ObjetTombe { Fait tomber l'objet de DX pixel }
	MOV	WORD PTR [ObjetY+SI],AX
        TEST	WORD PTR [ObjetAttr+SI],ObjetPerso
        JNZ	@OTO0
        PUSH	DX
        MOV	[TmpB1],1
        CALL	@TestObjetDelEnnemi
        POP	DX
@OTO0:  OR	DX,DX   { Si la boucle … ‚t‚ avort‚e, alors }
        JZ	@RETURN { l'objet ne peut plus tomber       }
        XOR	BH,BH
	MOV	BL,BYTE PTR [ObjetStatut+1+SI]
	SHR	BX,2
        CMP	BX,11
        JNA	@OTO3
        MOV	BX,11
@OTO3:	OR	BX,$0710
	CALL	@Sound
	AND	WORD PTR [ObjetAttr+SI],NOT Tombe
        MOV	BYTE PTR [ObjetStatut+1+SI],0
        TEST	WORD PTR [ObjetAttr+SI],ObjetPerso
        JNZ	@RETURN
	OR	WORD PTR [ObjetAttr+SI],ObjetStop
	RETN

        { Test si l'objet est devant mister et qu'il le prend }
@TestObjetPrend:
        TEST	[MisterPos],Action
        JZ	@False
        TEST	[MisterPos],Porte
	JNZ	@False
        TEST	[NotTake],$FF
        JNZ	@False
        MOV	AX,[MisterX]
        TEST	[MisterPos],1
        JZ	@TOP5
	DEC	AX
	JMP	@TOP6
@TOP5:	ADD	AX,18
@TOP6:	MOV	BX,WORD PTR [ObjetX+SI]
	CMP	AX,BX
        JB	@False
        SUB	AX,3
        ADD	BX,WORD PTR [ObjetHSize+SI]
        DEC	BX
	CMP	AX,BX
        JA	@False
        MOV	AX,[MisterY]
        SUB	AX,2
	MOV	BX,WORD PTR [ObjetY+SI]
	CMP	AX,BX
        JB	@False
        SUB	AX,3
        ADD	BX,WORD PTR [ObjetVSize+SI]
        DEC	BX
	CMP	AX,BX
        JA	@False
        CLC
        RETN

@ObjetLanceur:
        TEST	WORD PTR [ObjetAttr2+SI],ObjetQuiTire
        JZ	@OL0
	MOV	AX,WORD PTR [ObjetStat2+SI]
        OR	AH,AH
        JZ	@OL2
        DEC	AH
        JNZ     @STOD
@OL2:	INC	AL
        CMP	AL,24
        JNE	@STOD
        AND     WORD PTR [ObjetAttr2+SI],NOT ObjetQuiTire
        MOV	BX,67
        XOR	DX,DX
        CALL	@CreateObjetTire
	MOV	ObjetGetSp[DI].Word,OFFSET @Couteau
	MOV	AX,ObjetAttr2[SI].Word
        XOR	AL,AL
        AND	AH,7
        SHL	AH,5
        ADD	AH,10
@STOD:	MOV	WORD PTR [ObjetStat2+SI],AX
	RETN
@OL0:	CALL	@GetDist
	CMP	CX,DX
        JNA	@OL1
        MOV	WORD PTR [ObjetStat2+SI],$0100
        RETN
@OL1:   MOV	BX,ObjetLim1[SI].Word
        SHL	BX,4
	TEST	[MisterPos],Petit
        JZ	@STON
        MOV	CX,BX
        SHR	CX,2
        SUB	BX,CX
        JMP	@STON
@STON:	CMP	AX,BX
        JA	@RETURN
        MOV	CX,WORD PTR [ObjetAttr+SI]
	XOR	CX,DI
        AND	CX,1
        XOR	WORD PTR [ObjetAttr+SI],CX
	OR	WORD PTR [ObjetAttr2+SI],ObjetQuiTire
	RETN

@ObjetMarche:
        MOV	[TmpB1],0
        MOV	DX,WORD PTR [ObjetAttr2+SI]
        AND	DX,ObjetSpeedBit
        INC	DH
        SHR	DX,9
        JNC	@STOE
        TEST	[EtatPalette1],1
        JNZ	@OMAR0
	OR	DX,DX
	JZ	@STO3
        JMP	@STOE
@OMAR0:	INC	DX
@STOE:  TEST	WORD PTR [ObjetAttr+SI],1
        JZ	@STO1
        CALL	@ObjetGauche
	JMP     @STO2
@STO1:  CALL	@ObjetDroite
@STO2:  OR	DX,DX
	JZ	@STO3
        XOR	WORD PTR [ObjetAttr+SI],1
@STO3:	CALL	@GetDist
        TEST	[TmpB1],$FF { Teste si il est assez pr‚s     }
        JZ	@RETURN     { de mister pour qu'on l'entende }
        CMP	AX,256
        JA	@RETURN
        CMP	CX,127
        JA	@RETURN
        MOV	BX,AX
        SHL	BX,1
        ADD	BX,CX
        SHR	BX,6
        SUB	BX,9
        NEG	BX
        OR	BX,$0700
	CALL	@Sound
        RETN

@TestAttaque:
	TEST	[MisterPos],PerdVie
	JNZ	@False
        CALL	@GetDist
	CMP	CX,DX
        JA	@False
	MOV	CX,[MisterPos]
     	TEST	[Boss],$FF
	JZ	@STOJ
        TEST	CX,Petit
        JZ	@STOL
        CMP	AX,BX
        JA	@STOJ
	JMP	@STOM
@STOL:  ADD	BX,5
	CMP	AX,BX
        JA	@STOJ
        TEST	CX,Frappe
        JZ	@STOJ
@STOM:  MOV	DX,CX
        XOR	DX,DI
        TEST	DX,1
        JZ	@STOJ
        AND	CX,1
        OR	CX,ObjetTsp+ObjetTire
        MOV	WORD PTR [ObjetAttr+SI],CX
        MOV	WORD PTR [ObjetAttr2+SI],ObjetRien
        CALL	@GetSpriteObjet
        MOV	ObjetSprite[SI].Word,BX
        MOV	ObjetProc[SI].Word,OFFSET @VoleObjet
        MOV	ObjetGetSp[SI].Word,OFFSET @Default
        MOV	BX,$0505
        CALL	@Sound
        STC
	RETN
@STOJ:	CMP     AX,BX
        JA	@False
        CMP	WORD PTR [ObjetSprite+SI],57
        JNE	@STOF
        MOV	CX,[MisterPos]
        TEST	CX,Porte
        JNZ	@STOF
        TEST	CX,Action
        JZ	@STOF
        TEST	CX,1
        JZ	@STOH
        TEST	DI,1
        JNZ	@STOF
        TEST	WORD PTR [ObjetAttr+SI],1
        JZ	@STOF
	JMP	@STOI
@STOH:  TEST	DI,1
        JZ	@STOF
        TEST	WORD PTR [ObjetAttr+SI],1
        JNZ	@STOF
@STOI:  AND	WORD PTR [ObjetAttr+SI],$7FFF
        OR	WORD PTR [ObjetAttr+SI],ObjetPris
        MOV	[ObjetPorte],SI
        OR	[MisterPos],Porte
        MOV	WORD PTR [ObjetSprite+SI],73
        MOV	ObjetProc[SI].Word,OFFSET @FinTestObjet
        MOV	ObjetGetSp[SI].Word,OFFSET @Default
        STC
	RETN
@STOF:	TEST	[Boss],$FF
	JNZ     @RETURN
	MOV	BX,$0040
	MOV	ES,BX
        MOV	BL,ES:[$006C]
        AND	BL,7
	OR	BX,$0510
        CALL	@Sound
	CALL	@FrappeMister
	CLC
	RETN

@DelObjet: { Supprime un objet }
        MOV	BX,SI
        CALL	@DeletteObjet
        JMP	@FinTestObjet
@False:	STC
@RETURN:RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                    {³ Renvoie le sprite annim‚         ³
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@GetSpriteObjet:
	MOV	BX,ObjetSprite[SI].Word
        JMP	ObjetGetSp[SI].Word
@CoupDeFeu:
        DEC	ObjetSprite[SI].Word
@Couteau:
        MOV	ObjetGetSp[SI].Word,OFFSET @Default
        AND	ObjetAttr[SI].Word,NOT ObjetTire
        JMP	@Default
@GetGetteur:
	TEST	ObjetAttr2[SI].Word,$0002
        JNZ	@GGET0
	TEST	ObjetAttr2[SI].Word,$0001
      	JZ	@Default
	INC	BX
	JMP	@Default
@GGET0:	ADD	BX,2
@GetMarcheur:
        MOV	AL,BYTE PTR [ObjetStatut+SI]
        SHR	AL,2
        AND	AL,15
        CMP	AL,5
        JB	@Default
        CMP	AL,8
        JB	@GSO3
        CMP	AL,12
        JA	@GSO3
        ADD	BX,2
        JMP	@Default
@GSO3:	INC	BX
	JMP	@Default
@GetLanceur:
        MOV     AX,ObjetStat2[SI].Word
	SHR	AL,3
        AND	AX,15
	ADD	BX,AX
@Default:
	RETN
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
                    {³ Teste si on est sur un ascenseur ³
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
@TestAsc:
        PUSH	AX
        PUSH	CX
        TEST	[MisterPos],echelle
        JNZ	@TA0
        CMP	AX,[MisterY]
        JNE	@TA0
        MOV	AX,WORD PTR [ObjetX+SI]
        INC	AX
        MOV	BX,[MisterX]
        INC	BX
        MOV	CX,[MisterLargeur]
        ADD	CX,BX
        SUB	CX,3
        CMP	AX,CX
        JA	@TA0
        ADD	AX,WORD PTR [ObjetHSize+SI]
        SUB	AX,3
        CMP	AX,BX
        JB	@TA0
        POP	CX
        POP	AX
	CLC
        RETN
@TA0:	POP	CX
	POP	AX
        STC
        RETN
@ExitGame:
	PUSH	7
        CALL	CloseScreen
@ExitWithOutClose:
end;

procedure Jouer;
var
  i,j: word;
label Debut;
begin
  SuperBonnus := 0;
  Vie := 3;
  Bonnus := 0;
  Energie := 16;
Debut:
  { Efface doucement l'‚cran }
  PaletteFadeIn;

  { Charge le niveau }
  if not Load then exit;

  { Initialisation de mister patate }
  MisterPos := Droite;
  MisterElan := 0;
  CompteurPasBouge := 0;
  EtatTombe := 0;
  Boss := 0;
  MisterLargeur := DimSprite[30].Largeur;
  MisterHauteur := DimSprite[30].Hauteur;
  MaxPosX := 1 shl (ShiftLargeur + 4 )- 1;
  MaxScreenX := MaxPosX - 319;
  MaxPosY := 1 shl (19 - ShiftLargeur) - 1;
  MaxScreenY:= MaxPosY - (HautScr-1);
  WaitSaute := 0;

  for i := 0 to 255 do begin
    if ObjetSprite[i] = 0 then
      for j := 0 to 10 do MemW[Seg(ObjetX):Ofs(ObjetX[i])+j shl 9] := 0
    else if ObjetSprite[i] in [57] then ObjetStatut[i] := random (16);
  end;

  FirstPosX := ObjetX[200];
  FirstPosY := ObjetY[200] + MisterHauteur-1;
  ObjetSprite[200] := 0;
  ObjetX[200] := 0;
  ObjetY[200] := 0;

  PushObjet;
  avancement := 0;
  SetChannelIns (4, InsChannel[4]);

  { Lance le jeu }
  Jeu;

  if NiveauFinit <> 0 then
  begin
    BigText(Page_display, 0, HautScr shr 1-12, 'STAGE CLEAR', 242, 243, 0);
    Sleep;
    inc(Niveau);
    goto Debut;
  end;
end;

end.