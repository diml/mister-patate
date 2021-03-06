
{ Menu pour Mister Patate }
unit MrpMenu;

interface

uses MrpVga, MrpLoad, MrpPal, MrpKey, MrpStr, MrpCode, MrpTps, MrpSon;

const
  Principal  = 1;
  PendantJeu = 2;
  Option     = 3;
  ClavierOpt = 4;
  EcranOpt   = 5;
  SonOpt     = 6;

  SonMove: array[0..4] of Byte = (130,0,3,1,0);
  SonOk  : array[0..4] of Byte = (100,0,3,1,0);

var
  ResultMenu: Word;

  { �tat des couleurs du choix actif }
  StatutColor: Byte;

{ Lance un menu }
procedure Menu (What: Word);

{ Initialise les menus }
procedure InitMenu;

implementation

var
  { Nombre de choix possible du menu }
  NbrChoix: Byte;

  { Pour les couleurs }
  SaveCounter: Word;

  { �tat du programme }
  avancement: Byte;

procedure CaptureEcran;
var
  F: file;
  x, y: Word;
  p: array[0..319] of Byte;
begin
  Assign(F, 'Capture');
  ReWrite(F, 1);
  for y := 0 to HautScr-1 do begin
    for x := 0 to 319 do
      p[x] := GetPixel(2, x, y);
    BlockWrite(F, p, 320);
  end;
  BlockWrite(F, Palette, sizeof(Palette));
  Close(F);
end;

procedure PutMenu (Txt: String; PosCurseur: Word);
var
  PosTxt: Byte;
  Ligne: Byte;
  TxtTmp: String;
  Plus: Word;
