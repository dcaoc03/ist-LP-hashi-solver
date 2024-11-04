% ist1103179, Diogo Cabral Antunes de Oliveira Costa

% Projeto LP 2021/2022: Solucionador de Puzzles Hashi

% 2.1: extrai_ilhas_linha/3
/* extrai_ilhas_linha(N_L, Linha, Ilhas): recebe o inteiro N_L correspondente ao numero da 
lista, a lista Linha, representacao da linha do puzzle correspindente a N_L, e Ilhas, uma 
lista ordenada das ilhas da linha, ou seja, os elementos diferetes de 0. As ilhas aparecem 
na lista sob a forma 'ilha(N_P, (N_L, N_C))', em que N_P e o numero de pontes que essa ilha 
deve ter, N_L e o numero da ilha em que se insere e N_C e o numero da coluna em que se insere. */

extrai_ilhas_linha(N_L, Linha, Ilhas) :-
	findall(ilha(P, (N_L,C)),
	(nth1(C, Linha, P), P =\= 0),
	Ilhas).


% 2.2: ilhas/2
/* ilhas(Puzzle, Ilhas): recebe um Puzzle, uma lista de listas correspondentes as varias linhas, 
e as Ilhas, resultantes de aplicar o predicado extrai_ilhas_linha(N_L, Linha, Ilhas) a cada
linha do puzzle. */ 

ilhas(Puz,Ilhas) :- ilhas(1,Puz,Ilhas).
ilhas(_,[],[]).
ilhas(N_L,[L1|Res_Puz],IlhasTotal) :-
	extrai_ilhas_linha(N_L,L1,Ilhas_L1),
	NovoN_L is N_L+1,
	ilhas(NovoN_L,Res_Puz,Res_ilhas),
	append(Ilhas_L1,Res_ilhas,IlhasTotal).


% 2.3: vizinhas/3
/* vizinhas(Ilhas, Ilha, Vizinhas): recebe um conjunto de ilhas de um puzzle, uma ilha especifica
 desse puzzle e uma lista correspondente as ilhas vizinhas, ordenadas segundo a sua posicao,
dessa ilha especifica. As vizinhas de uma ilha_x correspondem as outras ilhas que se encontram
 na mesma coluna ou linha da ilha_x e que entre elas nao exista um obstaculo, seja uma ponte
ou outra ilha. */

vizinhas(Ilhas, Ilha, Vizinhas) :-
	vizinhas1(Ilhas, Ilha, V1),
	vizinhas2(Ilhas, Ilha, V2),
	vizinhas3(Ilhas, Ilha, V3),
	vizinhas4(Ilhas, Ilha, V4),
	append([V1, V2, V3, V4], Vizinhas).

/* predicados auxiliares quebra/2 e quebra2/2: quebra/2 obtem o ultimo elemento de uma lista; 
quebra2/2 obtem o primeiro elemento de uma lista. */

quebra([], []).
quebra([E], [E]) :- !.
quebra([_|R], Aux) :-
	quebra(R, Aux).

quebra2([], []).
quebra2([P|_], [P]).

/* predicados auxiliares vizinhas1/3, vizinhas2/3, vizinhas3/3, vizinhas4/3: obtem as ilhas
 vizinhas de uma ilha especifica que se encontrem em cima, a esquerda, a direita ou em baixo 
da ilha escolhida, respetivamente. */

vizinhas1(Ilhas, ilha(_, (L,C)), V1) :-
	findall(ilha(P, (L1, C)), (member(ilha(P, (L1, C)), Ilhas), L1 < L), V1_I),
	quebra(V1_I, V1).

vizinhas2(Ilhas, ilha(_, (L,C)), V2) :-
	findall(ilha(P, (L, C1)), (member(ilha(P, (L, C1)), Ilhas), C1 < C), V2_I),
	quebra(V2_I, V2).

vizinhas3(Ilhas, ilha(_, (L,C)), V3) :-
	findall(ilha(P, (L, C1)), (member(ilha(P, (L, C1)), Ilhas), C1 > C), V3_I),
	quebra2(V3_I, V3).

vizinhas4(Ilhas, ilha(_, (L,C)), V4) :-
	findall(ilha(P, (L1, C)), (member(ilha(P, (L1, C)), Ilhas), L1 > L), V4_I),
	quebra2(V4_I, V4).


% 2.4: estado/2
/* estado(Ilhas, Estado): recebe uma lista de ilhas de um puzzle e um o Estado correspondente 
a esse puzzle num determinado momento. Um Estado e uma lista de Entradas, em que cada entrada
corresponde a uma lista de 3 elementos em que o primeiro e uma ilha, o segundo e a lista de
 vizinhas dessa ilha e a terceira e a lista de pontes dessa ilha (no incio, a lista de pontes
e a lista vazia). */

estado(Ilhas, Estado) :-
	findall([X, Y, []], (member(X,Ilhas), vizinhas(Ilhas, X, Y)), Estado).


