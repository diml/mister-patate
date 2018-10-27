uses MrpGraph, MrpVga, MrpTps, MrpSon, MrpStr, MrpLoad, MrpKey, MrpInit;

var
  Mode: Word;
  Channel: Word;
  MusicFile: Word;

  InsSel: array[0..3,0..1,0..3] of WordBool;
  Conection: array[0..3] of WordBool;
  InsVar: array[0..3,0..16] of Word;
  ScrNote: Word;
  PosNote: Word;
  PosChan: Word;
  ModeInser: Boolean;
  Octave: Word;

const
  InsMax: array[0..8] of Word =
  (15,3,63,15,15,15,15,255,127);
  MaxScrNote: Word = 986;

  Nb2Note: array[0..13,0..2] of Char =
    ('C  ','C# ','D  ','D# ','E  ','F  ','F# ','G  ','G# ','A  ','A# ','B  ','   ','>>>');

procedure Quitter (Sender: Word); far;
begin
  Halt;
end;

procedure ShowIns;
var
  i: Word;
begin
  for i := 0 to 16 do
    OutText8 (1,168+(i and 1)*50, 88+(i shr 1)*10,StrE (InsVar[Channel,i],4),243,0,false);
end;

procedure SetIns (Sender: Word); far;
begin
  case Sender of
    11..14: InsMusic[Channel,0] := InsMusic[Channel,0] xor (16 shl (14-Sender));
    15..18: InsMusic[Channel,1] := InsMusic[Channel,1] xor (16 shl (18-Sender));
    19:InsMusic[Channel, 0] := InsMusic[Channel, 0] and $F0 or InsVar[Channel, 0];
    20:InsMusic[Channel, 1] := InsMusic[Channel, 1] and $F0 or InsVar[Channel, 1];
    21:InsMusic[Channel, 2] := InsMusic[Channel, 2] and $3F or InsVar[Channel, 2] shl 6;
    22:InsMusic[Channel, 3] := InsMusic[Channel, 3] and $3F or InsVar[Channel, 3] shl 6;
    23:InsMusic[Channel, 2] := InsMusic[Channel, 2] and $C0 or InsVar[Channel, 4];
    24:InsMusic[Channel, 3] := InsMusic[Channel, 3] and $C0 or InsVar[Channel, 5];
    25:InsMusic[Channel, 4] := InsMusic[Channel, 4] and $F0 or InsVar[Channel, 6];
    26:InsMusic[Channel, 5] := InsMusic[Channel, 5] and $F0 or InsVar[Channel, 7];
    27:InsMusic[Channel, 4] := InsMusic[Channel, 4] and $0F or InsVar[Channel, 8] shl 4;
    28:InsMusic[Channel, 5] := InsMusic[Channel, 5] and $0F or InsVar[Channel, 9] shl 4;
    29:InsMusic[Channel, 6] := InsMusic[Channel, 6] and $F0 or InsVar[Channel,10];
    30:InsMusic[Channel, 7] := InsMusic[Channel, 7] and $F0 or InsVar[Channel,11];
    31:InsMusic[Channel, 6] := InsMusic[Channel, 6] and $0F or InsVar[Channel,12] shl 4;
    32:InsMusic[Channel, 7] := InsMusic[Channel, 7] and $0F or InsVar[Channel,13] shl 4;
    33:InsMusic[Channel, 8] := InsVar[Channel,14];
    34:InsMusic[Channel, 9] := InsVar[Channel,15];
    35:InsMusic[Channel,10] := InsMusic[Channel,10] and 1 or InsVar[Channel,16] shl 1;
    37:InsMusic[Channel,10] := InsMusic[Channel,10] xor 1;
  end;
  MusicOn := False;
  SetChannelIns (Channel, InsMusic[Channel]);
  MusicOn := True;
  ShowIns;
end;

procedure DecInsVar (Sender: Word); far;
begin
  if InsVar[Channel,Sender-38] > 0 then dec (InsVar[Channel,Sender-38]);
  SetIns (19+Sender-38);
end;

