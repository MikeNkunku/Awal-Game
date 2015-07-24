%/Main predicate/%
tourPlateau(J1,J2,P1,P2,P1Fin,P2Fin,CasePriseGraines,GrainesRamassees) :- nombreGrainesDansCase(CasePriseGraines,P1,NbGrDistrib),
																			siPremiereDistributionPossible(J1,J2,P1,P2,P1Fin,P2Fin,CasePriseGraines,NbGrDistrib,GrainesRamassees).

%/Distribution calculation/%
siPremiereDistributionPossible(_,_,P1,P2,P1,P2,_,0,0):- !.
siPremiereDistributionPossible(J1,J2,P1,P2,P1Fin,P2Fin,CasePriseGraines,NbGrDistrib,GrainesRamassees):- NbGrDistrib\==0,!,distribuerSurPlateau(0,CasePriseGraines,NbGrDistrib,P1,NewP1,_,NbGrainesResttes),
																										siDeuxiemeDistributionPossible(J2,J1,P2,NewP1,P2Fin,P1Fin,NbGrainesResttes,GrainesRamassees).
%/
	If seeds number to distribute is greater than the number of cases to travel on current user board, then the remnant of seeds are distributed on
	the other player's board
/%
siDeuxiemeDistributionPossible(_,_,P2,NewP1,P2,NewP1,0,0):- !.
siDeuxiemeDistributionPossible(J2,J1,P2,NewP1,P2Fin,P1Fin,NbGrainesResttes,GrainesRamassees):-  NbGrainesResttes\==0,!,distribuerSurPlateau2(J2,J1,P2,NewP1,NbGrainesResttes,CaseA,P2AvtRamasse,P1Fin,Ja),
																								calculerNombreDeGrainesRamassees(J1,Ja,P2AvtRamasse,P2Fin,CaseA,GrainesRamassees).
%/Distribution on other player's board/%
distribuerSurPlateau2(J2,J1,P2,P1,NbGraines,CaseArrivee,NvP2,NvP1,JoueurArr) :-	distribuerSurPlateau(1,1,NbGraines,P2,NewP2,CaseArr,NbGrainesReste),
																				siDistributionEncorePossible(J1,J2,P1,NewP2,NbGrainesReste,CaseArr1,NvP1,NvP2,JoueurArr),calculerCaseArrivee(CaseArr,CaseArr1,CaseArrivee).
%/If a second distribution is still not enough, the process is repeated once again/%
siDistributionEncorePossible(_,J2,P1,P2,0,_,P1,P2,J2):- !.
siDistributionEncorePossible(J1,J2,P1,P2,NbGrainesReste,CaseArr,Plat1,Plat2,Ja):- NbGrainesReste\==0,distribuerSurPlateau2(J1,J2,P1,P2,NbGrainesReste,CaseArr,Plat1,Plat2,Ja).

%/if Case2 is defined, it becomes the final destination/%
calculerCaseArrivee(_,Case2,CaseFin):- nonvar(Case2),!,CaseFin is Case2.

%/Otherwise, the final compartment is on the other board : therefore, the compartment number must be reversed/%
calculerCaseArrivee(Case1,_,CaseFin):- CaseFin is 1-Case1,!.

%/The list representing the board is browsed until head list matches the compartment where seeds need to be recovered from/%
nombreGrainesDansCase(Case, [_|Q], NbGraines) :- Case\==1,!,NouvCase is Case-1, nombreGrainesDansCase(NouvCase,Q, NbGraines).
nombreGrainesDansCase(1,[NbGraines|_], NbGraines):- !.

%/
	In order to calculate the number of seeds, the list needs to be reversed so as to respect the recursion implied by Awalé rule : it's indeed
	possible to recover several seeds in one shot.
/%
calculerNombreDeGrainesRamassees(J1,J1,P2,P2,_,0):- !.
calculerNombreDeGrainesRamassees(_,_,P2,NewP2,CaseDepart,GrainesRamassees):-  inverse(P2,P2Inverse), CaseDep is 7-CaseDepart,recuperationGraines(P2Inverse, CaseDep, NewP2Invers, GrainesRamassees),inverse(NewP2Invers,NewP2).

%/Predicate to reverse a list/%
inverse([],[]):- !.
inverse([T|Q],NouvListe) :- inverse(Q,R), append(R,[T],NouvListe).

%/Stop condition/%
recuperationGraines([],_, [], 0):- !.

