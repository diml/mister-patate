
{ Routine pour le temps }
unit MrpTps;

interface

uses MrpStr, MrpSon, MrpLoad;

var
  { Nombre de dixiŠme de seconde ‚coul‚ depuis minuit }
  Timer: LongInt absolute $0040:$006C;
  { Compteur }
  Counter: Word;
  CounterSound: Byte;
  CounterMusic: Byte;

{ Fait une pause de 'Temps' millisecondes }
procedure Pause (Temps: Word);

{ Donne HH:MM:SS }
function GetHeure: String;

{ Active le compteur }
procedure CounterOn;

{ D‚sactive le compteur }
procedure CounterOff;

implementation

var
  OldInt8: procedure;
  CounterInt8: Boolean;

procedure Pause;
begin
  Counter := 0;
  while (Counter < Temps) do;
end;

function GetHeure;
var
  Heure, Minute, Seconde: Byte;
begin
  	asm
        MOV	AH,2Ch
        INT	21h
	MOV	Heure,CH
	MOV	Minute,CL
	MOV	Seconde,DH
        end;
  GetHeure := Str (Heure, 2) + ':' + Str (Minute, 2) + ':' + Str (Seconde, 2);
end;

procedure CounterOn; assembler;
asm
	MOV	AX,$3508
        INT	$21
        MOV	[CounterInt8],6
        MOV	[CounterSound],20
	MOV 	WORD PTR [OldInt8],BX
	MOV 	WORD PTR [OldInt8+2],ES
        PUSH	DS
        MOV	AX,SEG @NewInt8
        MOV	DS,AX
        MOV	DX,OFFSET @NewInt8
        MOV	AX,$2508
        INT	$21
        POP	DS
        MOV	AL,$34
        OUT	$43,AL
        MOV	AL,$C3
        OUT	$40,AL
        MOV	AL,$2A
        OUT	$40,AL
	JMP	@exit
@NewInt8:
        PUSH	DS
        PUSH	AX
        MOV	AX,SEG @Data
        MOV	DS,AX
        TEST	[SoundEnAble],$FF
        JZ      @NI1
        TEST	[SonOn],$FF
        JZ      @NI0
	TEST	[BonnusMusic.EnAble],$FF
	JZ	@NI0
        DEC	[CounterSound]
        JNZ	@NI0
        MOV	AL,[BonnusMusic.Pas]
        MOV	[CounterSound],AL
        PUSH	CX
        PUSH	DX
        PUSH	BX
        MOV	DX,$388
        MOV	BX,[BonnusMusic.OfsSound]
        MOV	BL,[BX]
        CMP	BL,15
        JNE	@NI4
        MOV	[BonnusMusic.EnAble],0
        JMP	@NI5
@NI4:	INC	[BonnusMusic.OfsSound]
        MOV	AL,$A4
        CALL	@JoueNote
@NI5:	POP	BX
        POP	DX
        POP	CX
@NI0:   TEST	[MusicOn],$FF
        JZ      @NI1
	TEST	[Music.EnAble],$FF
        JZ	@NI1
	DEC	[CounterMusic]
        JNZ	@NI1
        MOV	AL,[Music.Pas]
        MOV	[CounterMusic],AL
        PUSH	CX
        PUSH	DX
        PUSH	BX
        PUSH	SI
        MOV	DX,$388
	MOV	SI,[Music.OfsSound]
        MOV	BL,[SI]
        MOV	AL,$A0
        CALL	@JoueNote
        MOV	BL,[SI+1024]
        MOV	AL,$A1
        CALL	@JoueNote
        MOV	BL,[SI+2048]
        MOV	AL,$A2
        CALL	@JoueNote
        MOV	BL,[SI+3072]
        MOV	AL,$A3
        CALL	@JoueNote
        INC	SI
	CMP	[SI].Byte,15
        JNE	@NI6
        MOV	SI,OFFSET [MusicNote]
@NI6:	MOV	[Music.OfsSound],SI
        POP	SI
        POP	BX
        POP	DX
        POP	CX
@NI1:   DEC	[CounterInt8]
        JZ	@NI3
        MOV	[CounterInt8],6
	PUSHF
        CALL	[OldInt8]
@NI3:	INC	[Counter]
	MOV	AL,$20
        OUT	$20,AL
        POP	AX
        POP	DS
	IRET
@JoueNote:
        CMP	BL,-1
        JE	@JN0
        XOR	AH,AH
        CALL	@SND0
        OR	AL,$10
        CALL	@SND0
        AND	AL,$AF
        CMP	BL,$F0
        JE      @JN0
        MOV	AH,BL
        AND	AH,$F0
        SHR	AH,2
        AND	BX,$000F
        SHL	BX,1
        MOV	BX,WORD PTR [NoteFreq+BX]
        OR	BH,AH
        MOV	AH,BL
        CALL	@SND0
        MOV	AH,BH
        OR	AL,$10
        CALL	@SND0
        AND	AL,$AF
@JN0:	RETN
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
@exit:
end;

procedure CounterOff; assembler;
asm
	PUSH	DS
        LDS	DX,[OldInt8]
        MOV	AX,DS
        OR	AX,DX
        JZ	@exit
        MOV	AX,$2508
        INT	$21
@exit:  POP	DS
end;

end.