procedure IncInsVar (Sender: Word); far;
begin
  if InsVar[Channel,Sender-55] < InsMax[(Sender-55)shr 1]then inc (InsVar[Channel,Sender-55]);
  SetIns (19+Sender-55);
end;

procedure SetChannel (Sender: Word); far;
var
  i: Word;
begin
  Channel := Sender-7;
  FillBox (1, 3, 19, 316, 196, 0);
  MakeClasseur (7, Channel+1, 3, 19, 316, 196, 'Canal 0/Canal 1/Canal 2/Canal 3', SetChannel);
  Outtext8 (1, 6, 48, 'Ton Vibrant       :', 241, 0, false);
  Outtext8 (1, 6, 58, 'Amplitude Vibrante:', 241, 0, false);
  Outtext8 (1, 6, 68, 'Niveau soutenu    :', 241, 0, false);
  Outtext8 (1, 6, 78, 'Gamme envelopp‚e  :', 241, 0, false);
  Outtext8 (1, 6, 88, 'Frequence *       :', 241, 0, false);
  Outtext8 (1, 6, 98, 'Gamme             :', 241, 0, false);
  Outtext8 (1, 6,108, 'Nettet‚           :', 241, 0, false);
  Outtext8 (1, 6,118, 'Attaque           :', 241, 0, false);
  Outtext8 (1, 6,128, 'D‚clin            :', 241, 0, false);
  Outtext8 (1, 6,138, 'Soutenance        :', 241, 0, false);
  Outtext8 (1, 6,148, 'Lib‚ration        :', 241, 0, false);
  Outtext8 (1, 6,158, 'Onde s‚lection    :', 241, 0, false);
  Outtext8 (1, 6,168, 'FeedBack          :', 241, 0, false);
  Outtext8 (1, 6,178, 'Conection         :', 241, 0, false);

  for i := 0 to 3 do begin
    MakeSelBox (11+i, 158, 48+i*10, InsSel[Channel,0,i], SetIns);
    MakeSelBox (15+i, 198, 48+i*10, InsSel[Channel,1,i], SetIns);
  end;

  for i := 0 to 16 do begin
    MakeValeur (19+i, 168+(i and 1)*50+23-Len(InsMax[i shr 1]) shl 3, 88+(i shr 1)*10,
                InsVar[Channel,i],InsMax[i shr 1],243,0,SetIns);
    OutText8 (2,168+(i and 1)*50, 88+(i shr 1)*10,'ÛÛÛÛ',19+i,0,false);
    OutText8 (2,160+(i and 1)*50, 88+(i shr 1)*10,'Û',38+i,0,false);
    OutText8 (2,200+(i and 1)*50, 88+(i shr 1)*10,'Û',55+i,0,false);
    OutText8 (1,160+(i and 1)*50, 88+(i shr 1)*10,'-',240,0,false);
    OutText8 (1,200+(i and 1)*50, 88+(i shr 1)*10,'+',240,0,false);
    with ObjetInfo[38+i] do begin
      TxtX := 160+(i and 1)*50;
      TxtY := 88+(i shr 1)*10;
      Text := '-';
      Color := 240;
      Attribut := TextLight + CursorMain + EventOnPush;
      Event := DecInsVar;
      Pas1 := 4;
      Pas2 := 0;
      PtrOn := @ObjetAble;
    end;
    with ObjetInfo[55+i] do begin
      TxtX := 200+(i and 1)*50;
      TxtY := 88+(i shr 1)*10;
      Text := '+';
      Color := 240;
      Attribut := TextLight + CursorMain + EventOnPush;
      Event := IncInsVar;
      Pas1 := 4;
      Pas2 := 0;
      PtrOn := @ObjetAble;
    end;
  end;

  ShowIns;
  MakeSelBox (37, 158, 178, Conection[Channel], SetIns);
end;

procedure Save (Sender: Word); far;
var
  F: file;
begin
  assign (F, 'MUSIQUE\MRPMSQ' + Str (MusicFile, 2) + '.SQZ');
  rewrite (f, 1);
  BlockWrite (F, Music.pas, 1);
  BlockWrite (F, InsMusic, SizeOf (InsMusic));
  BlockWrite (F, MusicNote, SizeOf (MusicNote));
  close (F);
end;