%/Enables recursion by discarding useless head list/%
recuperationGraines([T|Q], CaseCourante, [T|N], GrainesRamassees):- CaseCourante > 1,!,NewCase is CaseCourante-1,recuperationGraines(Q, NewCase, N, GrainesRamassees).

%/Case where player recovers no seeds/%
recuperationGraines([T|Q], 1, [T|Q], 0):- T > 3 ; T < 2 .

%/Case where player recovers seeds/%
recuperationGraines([T|Q], 1, [0|V], GrainesRamassees):- recuperationGraines(Q, 0, V, AncienNbGraine),!,GrainesRamassees is AncienNbGraine + T.
recuperationGraines([T|Q], CaseCourante, [0|V], GrainesRamassees):- CaseCourante < 1,T > 1,T < 4,!,NewCase is CaseCourante-1,recuperationGraines(Q, NewCase, V, AncienNbGraine),!,GrainesRamassees is AncienNbGraine + T.
recuperationGraines([T|Q], CaseCourante, [T|Q], 0):- CaseCourante < 1,T < 2 ; T > 3 .

%/Distribution predicate/%
distribuerSurPlateau(_,CaseCrte,NbGrDistrib,Plateau,Plateau,CaseA,NbGrR):-NbGrDistrib==0,!,CaseA is CaseCrte,NbGrR is NbGrDistrib.
distribuerSurPlateau(_,_,NbGrDistrib,[],[],CaseA,NbGrR):-CaseA is -99,NbGrR is NbGrDistrib,!.
distribuerSurPlateau(Prise,CaseCrte,NbGrDistrib,[T|Q],[T|M],CaseArr,NbGrRestantes):- CaseCrte>1,!,NewCase is CaseCrte-1,distribuerSurPlateau(Prise,NewCase,NbGrDistrib,Q,M,CaseArr,NbGrRestantes).
distribuerSurPlateau(Prise,CaseCrte,NbGrDistrib,[T|Q],[N|M],CaseArr,NbGrRestantes):- CaseCrte==1,!,distribution(Prise,N,T),siGraines(Prise,NbGr,NbGrDistrib),NewCase is CaseCrte-1,distribuerSurPlateau(Prise,NewCase,NbGr,Q,M,CaseArr,NbGrRestantes).
distribuerSurPlateau(Prise,CaseCrte,NbGrDistrib,[T|Q],[P|M],CaseArr,NbGrRestantes):- CaseCrte<1,!,P is T+1,NewCase is CaseCrte-1,NewNbGraine is NbGrDistrib-1,distribuerSurPlateau(Prise,NewCase,NewNbGraine,Q,M,CaseArr,NbGrRestantes).

%/Predicate to increment from 1 the number of seeds in each compartment concerned by redistribution/%
distribution(Prise,Compte,_):- Prise==0,!,Compte is 0.
distribution(_,Compte,T):- Compte is T+1.

%/Predicate to decrease the number of remaining seeds to be distributed/%
siGraines(Prise,NbGr,NbGrD):- Prise==0,!,NbGr is NbGrD.
siGraines(_,NbGr,NbGrD):- NbGr is NbGrD-1.


%/Predicate for game management/%
afficherPlateau(P1,P2):-write('Plateau Joueur1 : '),write(P1),nl,write('Plateau Joueur2 : '),write(P2),nl,nl.
afficherScore(S1,S2):-write('Score Joueur1 : '),write(S1),nl,write('Score Joueur2 : '),write(S2),nl,nl.

%/Predicate to make a player play/%
tourJoueur1(Pj1,Pj2,Sj1,_,Pj1fin,Pj2fin,Nsj1):- write('Tour du Joueur1 : '),read(CaseJ1),nl,
												tourPlateau('humain1','humain2',Pj1,Pj2,Pj1fin,Pj2fin,CaseJ1,Nb),Nsj1 is Sj1 + Nb.
tourJoueur2(Pj2,Pj1,Sj2,_,Pj2fin,Pj1fin,Nsj2):- write('Tour du Joueur2 : '),read(CaseJ2),nl,
												tourPlateau('humain2','humain1',Pj2,Pj1,Pj2fin,Pj1fin,CaseJ2,Nb),Nsj2 is Sj2 + Nb.