% 2.5: posicoes_entre/3
/* posicoes_entre(Pos1, Pos2, Posicoes): Pos1 e Pos2 sao duas posicoes que pertencem ou a 
mesma linha ou a mesma coluna, Posicoes e alista de posicoes entre elas as duas. Se Pos1 e 
Pos2 nao pertencerem a mesma linha ou coluna, o resultado e false. */

posicoes_entre((L,C1), (L,C2), Posicoes) :-
	sort([C1, C2], [Cmin, Cmax]),
	findall((L,X), (between(Cmin,Cmax,X), X \== Cmin, X \== Cmax), Posicoes).

posicoes_entre((L1,C), (L2,C), Posicoes) :-
	sort([L1, L2], [Lmin, Lmax]),
	findall((X,C), (between(Lmin,Lmax,X), X \== Lmin, X \== Lmax) , Posicoes).


% 2.6: cria_ponte/3
/* cria_ponte(Pos1, Pos2, Ponte): Pos1 e Pos2 sao duas posicoes que pertencem ou a mesma 
coluna ou a mesma linha, Ponte e uma ponte entre essas duas posicoes, em que a ponte e 
representada pela estrutura ponte(Pos1, Pos2). */

cria_ponte((L, C1), (L, C2), ponte((L, C1P), (L, C2P))) :-
	sort([C1, C2], [C1P, C2P]).

cria_ponte((L1, C), (L2, C), ponte((L1P, C), (L2P, C))) :-
	sort([L1, L2], [L1P, L2P]).


% 2.7: caminho_livre/5
/* caminho_livre(Pos1, Pos2, Posicoes, I, Vz): Pos1 e Pos2 sao duas posicoes, Posicoes e a 
lista ordenada de posicoes entre Pos1 e Pos2, I e uma ilha e Vz e uma vizinha de I. O predicado
devolve true se a adicao da ponte ponte(Pos1, Pos2) nao faz com que I e Vz deixem de ser vizinhas. */

caminho_livre(Pos1, Pos2, _, ilha(_, Pos1), ilha(_, Pos2)).
caminho_livre(Pos1, Pos2, _, ilha(_, Pos2), ilha(_, Pos1)).
caminho_livre(_, _, Posicoes, ilha(_, (LI, CI)), ilha(_, (LViz, CViz))) :-
	posicoes_entre((LI, CI), (LViz, CViz), Posicoes2),
	findall(P, (member(P, Posicoes), member(P, Posicoes2)), Els_em_comum),
	Els_em_comum == [].


% 2.8: actualiza_vizinhas_entrada/5
/* actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, Entrada, Nova_entrada): Pos1 e Pos2
correspondem a posicoes entre as quais sera adicionada uma ponte, Posicoes e a lista de 
posicoes ordenadas entre Pos1 e Pos2, Entrada e uma entrada de uma ilha e Nova_Entrada e
igual a Entrada, mas retirando a lista das vizinhas as ilhas que deixam de o ser devido
a adicao da ponte entre Pos1 e Pos2. */

actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes, [Ilha, Viz, Pontes], [Ilha, NovoViz, Pontes]) :-
	include(caminho_livre(Pos1, Pos2, Posicoes, Ilha), Viz, NovoViz).


% 2.9: actualiza_vizinhas_apos_ponte/4
/* actualiza_vizinhas_apos_ponte(Estado, Pos1, Pos2, NovoEstado): Estado e um estado de um puzzle,
Pos1 e Pos2 sao as duas posicoes entre as quais se vai adicionar uma ponte e NovoEstado corresponde
a atualizar a lista de vizinhas de todas as entradas do estado apos a adicao da ponte. */

actualiza_vizinhas_apos_pontes(Estado, Pos1, Pos2, NovoEstado) :-
	posicoes_entre(Pos1, Pos2, Posicoes),
	maplist(actualiza_vizinhas_entrada(Pos1, Pos2, Posicoes), Estado, NovoEstado).


% 2.10: ilhas_terminadas/2
/* ilhas_terminadas(Estado, Ilhas_term): Estado e um estado de um puzzle e Ilhas_term e a lista
das ilhas terminadas desse estado, ou seja, as ilhas as quais ja foram atribuidas todas as
pontes e cujo numero de pontes e diferente de 'X'. */

ilhas_terminadas(Estado, Ilhas_term) :-
	findall(ilha(N_P, Pos), (member([ilha(N_P, Pos), _, Pontes], Estado), N_P \== 'X',
	 length(Pontes, Comp_Pontes),  N_P =:= Comp_Pontes), Ilhas_term).


% 2.11: tira_ilhas_terminadas_entrada/3
/* tira_ilhas_terminadas_entrada(Ilhas_term, Entrada, NovaEntrada): Ilhas_term e a
lista de ilhas terminadas de um dado puzzle, Entrada e uma entrada desse puzzle e
NovaEntrada e igual a Entrada, excetuando a lista das vizinhas, a qual foram retiradas
as ilhas ja terminadas. */

tira_ilhas_terminadas_entrada(Ilhas_term, [Ilha, Viz, Pontes], [Ilha, NovoViz, Pontes]) :-
	subtract(Viz, Ilhas_term, NovoViz).