procedure SetPos (Sender: Word); far;
begin
  PosChan := Sender - 10;
  PosNote := MouseXr shr 3 + ScrNote;
end;

procedure SetNote (Sender: Word); far;
begin
  MusicOn := False;
  Music.OfsSound := Ofs (MusicNote) + MouseXr shr 3 + ScrNote;
  MusicOn := True;
end;

procedure Play (Sender: Word); far;
begin
  Music.EnAble := False;
  case Sender of
    14: Music.EnAble := True;
    16: Music.OfsSound := Ofs (MusicNote);
  end;
end;

procedure IncPas (Sender: Word); far;
begin
  if Music.Pas < 255 then inc (Music.Pas);
end;

procedure DecPas (Sender: Word); far;
begin
  if Music.Pas > 0 then dec (Music.Pas);
end;

function Lit(var F: file; var Buffer; Qte: Word): Boolean;
var
  NB: Word;
begin
  BlockRead(F, Buffer, Qte, NB);
  Lit := NB = Qte;
end;
procedure LoadMusicFile;
var
  F: file;
  i: Byte;
label MusicError;
begin
  { Ouvre le fichier des musiques }
  if not Ouvre ('MUSIQUE\MRPMSQ' + Str(MusicFile, 2) + '.SQZ', F, 1) then goto MusicError;
  { Lit les musiques }
  if not Lit(F, Music.pas, 1) then goto MusicError;
  if not Lit(F, InsMusic, SizeOf (InsMusic)) then goto MusicError;
  if not Lit(F, MusicNote, SizeOf (MusicNote)) then goto MusicError;
  close (F);
  SetVolumeMusique;
  exit;
MusicError:
  Music.EnAble := False;
  Music.Pas := 25;
  FillChar(MusicNote, SizeOf(MusicNote), 0);
end;
procedure SetMode(Sender: Word); far; forward;
procedure Charger(Sender: Word); far;
var
  i: Byte;
begin
  i := SelectFile(FileMusic, 'Charger', MusicFile, 0);
  if i < 16 then
  begin
    Music.EnAble := False;
    Music.OfsSound := Ofs(MusicNote);
    MusicFile := i;
    LoadMusicFile;
  end;
  SetMode(Mode);
end;

procedure SetMode;
var
  i: Word;
