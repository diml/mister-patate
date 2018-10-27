
{ Programme de lancement }
program MisterPatate;

{ unit‚s n‚scessaires }
uses MrpInit, MrpMenu, MrpJeu;

begin
  { Initialise le programme }
  Init;

  { Debut du jeu }
  repeat

    { Lance les menus }
    InitMenu;
    Menu (Principal);

    { Puis lance le jeu }
    Jouer;

  until False;
end.
