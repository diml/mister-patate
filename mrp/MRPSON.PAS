
{ Routines de son pour Mister Patate }
unit MrpSon;

interface

type
  { Instrumment }
  TIns = array[0..10] of Byte;

  TMusic = record
    OfsSound: Word;
    Pas     : Byte;
    EnAble  : Boolean;
  end;

var
  { True si le driver son est pr�sent }
  SoundEnable: Boolean;

  { Musique jou�e pour les bonnsu }
  BonnusMusic: TMusic;

  { Musique de fond }
  Music: TMusic;

  { Buffer de note }
  MusicNote: array[0..3,0..1023] of Byte;

  { Instrument de la musique }
  InsMusic: array[0..3] of TIns;

const
  ChannelIns: array[0..8] of Word =
    ($0003, $0104, $0205, $080B, $090C, $0A0D, $1013, $1114, $1215);

  NoteFreq: array[0..11] of Word =
  ($216B,$2181,$2198,$21B0,$21CA,$21E5,$2202,$2220,$2241,$2263,$2287,$22AE);

  { Instrument }
  InsChannel: array[4..8] of TIns =
  (($03,$03,$0B,$40,$A9,$D3,$05,$07,$01,$05,$09), {Bonnus}
   ($01,$00,$03,$00,$76,$76,$25,$32,$02,$02,$04), {Coup}
   ($04,$04,$07,$00,$75,$75,$73,$62,$01,$00,$00), {Rebondissement}
   ($10,$10,$C3,$00,$F6,$F6,$75,$62,$01,$00,$02), {Pas, Tombe, Cogne}
   ($23,$01,$C3,$C0,$C9,$93,$05,$07,$03,$00,$00));

{ Emet un son }
procedure Son (Frequence: Word);

{ Stop le HP }
procedure StopSon;

{ Emet un BEEEP }
procedure Beep;

{ Initialise le son }
function InitSound: Boolean;

{ arr�te le son }
procedure CloseSound;

{ �crit dans le port de la carte son }
procedure WritePort;

{ S�lectionne l'instrument d'un channel }
procedure SetChannelIns (Channel: Word; var Ins: TIns);

{ Emet un son }
procedure NewSound (Channel, Note: Word; Octave: Byte);

{ Stop tous les channels }
procedure ClearSound;

implementation

uses MrpTps, MrpLoad;

{$S-}
procedure Son; assembler;
asm
	MOV	BX,Frequence
        MOV	AX,$34DD
        MOV	DX,$0012
        CMP	DX,BX
        JNB	@@2
        DIV	BX
        MOV	BX,AX
	IN      AL,$61
	TEST    AL,3
	JNZ	@@1
	OR      AL,3
	OUT     $61,AL
	MOV     AL,$B6
	OUT     $43,AL
@@1:    MOV     AL,BL
	OUT     $42,AL
	MOV     AL,BH
	OUT     $42, AL
@@2:
end;

procedure StopSon; assembler;
asm
	IN      AL,$61
	AND     AL,252
	OUT     $61,AL
end;
{$S+}

procedure Beep;
var
  t: LongInt;
begin
  Son (800);
  t := Timer + 4;
  repeat until Timer > t;
  StopSon;
end;

{$S-}
procedure WritePort; assembler;
asm
        PUSH	DX
        PUSH	CX
        PUSH	AX
	MOV	DX,$388
        OUT	DX,AL
	MOV	CX,5
@1:     IN	AL,DX
	LOOP	@1
	INC	DX
        MOV	AL,AH
        OUT	DX,AL
        MOV	CL,35
	DEC	DX
@2:     IN	AL,DX
	LOOP	@2
        POP	AX
        POP	CX
        POP	DX
end;
{$S+}

function InitSound; assembler;
asm
	MOV	AX,$6004
        CALL	WritePort
        MOV	AX,$8004
        CALL	WritePort
        MOV	DX,$388
        IN	AL,DX
        TEST	AL,$E0
        JNZ	@NoSound
        MOV	AX,$FF02
        CALL	WritePort
        MOV	AX,$2104
        CALL	WritePort
	MOV	CX,151
@1:	IN	AL,DX
	LOOP	@1
        AND	AL,$E0
        CMP	AL,$C0
        JNE	@NoSound
	MOV	AX,$6004
        CALL	WritePort
        MOV	AX,$8004
        CALL	WritePort
	XOR	BL,BL
	XOR	AH,AH
@2:	MOV	AL,BL
	CALL	WritePort
        INC	BL
        CMP	BL,246
        JNE	@2
	MOV	AL,1
        JMP	@exit
@NoSound:
	XOR	AL,AL
@exit:
	MOV	[SoundEnable],AL
end;

procedure SetChannelIns; assembler;
asm
	PUSH	DS
        MOV	BX,[Channel]
        SHL	BX,1
        MOV	BX,WORD PTR [ChannelIns+BX]
        LDS	SI,[Ins]
        MOV	CL,$20
@1:     LODSB
	MOV	AH,AL
	MOV	AL,CL
        ADD	AL,BH
        CALL	WritePort
        LODSB
	MOV	AH,AL
	MOV	AL,CL
        ADD	AL,BL
        CALL	WritePort
        ADD	CL,$20
        CMP	CL,$A0
        JNE	@1
	LODSB
        MOV	AH,AL
        MOV	AL,$E0
        ADD	AL,BH
        CALL	WritePort
	LODSB
        MOV	AH,AL
        MOV	AL,$E3
        ADD	AL,BH
        CALL	WritePort
        LODSB
        MOV	AH,AL
        MOV	AL,$C0
        ADD	AL,BYTE PTR [Channel]
        CALL	WritePort
        POP	DS
end;

procedure NewSound; assembler;
asm
	MOV	AL,[SonOn]
        OR	AL,[SoundEnable]
        JZ	@exit
	MOV	AX,[Channel]
	OR	AL,$A0
        CALL	WritePort
        OR	AL,$10
        CALL	WritePort
        MOV	BX,[Note]
        SHL	BX,1
        MOV	BX,WORD PTR [NoteFreq+BX]
        AND	AL,$AF
        MOV	AH,BL
        CALL	WritePort
        OR	AL,$10
        MOV	AH,[Octave]
        SHL	AH,2
        OR	AH,BH
        CALL	WritePort
@exit:
end;

procedure ClearSound; assembler;
asm
	MOV	AL,[SonOn]
        OR	AL,[MusicOn]
        JZ	@exit
        XOR	AX,AX
        MOV	CX,9
@Loop:	OR	AL,$A0
        CALL	WritePort
        OR	AL,$10
        CALL	WritePort
	INC	AL
        LOOP	@Loop
@exit:
end;

procedure CloseSound;
var
  InsNul: TIns;
  i: Byte;
begin
  if not SoundEnable then exit;
  ClearSound;
  fillChar (InsNul, 11, 0);
  for i := 0 to 8 do SetChannelIns (i, InsNul);
  asm
  	XOR	AX,AX
        MOV	CX,225
  @Loop:CALL	WritePort
  	INC	AL
        LOOP	@Loop
  end;
end;

end.