begin
  ClearObjet(0,255); Cls (2, 0); Cls (1, 0);
  Mode := Sender;
  MakeClasseur (1, Mode, 0, 0, 319, 199, 'Musique/Instruments/Attributs', SetMode);
  case Mode of
    1: Begin
      MakeBarreH (7,  3, 30, 312, ScrNote, MaxScrNote, 4, 0, 1, nil);
      for i := 0 to 3 do MakeBox (10+i, 7, 49+i*26, 312, 74+i*26, 0, EventOnPush+CursorMain
      , SetPos, SetNote);
      MakeBouton (14,  8, 156, #$90, 246, Play);
      MakeBouton (15, 24, 156, #$91, 246, Play);
      MakeBouton (16, 40, 156, #$92, 246, Play);
      OutText8 (1, 64, 160, 'Duree d''une note:-   +109e de s', 246, 0, false);
      OutText8 (2, 200, 160, 'Û', 17, 0, false);
      OutText8 (2, 232, 160, 'Û', 18, 0, false);
      with ObjetInfo[17] do begin
        TxtX := 200;
        TxtY := 160;
        Text := '-';
        Color := 246;
        Attribut := TextLight + CursorMain + EventOnPush;
        Event := DecPas;
        Pas1 := 4;
        Pas2 := 0;
        PtrOn := @ObjetAble;
      end;
      with ObjetInfo[18] do begin
        TxtX := 232;
        TxtY := 160;
        Text := '+';
        Color := 246;
        Attribut := TextLight + CursorMain + EventOnPush;
        Event := IncPas;
        Pas1 := 4;
        Pas2 := 0;
        PtrOn := @ObjetAble;
      end;
      OutText8 (1, 8, 180, 'Octave=', 246, 0, false);
    end;
    2: SetChannel (Channel+7);
    3: begin
      MakeBouton (7, 3, 181, 'Enregistrer', 246, Save);
      MakeBouton (9, 99, 181, 'Charger', 246, Charger);
      MakeBouton (8, 171, 181, 'Quitter', 246, Quitter);
    end;
  end;
end;

procedure ShowNote; assembler;
asm
	MOV	DX,$3C4
        MOV	AL,$02
        OUT	DX,AL
        INC	DX
        MOV	AX,$A3E8
        MOV	ES,AX
        MOV	DI,50*80+2
        MOV	SI,[ScrNote]
        MOV	CX,38
@LoopColonne:
        PUSH	CX
        MOV	CX,4
@LoopChannel:
	PUSH	CX
        PUSH	SI
        MOV	BL,$0A
        MOV	AX,[Music.OfsSound]
        SUB	AX,OFFSET [MusicNote]
	CMP	SI,AX
	JNE	@SN6
        MOV	BH,$06
        JMP	@SN5
@SN6:	MOV	BH,$09
@SN5:   MOV	AX,4
	SUB	AX,CX
        CMP	SI,[PosNote]
        JNE	@SN7
        CMP	AX,[PosChan]
        JNE	@SN7
        MOV	BL,$0E
@SN7:	SHL	AX,10
        ADD	SI,AX
	MOV	AL,[MusicNote+SI].Byte
        CMP	AL,15
        JNE     @SN0
        MOV	BX,$0C0C
        JMP     @SN3
@SN0:	CMP	AL,-1
        JNE	@SN8
	MOV	SI,OFFSET [Nb2Note]+13*3
        JMP	@SN3
@SN8:   CMP	AL,$F0
	JNE	@SN4
	MOV	SI,OFFSET [Nb2Note]+12*3
        JMP	@SN3
@SN4:	MOV	SI,AX
        AND	SI,15
        MOV	CX,SI
        SHL	SI,1
        ADD	SI,CX
	ADD	SI,OFFSET [Nb2Note]
        SHR	AL,4
        ADD	AL,'0'
        MOV	[SI+2],AL
@SN3:	MOV	CX,3
@LoopChar:
	PUSH	CX
        LODSB
        PUSH	SI
	XOR	AH,AH
        MOV	SI,AX
        SHL	SI,3
        ADD	SI,OFFSET [Police8x8]
	MOV	CX,8
@LoopLine:
	LODSB
        OUT	DX,AL
        MOV     ES:[DI],BL
        NOT	AL
        OUT	DX,AL
        MOV	ES:[DI],BH
        INC	DI
        SHR	AL,4
        OUT	DX,AL
        MOV	ES:[DI],BH
        NOT	AL
        OUT	DX,AL
        MOV	ES:[DI],BL
        ADD	DI,79
        LOOP	@LoopLine
        POP	SI
        POP	CX
        LOOP	@LoopChar
        POP	SI
        POP	CX
        ADD	DI,80*2
        DEC	CX
        JNZ	@LoopChannel
        POP	CX
        SUB	DI,80*104-2
        INC	SI
        DEC	CX
        JNZ	@LoopColonne
end;

procedure NewNote (Note: Byte);
var
  c, n: Word;
begin
  if ModeInser and (PosNote < 1023) then
    move (MusicNote[PosChan,PosNote],MusicNote[PosChan,PosNote+1],1023-PosNote);
  if Note = 15 then MusicNote[PosChan,PosNote] := 15
  else MusicNote[PosChan,PosNote] := Octave shl 4 or Note;
  for c := 0 to 3 do for n := 0 to PosNote do if MusicNote[c,n] = $0F then MusicNote[c,n] := $F0;
  if PosNote < 1023 then inc (PosNote);
  if (PosNote < ScrNote) or (PosNote > ScrNote+37) then begin
    ScrNote := PosNote;
    if ScrNote > MaxScrNote then ScrNote := MaxScrNote;
    DrawBarreH (7);
  end;
end;

var
  i,j: Word;
  k: char;
  Test: Boolean;
begin
  InitGraph (3);
  Page_not_display := 3;
  MusicFile := SelectFile(FileMusic, 'Ouvrir', 0, 1);
  LoadMusicFile;
  CounterMusic := 1;
  MusicOn := True;
  Music.OfsSound := Ofs (MusicNote);
  for j := 0 to 3 do begin
    Conection[j] := InsMusic[j,10] and 1 = 1;
    InsVar[j, 0] := InsMusic[j,0] and $0F;
    InsVar[j, 1] := InsMusic[j,1] and $0F;
    InsVar[j, 2] := InsMusic[j,2] shr 6;
    InsVar[j, 3] := InsMusic[j,3] shr 6;
    InsVar[j, 4] := InsMusic[j,2] and $3F;
    InsVar[j, 5] := InsMusic[j,3] and $3F;
    InsVar[j, 6] := InsMusic[j,4] and $0F;
    InsVar[j, 7] := InsMusic[j,5] and $0F;
    InsVar[j, 8] := InsMusic[j,4] shr 4;
    InsVar[j, 9] := InsMusic[j,5] shr 4;
    InsVar[j,10] := InsMusic[j,6] and $0F;
    InsVar[j,11] := InsMusic[j,7] and $0F;
    InsVar[j,12] := InsMusic[j,6] shr 4;
    InsVar[j,13] := InsMusic[j,7] shr 4;
    InsVar[j,14] := InsMusic[j,8];
    InsVar[j,15] := InsMusic[j,9];
    InsVar[j,16] := InsMusic[j,10] shr 1;
    for i := 0 to 3 do begin
      InsSel[j,0,i] := (InsMusic[j,0] and (16 shl (3-i))) <> 0;
      InsSel[j,1,i] := (InsMusic[j,1] and (16 shl (3-i))) <> 0;
    end;
  end;
  SetMode (1);

  repeat
    Update;

      case Mode of
        1: begin
          k := UpCase(Inkey);
          case k of
            'Q': NewNote (00);
            'S': NewNote (01);
            'D': NewNote (02);
            'F': NewNote (03);
            'G': NewNote (04);
            'H': NewNote (05);
            'J': NewNote (06);
            'K': NewNote (07);
            'L': NewNote (08);
            'M': NewNote (09);
            '%': NewNote (10);
            'æ': NewNote (11);
            ' ': NewNote ($F0);
            '>': NewNote (255);
            '0'..'6': Octave := Ord(k) - Ord('0');
            CharBas: PosChan := (PosChan+1) and 3;
            CharHaut: PosChan := (PosChan-1) and 3;
            CharDroite: if PosNote < 1023 then begin
	      Inc (PosNote);
              if PosNote > ScrNote+37 then begin
	        inc (ScrNote);
                DrawBarreH (7);
              end;
            end;
            CharGauche: if PosNote > 0 then begin
	      dec (PosNote);
              if PosNote < ScrNote then begin
	        dec (ScrNote);
                DrawBarreH (7);
              end;
            end;
            CharInser: ModeInser := not ModeInser;
            CharSuppr: begin
              MusicNote[PosChan,PosNote] := $0F;
              if PosNote < 1023 then begin
                move (MusicNote[PosChan,PosNote+1],MusicNote[PosChan,PosNote],1023-PosNote);
                for i := PosNote to 1023 do if MusicNote[PosChan,i] = $0F then
	        begin
		    MusicNote[PosChan,i] := $F0;
                    Break;
                end;
                for i := 1023 downto PosNote do
		begin
                  Test := True;
                  for j := 0 to 3 do Test := Test and (MusicNote[j,i] in [$F0,$0F]);
                  if not Test then Break;
                  for j := 0 to 3 do MusicNote[j,i] := $0F;
                end;
              end;
            end;
          end;
	  ShowNote;
          if (PosNote >= ScrNote) and (PosNote <= ScrNote+37) and (Timer and 8 = 8) then begin
            if ModeInser then k := 'Ü' else k := '_';
            OutText8 (1, 8 + (PosNote-ScrNote) shl 3, 51 + PosChan * 26, k, 13, tsp, false);
	  end;
          OutText8 (1, 64, 180, Str (Octave,1), 246, 0, false);
          OutText8 (1, 208, 160, StrE (Music.Pas,3), 246, 0, false);
        end;
      end;

  until false;

end.