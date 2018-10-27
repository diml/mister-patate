
{ Commence Mister Patate et le termine }
unit MrpInit;

interface

uses MrpText, MrpVga, MrpStr, MrpKey, MrpSon, MrpLoad, MrpPal, MrpTps;

var
  { Handle de la m‚moire Ems }
  HandleEms: Word;

  { Erreur d'initialisation }
  InitError: Byte;

{ D‚bute mister patate }
procedure Init;

{ Termine le programme en affichant un message d'erreur }
procedure Erreur (Quand, Cause: String);

{ V‚rifi‚ si la m‚moire est suffisante }
procedure TestAlloue (Taille: Word);

{ Alloue un segment }
procedure AlloueBuffer (var p: PtrBuffer);

{ Ouvre en v‚rifiant l'existence d'un fichier }
function Ouvre (Fichier: String; var Handle: File; TailleEnr: Word): Boolean;

{ Fin de mister patate }
procedure Fin;

{ Pour la m‚moire EMS }
function InitEms (var p: PtrBuffer): Byte;

implementation

const
  { Texte pour v‚rifi‚ la pr‚sence du driver EMS }
  EmsAble: array[0..7] of Char = 'EMMXXXX0';

  NoDriver    = 1;
  NoEnoughEms = 2;

function InitEms; assembler;
asm
	XOR	AX,AX
        MOV	ES,AX
        MOV	ES,ES:[$019E]
        MOV	DI,10
        MOV	SI,OFFSET [EmsAble]
        MOV	CX,8
        REPE	CMPSB
        MOV	AX,NoDriver
        JNE	@Exit
	MOV	AH,$42
        INT	$67
        MOV	AL,NoEnoughEms
        CMP	BX,4
        JB	@Exit
        MOV	AH,$43
        MOV	BX,4
        INT	$67
        MOV	[HandleEms],DX
        MOV	AH,$41
        INT	$67
        LES	DI,[p]
        MOV	ES:[DI+2],BX
        MOV	DX,[HandleEms]
        XOR	BX,BX
        XOR	AL,AL
@Label1:MOV	AH,$44
        INT	$67
        INC	BX
        INC	AL
        CMP	AL,4
        JNE	@Label1
        XOR	AL,AL
@Exit:
end;

procedure ReleaseEms; assembler;
asm
	MOV	AH,$45
        MOV	DX,[HandleEms]
        INT	$67
end;

{ Fin de Mister Patate }
procedure Fin;
begin
  { Rend la m‚moire EMS si elle est allou‚e }
  if HandleEms <> 0 then ReleaseEMS;

  { Passe en mode texte si non fait, sinon retourne … la ligne }
  if GetMode <> $03 then InitTexte else Retour;

  { D‚sinstalle le compteur }
  CounterOff;

  { Arrˆte la musique }
  CloseSound;

  { Arrˆte le HP }
  StopSon;

  { Remet l'ancienne interruption du clavier }
  KBHoff;

  { Si le code de sortie est diff‚rent de 0, }
  { alors une erreurs c'est produites        }
  if ExitCode <> 0 then begin
    PrintR ('Erreur d''‚x‚cution nø' + StrHexa (ExitCode, 2) + 'h … ' + PtrToStr (ErrorAddr) + '.', 12);
    Beep;
  end;

  { Termine le programme }
  Halt;
end;

{ Ouvre un fichier et renvoie FALSE s'il n'existe pas }
function Ouvre;
begin
  assign (Handle, Fichier);
  {$I- Ouvre le fichier en lecture }
  reset (Handle, TailleEnr);
  {$I+ Si IOResult = 0, le fichier existe }
  Ouvre := IOResult = 0;
end;

procedure TestAlloue;
begin
  { Si la m‚moire est insuffisante, alors on quitte }
  if MemAvail < Taille then Erreur ('l''allocation de m‚moire', 'M‚moire libre insuffisante.');
end;

procedure AlloueBuffer;
begin
  { Si la m‚moire est insuffisante, alors on quitte }
  if MemAvail < $10000 then begin
    if HandleEms = 0 then case InitEms (p) of
      NoDriver: Erreur ('l''allocation de m‚moire EMS','Driver EMS non pr‚sent.');
      NoEnoughEms: Erreur ('l''allocation de m‚moire EMS','M‚moire EMS insuffisante.');
    end else Erreur ('l''allocation de m‚moire', 'M‚moire libre insuffisante.');
  end else GetMem (p, $FFFF);
end;

{ Initialisation de Mister Patate }
procedure Init;
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

PrintR ('Chargement des sprites.', 7);
  LoadSprite;

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

PrintR ('Initialisation de la carte son.', 7);
  if not InitSound then begin
    PrintR ('Carte son non pr‚sente ou driver non install‚.', 14);
    inc (InitError);
  end else SetVolumeSon;



  if InitError > 0 then Pause (InitError * 200);

  { Passe en mode VGA }
  InitVga;
end;

procedure Erreur;
begin
  { Passe en mode texte si non fait, sinon retourne … la ligne }
  if GetMode <> $03 then InitTexte else Retour;

  { Affiche un message }
  Print ('Une erreur c''est produite lors de ', 12);
  PrintR (Quand, 14);
  Print ('À> ', 15);
  PrintR (Cause, 7);
  Beep;

  { Attend l'appuie sur une touche }
  repeat until KeyPress;

  { Termine le programme }
  Halt;
end;

end.