begin
  { D�termine le nombre de choix de 'Txt' }
  NbrChoix := 0;
  for PosTxt := 1 to Length (Txt) do if Txt[PosTxt] = '/' then inc (NbrChoix);

  { Affiche le fond }
  PCopy (2, Page_not_display);

  { Affiche les menus }
  for Ligne := 1 to NbrChoix do begin
    PosTxt := Pos ('/', Txt);
    TxtTmp := Copy (Txt, 1, PosTxt-1);
    if Ligne = PosCurseur then begin
      Plus := Counter shr 1;
      if Plus and 8 <> 0 then Plus := Length(TxtTmp)*7 + 7 + (Plus and 7)
                         else Plus := Length(TxtTmp)*7 + 7 + (not Plus and 7);
      OutText (Page_not_display, Centre - Plus, HautScr shr 1 - 14 -NbrChoix shl 3+Ligne shl 4, '', 244, 245, True);
      OutText (Page_not_display, Centre + Plus, HautScr shr 1 - 14-NbrChoix shl 3+Ligne shl 4, '', 244, 245, True);
      OutText (Page_not_display, Centre, HautScr shr 1 - 14 - NbrChoix shl 3 + Ligne shl 4, TxtTmp, 244, 245, True);
    end else
      OutText (Page_not_display, Centre, HautScr shr 1 - 14 - NbrChoix shl 3 + Ligne shl 4, TxtTmp, 242, 243, True);
    Delete (Txt, 1, PosTxt);
  end;

  { Affiche � l'�cran }
  ShowPage;
end;

procedure InitMenu;
var x, y: word;
begin
  Music.EnAble := FALSE;
  LoadMusic(2);
  Music.OfsSound := Ofs(MusicNote);
  Music.EnAble := TRUE;
  if avancement = 0 then FillPalette (0,0,0)
                    else with Palette[7] do FillPalette (r,v,b);
  LoadFont;
  PCopy (2, Page_not_display);
  ShowPage;
  ConvertPalette;
  StatutColor := 2;
  avancement := 1;
end;

{ Active les couleur du choix s�lectionn� }
procedure LoopColorMenu;
begin
  if Counter = SaveCounter then exit;
  SaveCounter := Counter;
  with Palette[244] do case StatutColor of
    0: begin inc (V,4); if V = 63 then StatutColor := 1; end;
    1: begin dec (R,4); if R = 7 then StatutColor := 2; end;
    2: begin inc (B,4); if B = 63 then StatutColor := 3; end;
    3: begin dec (V,4); if V = 7 then StatutColor := 4; end;
    4: begin inc (R,4); if R = 63 then StatutColor := 5; end;
    5: begin dec (B,4); if B = 7 then StatutColor := 0; end;
  end;
  Palette[245].R := Palette[244].R - 5;
  Palette[245].V := Palette[244].V - 5;
  Palette[245].B := Palette[244].B - 5;
  OutPalette (244, 245);
end;

procedure GetCode;
var
  PosCode : Byte;
  Plus    : Byte;
  CodeRead: array[0..3] of Byte;
  i       : Word;
  Key     : Char;
  CodeTmp : Word;
begin
  PosCode := 0;
  FillChar (CodeRead, 4, 0);
  repeat
    { Prend le charact�re frapp�s }
    Key := InKey;
    LoopColorMenu;

    { Affiche le fond }
    PCopy (2, Page_not_display);

    { Affiche le code entr� }
    for i := 0 to 3 do begin
      if PosCode = i then begin
        Plus := Counter shr 1;
        if Plus and 8 <> 0 then Plus := Plus and 7
                           else Plus := not Plus and 7;
        OutText (Page_not_display, 105 + i * 34, HautScr shr 1 -30 - Plus, '*', 244, 245, true);
        OutText (Page_not_display, 105 + i * 34, HautScr shr 1 +20 + Plus, '*', 244, 245, true);
      end;
      BigPut (Page_not_display, 93 + i * 34, HautScr shr 1 -14, SpriteCode[CodeRead[i]]);
    end;

    { D�place le curseur ou le personnage }
    case Key of
      CharDroite: begin
        PosCode := (PosCode + 1) and 3;
        NewSound (5, 0, 0);
      end;
      CharGauche: begin
        PosCode := (PosCode - 1) and 3;
        NewSound (5, 0, 0);
      end;
      CharHaut  : begin
        CodeRead[PosCode] := (CodeRead[PosCode] - 1) and 7;
        NewSound (7, 0, 3);
      end;
      CharBas   : begin
        CodeRead[PosCode] := (CodeRead[PosCode] + 1) and 7;
        NewSound (7, 0, 3);
      end;
      CharEchap : exit;
    end;

    ShowPage;
  until Key = CharEntree;
  CodeTmp := 0;
  asm
        PUSH	DS
  	LEA	SI,[CodeRead]
  	MOV	AX,SS
        MOV	DS,AX
        MOV	CL,9
        XOR	BX,BX
  @LoopCode:
  	LODSB
        CBW
        SHL	AX,CL
        OR	BX,AX
        SUB	CL,3
        JNC	@LoopCode
        POP	DS
        MOV	AX,BX
        MOV	[i],AX
        MUL	AX
        MOV	AL,AH
        MOV	AH,DL
        MOV	[CodeTmp],AX
  end;
  if i <> 0 then
    begin
      i := StageCode(CodeTmp);
      if i = 0 then i := 16;
    end
  else i := StageCode(CodeTmp);
  PCopy (2, Page_not_display);
  if i = 16 then OutText (Page_not_display, Centre, Centre, '!FAUX CODE!', 242, 243, true)
  else begin
    OutText (Page_not_display, Centre, Centre-20, 'NIVEAU ' + Str (i+1,2), 242, 243, true);
    if Length (Nom[i]) > 20 then begin
      OutText (Page_not_display, Centre, Centre+8, StrPart1 (Nom[i]), 242, 243, true);
      OutText (Page_not_display, Centre, Centre+27, StrPart2 (Nom[i]), 242, 243, true);
    end else OutText (Page_not_display, Centre, Centre+20, Nom[i], 242, 243, true);
    Niveau := i;
  end;
  ShowPage;
  repeat until inkey = CharEntree;
end;

procedure Menu;
var
  Curseur: Word;
  Key: Char;
  TxtMenu: String;
  ConfigSave: array[0..8] of Word;
  TmpModif: Boolean;
  i: Byte;
begin
  { Positionne le curseur au d�but }
  Curseur := 1;

  { S�lectionne le menu }
  case What of
    Principal : TxtMenu := 'JOUER/CODE/OPTION/CREDIT/QUITTER/';
    PendantJeu: TxtMenu := 'REPRENDRE/OPTION/CAPTURE/RETOUR MENU/';
    Option    : TxtMenu := 'CLAVIER/SON/ECRAN/RETOUR/';
    ClavierOpt: move (KeyMrp, ConfigSave, 18);
  end;

  { Modification des configurations }
  TmpModif := false;

  repeat
    case What of
      ClavierOpt: TxtMenu := 'DROITE:' + NomTouche (ConfigSave[0]) + '/' +
      		             'GAUCHE:' + NomTouche (ConfigSave[1]) + '/' +
	                     'HAUT  :' + NomTouche (ConfigSave[2]) + '/' +
	                     'BAS   :' + NomTouche (ConfigSave[3]) + '/' +
    	                     'SAUTE :' + NomTouche (ConfigSave[4]) + '/' +
	                     'ACTION:' + NomTouche (ConfigSave[5]) + '/' +
	                     'LANCE :' + NomTouche (ConfigSave[6]) + '/' +
	                     'STATUT:' + NomTouche (ConfigSave[7]) + '/' +
	                     'MENU  :' + NomTouche (ConfigSave[8]) + '/' +
	                     'PAR DEFAUT/RESTORE/RETOUR/';
      EcranOpt:
      begin
        TxtMenu :=   'STATUT PERMANENT ' + StrOk (StatutPerm) + '/' +
                     'ECRAN CENTRE     ' + StrOk (Center) + '/' +
		     'LARGEUR ZONE MRP=' + StrE(Screen.Zone[1].H shl 1,3) + '/' +
		     'HAUTEUR ZONE MRP=' + StrE(Screen.Zone[1].V shl 1,3) + '/';
        if Center then TxtMenu := TxtMenu +
		     'LARGEUR MINIZONE=' + StrE(Screen.Zone[2].H shl 1,3) + '/' +
		     'HAUTEUR MINIZONE=' + StrE(Screen.Zone[2].V shl 1,3) + '/'
                  else TxtMenu := TxtMenu +
		     'VITESSE X       =' + StrE(Screen.SpeedH shl 1,3) + '/' +
		     'VITESSE Y       =' + StrE(Screen.SpeedV shl 1,3) + '/';
	TxtMenu := TxtMenu + 'RETOUR/';
      end;
      SonOpt: TxtMenu := 'EFFET SONORE ' + StrOk (SonOn) + '/' +
                         'VOLUME      =' + StrE(VolumeSon,3) + '/' +
                         'MUSIQUE      ' + StrOk (MusicOn) + '/' +
                         'VOLUME      =' + StrE(VolumeMusic,3) + '/RETOUR/';
    end;

    { Affiche le menu }
    PutMenu (TxtMenu, Curseur);

    { Vide le buffer du clavier }
    ClearKey;

    { Attend l'appuie d'une touche }
    repeat
      Key := InKey;
      LoopColorMenu;
      PutMenu (TxtMenu, Curseur);
    until Key <> #0;

    { Traite la touche }
    case Key of
      CharHaut: begin
        if Curseur > 1 then dec (Curseur) else Curseur := NbrChoix;
	NewSound (7, 0, 3);
      end;
      CharBas : begin
        if Curseur < NbrChoix then inc (Curseur) else Curseur := 1;
	NewSound (7, 0, 3);
      end;
      CharPlus: begin
        TmpModif := True;
        if What = EcranOpt then with Screen do
	begin
	case Curseur of
        3: if Zone[1].H < 160 then Inc(Zone[1].H);
        4: if Zone[1].V < 100 then Inc(Zone[1].V);
        5: if Center then
	     begin
	       if Zone[2].H < 160 then Inc(Zone[2].H);
               if Zone[2].H > Zone[1].H then Zone[1].H := Zone[2].H;
             end
           else if SpeedH < 32  then Inc(SpeedH);
        6: if Center then
	     begin
	       if Zone[2].V < 100 then Inc(Zone[2].V);
               if Zone[2].V > Zone[1].V then Zone[1].V := Zone[2].V;
             end
           else if SpeedV < 32  then Inc(SpeedV);
        end;
        CalculScroll;
      end else if What = SonOpt then case Curseur of
        2: if VolumeSon < 63 then begin Inc(VolumeSon); SetVolumeSon; end;
        4: if VolumeMusic < 63 then begin Inc(VolumeMusic); SetVolumeMusique; end;
      end;
      end;
      CharMoins:begin
        TmpModif := True;
        if What = EcranOpt then with Screen do
        begin
	case Curseur of
        3: begin
	     if Zone[1].H > 0 then Dec(Zone[1].H);
             if Zone[2].H > Zone[1].H then Zone[2].H := Zone[1].H;
           end;
        4: begin
	     if Zone[1].V > 0 then Dec(Zone[1].V);
             if Zone[2].V > Zone[1].V then Zone[2].V := Zone[1].V;
           end;
        5: if Center then
             begin
	       if Zone[2].H > 0 then Dec(Zone[2].H);
             end
           else if SpeedH > 4  then Dec(SpeedH);
        6: if Center then
	     begin
	       if Zone[2].V > 0 then Dec(Zone[2].V);
             end
           else if SpeedV > 4  then Dec(SpeedV);
        end;
        CalculScroll;
      end else if What = SonOpt then case Curseur of
        2: if VolumeSon > 0 then begin Dec(VolumeSon); SetVolumeSon; end;
        4: if VolumeMusic > 0 then begin Dec(VolumeMusic); SetVolumeMusique; end;
      end;
      end;
      CharEntree: begin
	NewSound (5, 0, 0);
        case What of
        Principal: case Curseur of
	  1: exit;
          2: GetCode;
          3: Menu (Option);
          5: begin if ModifConfig then SaveConfig; Halt; end;
        end;
        Option: case Curseur of
          1: Menu (ClavierOpt);
          2: Menu (SonOpt);
          3: Menu (EcranOpt);
	  4: exit;
        end;
        PendantJeu: case Curseur of
	  1: begin ResultMenu := 0; exit; end;
          2: Menu (Option);
          3: CaptureEcran;
          4: begin ResultMenu := 1; exit; end;
        end;
        ClavierOpt: case Curseur of
          1..9: begin
            PCopy (2, Page_not_display);
            OutText (Page_not_display, Centre, Centre, 'APPUYEZ SUR UNE TOUCHE', 244, 245, true);
            ShowPage;
            while KeyPress do LoopColorMenu;
            while not KeyPress do LoopColorMenu;
            i := 0;
            while not GetKey[i] do inc (i);
            ConfigSave[Curseur-1] := i;
            TmpModif := true;
            ClearKey;
          end;
          10: begin
            ConfigSave[0] := 205;
            ConfigSave[1] := 203;
            ConfigSave[2] := 200;
            ConfigSave[3] := 208;
            ConfigSave[4] := 56;
            ConfigSave[5] := 57;
            ConfigSave[6] := 29;
            ConfigSave[7] := 28;
            ConfigSave[8] := 1;
            TmpModif := true;
          end;
          11: begin
	    move (KeyMrp, ConfigSave, 18);
            TmpModif := false;
          end;
          12: begin
            move (ConfigSave, KeyMrp, 18);
            ModifConfig := ModifConfig or TmpModif;
            exit;
          end;
        end;
        SonOpt: case Curseur of
          1: begin SonOn := not SonOn; TmpModif := true; end;
          3: begin MusicOn := not MusicOn; TmpModif := true; end;
          5: begin ModifConfig := ModifConfig or TmpModif; exit; end;
        end;
        EcranOpt: case Curseur of
          1: begin StatutPerm := not StatutPerm; TmpModif := true; end;
          2: begin Center := not Center; TmpModif := true; end;
          7: begin ModifConfig := ModifConfig or TmpModif; exit; CalculScroll; end;
        end;
        end;
      end;
    end;
  until false;

end;


end.