%/Game stop condition: the score of one of the participants is greater or equal to 24 or one board is empty/%
tourJeu2P(_,_,SL1,_):-SL1>24,write('Partie terminee !'),nl,write('Victoire de Joueur1 !'),!.
tourJeu2P(_,_,_,SL2):-SL2>24,write('Partie terminee !'),nl,write('Victoire du Joueur2 !'),!.
tourJeu2P([0,0,0,0,0,0],_,_,_):-write('Partie terminee !'),!.
tourJeu2P(_,[0,0,0,0,0,0],_,_):-write('Partie terminee !'),!.

%/Predicate enabling 2 players to play/%
tourJeu2P(PL1,PL2,SL1,SL2):-inverse(PL2,NPL2),afficherPlateau(PL1,NPL2),afficherScore(SL1,SL2),tourJoueur1(PL1,PL2,SL1,SL2,PL1i,PL2i,SL1f),inverse(PL2i,NPL2i),afficherPlateau(PL1i,NPL2i),afficherScore(SL1f,SL2),tourJoueur2(PL2i,PL1i,SL2,SL1f,PL2f,PL1f,SL2f),tourJeu2P(PL1f,PL2f,SL1f,SL2f).

%/Predicate to launch a 2-Players game/%
%/go2J:- tourJeu2P([4,4,4,4,4,4],[4,4,4,4,4,4],0,0)./%
go2J:- tourJeu2P([0,0,0,0,0,1],[1,4,4,4,4,1],24,0).

%/Predicate for game management when player plays against AI/%
afficherPlateauJIA(P1,PIA):-write('Plateau du joueur : '),write(P1),nl,write('Plateau de IA     : '),write(PIA),nl,nl.
afficherScoreJIA(S1,SIA):-write('Score Joueur : '),write(S1),nl,write('Score IA     : '),write(SIA),nl,nl.

%/Predicates for a game opposting player to AI/%
tourJoueur(Pj1,PIA,Sj1,_,Pj1fin,PIAfin,Nsj1):- write('Tour du joueur : '),read(CaseJ),nl,
												tourPlateau('Humain','IA',Pj1,PIA,Pj1fin,PIAfin,CaseJ,Nb),Nsj1 is Sj1 + Nb.
tourIA(PIA,Pj1,SIA,_,PIAfin,Pj1fin,NsIA):- write('Tour de IA ... '),nl,random(1,6,CaseIA),
												tourPlateau('IA','Humain',PIA,Pj1,PIAfin,Pj1fin,CaseIA,Nb),NsIA is SIA + Nb.

%/Game is over either when AI's or the player's score is equal or greater than 24, or one board is empty./%
tourJeu1P(_,_,SL1,_):-SL1>24,write('Partie terminee !'),nl,write('Victoire du Joueur !'),!.
tourJeu1P(_,_,_,SLIA):-SLIA>24,write('Partie terminee !'),nl,write('Victoire de IA !'),nl,write('Tu auras peut-etre plus de chance la prochaine fois, joueur !'),!.
tourJeu1P([0,0,0,0,0,0],_,_,_):-write('Partie terminee !'),!.
tourJeu1P(_,[0,0,0,0,0,0],_,_):-write('Partie terminee !'),!.

%/Predicate for only one player/%
tourJeu1P(PL1,PLIA,SL1,SLIA):-inverse(PLIA,NPLIA),afficherPlateauJIA(PL1,NPLIA),afficherScoreJIA(SL1,SLIA),tourJoueur(PL1,PLIA,SL1,SLIA,PL1i,PLIAi,SL1f),inverse(PLIAi,NPLIAi),afficherPlateauJIA(PL1i,NPLIAi),afficherScoreJIA(SL1f,SLIA),tourIA(PLIAi,PL1i,SLIA,SL1f,PLIAf,PL1f,SLIAf),tourJeu1P(PL1f,PLIAf,SL1f,SLIAf).


%/Predicate to launch a 1-Player game/%
go1J:-tourJeu1P([4,4,4,4,4,4],[4,4,4,4,4,4],0,0).
%/go1J:- tourJeu1P([0,0,0,0,0,1],[1,4,4,4,4,1],24,0)./%

%/Predicate to launch a 1- or 2-Players game/%
game(1):-nl,write('J1 VS IA ... GO !'),nl,go1J,!.
game(2):-nl,write('J1 VS J2 ... GO !'),nl,go2J,!.
game(_):-nl,write('Reponse incorrecte !'),!,fail.

%/Predicate to start a game./%
jeu:-write('Bienvenue dans notre version du jeu Awale !'),nl,nl,write('Combien de joueurs ? (1 ou 2) : '),read(NB),game(NB).