% 2.12: tira_ilhas_terminadas/3
/* tira_ilhas_terminadas(Estado, Ilhas_term, NovoEstado): Estado e um estado de um
puzzle, Ilhas_term e a lista de ilhas terminadas desse puzzle e NovoEstado resulta
de aplicar o predicado tira_ilhas_terminadas_entrada/3 a cada uma das entradas de
Estado. */

tira_ilhas_terminadas(Estado, Ilhas_term, Novo_estado) :-
	maplist(tira_ilhas_terminadas_entrada(Ilhas_term), Estado, Novo_estado).


% 2.13: marca_ilhas_terminadas_entrada/3
/* marca_ilhas_terminadas_entrada(Ilhas_term, Entrada, NovaEntrada): Ilhas_term e a
lista de ilhas terminadas de um certo estado, Entrada e uma entrada desse Estado e
NovaEntrada e a Entrada alterada: se a ilha da Entrada pertencer a Ilhas_term, o
numero de pontes da ilha sera substituido por 'X', caso contrario a entrada fica
igual. */

marca_ilhas_terminadas_entrada(Ilhas_term, Entrada, Nova_entrada) :-
	Entrada = [ilha(P, (L,C)), Viz, Pontes],
	member(ilha(P, (L,C)), Ilhas_term), !,
	Nova_entrada = [ilha('X', (L,C)), Viz, Pontes].

marca_ilhas_terminadas_entrada(Ilhas_term, Entrada, Entrada) :-
	Entrada = [Ilha, _, _],
	\+ member(Ilha, Ilhas_term), !.

	
% 2.14: marca_ilhas_terminadas/3
/* marca_ilhas_terminadas(Estado, Ilhas_term, Novo_estado): Estado e um estado de um
puzzle, Ilhas_term e a lista de ilhas terminadas desse puzzle e Novo_estado e o resultado
de aplicar o predicado marca_ilhas_terminadas_entrada/3 a cada uma das entradas do estado. */ 

marca_ilhas_terminadas(Estado, Ilhas_term, Novo_estado) :-
	maplist(marca_ilhas_terminadas_entrada(Ilhas_term), Estado, Novo_estado).


% 2.15: trata_ilhas_terminadas/2
/* trata_ilhas_terminadas(Estado, Novo_estado): Estado e um estado de um puzzle, Novo_estado
e o resultado de aplicar os predicados tira_ilhas_terminadas/3 e marca_ilhas_terminadas/3 a
Estado. */

trata_ilhas_terminadas(Estado, Novo_estado) :-
	ilhas_terminadas(Estado, Ilhas_term),
	tira_ilhas_terminadas(Estado, Ilhas_term, Novo_estado_inc),
	marca_ilhas_terminadas(Novo_estado_inc, Ilhas_term, Novo_estado).


% 2.16: junta_pontes/5
/* junta_pontes(Estado, Num_pontes, Ilha1, Ilha2, Novo_estado): Estado e um estado de um
puzzle, Ilha1 e Ilha2 sao duas ilhas do puzzle, Novo_estado e o resultado de acrescentar
a Estado o numero de pontes (1 ou 2) Num_pontes entre Ilha1 e Ilha2, aplicando tambem ao
estado os predicados actualiza_vizinhas_apos_pontes/4 e trata_ilhas_terminadas/2. */

% predicado auxilar adiciona_ponte/5
/* adiciona_ponte(Ilha1, Ilha2, Ponte, Num_pontes, Entrada, Nova_entrada): Ilha1 e Ilha2 sao
duas ilhas de um puzzle, Ponte e a ponte entre Ilha1 e Ilha2, Num_pontes e o numero de pontes
(1 ou 2) que se adiconara entre as ilhas 1 e 2, Entrada e uma entrada e Nova_entrada e Entrada
alterada da seguinte maneira: se a ilha da entrada for Ilha1 ou Ilha2, adiciona-se a lista de
pontes da entrada as novas pontes, caso contrario a entrada fica igual. */

adiciona_ponte(Ilha1, Ilha2, Ponte, 1, [Ilha, Viz, Pontes_antigas], [Ilha, Viz, Pontes_novas]) :-
	member(Ilha, [Ilha1, Ilha2]), !,
	append(Pontes_antigas, [Ponte], Pontes_novas).

adiciona_ponte(Ilha1, Ilha2, Ponte, 2, [Ilha, Viz, Pontes_antigas], [Ilha, Viz, Pontes_novas]) :-
	member(Ilha, [Ilha1, Ilha2]), !,
	append(Pontes_antigas, [Ponte, Ponte], Pontes_novas).

adiciona_ponte(_, _, _, _, Entrada, Entrada).

junta_pontes(Estado, Num_pontes, Ilha1, Ilha2, NovoEstado) :-
	Ilha1 = ilha(_, Pos1), Ilha2 = ilha(_, Pos2),
	cria_ponte(Pos1, Pos2, Ponte1),
	maplist(adiciona_ponte(Ilha1, Ilha2, Ponte1, Num_pontes), Estado, NovoEstado1),
	actualiza_vizinhas_apos_pontes(NovoEstado1, Pos1, Pos2, NovoEstado2),
	trata_ilhas_terminadas(NovoEstado2, NovoEstado).


	