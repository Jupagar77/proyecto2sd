-module(p2).
-export([getFileContent/1]).
-export([getBinaryToList/1]).
-export([getSymbolsNumber/1]).
-export([countSymbol/2]).
-export([generateList/2]).

-export([sortAscending/1]).

-export([crearListaArboles/1]).
-export([sortAscendingArboles/1]).

-export([huffman/1]).

%https://stackoverflow.com/questions/14447575/reading-file-whole-flat-text-file-to-an-array

%Leer contenido de archivo a binario:
getFileContent(Filename) -> {ok, Text} = file:read_file(Filename), Text.

%Pasar archivo de binario a lista:
getBinaryToList(Filename) -> binary:bin_to_list(getFileContent(Filename)). %list_to_bin

%Obtener la tabla de simbolos de una lista:
generateList(_X,0)->[];
generateList(X,N)->[X]++generateList(X,N-1).
countSymbol(_X,[])->0;
countSymbol(X,[X|T])->1 + countSymbol(X,T);
countSymbol(X,[_H|T])->countSymbol(X,T).
getSymbolsNumber([])->[];
getSymbolsNumber([H|T])->Number = countSymbol(H,T) , [[1 + Number|H]] ++ 
								  getSymbolsNumber(T--generateList(H,Number)).

%Generar arbol a partir de lista de simbolos:


%Ordenar lista generada por getSymbolsNumber de mayor a menor segun la Frecuencia. Basado en Quicksort
sortAscending([]) -> [];
sortAscending([[Pivot|Char]|T]) -> sortAscending([[X|Y] || [X|Y] <- T, X < Pivot]) ++ [[Pivot|Char]] ++ sortAscending([[X|Y] || [X|Y] <- T, X >= Pivot]).


crearListaArboles([]) -> [];
crearListaArboles(L) -> crearListaArboles(L,[]).
crearListaArboles([],Aux) -> Aux;
crearListaArboles([[F|E]|T],Aux) -> Laux = Aux ++ [{[F|E],{},{}}], crearListaArboles(T,Laux).


sortAscendingArboles([]) -> [];
sortAscendingArboles([{[Pivot|Char],I,D}|T]) -> sortAscendingArboles([{[X|Y],I,D} || {[X|Y],I,D} <- T, X < Pivot]) ++ [{[Pivot|Char],I,D}] ++ sortAscendingArboles([{[X|Y],I,D} || {[X|Y],I,D} <- T, X >= Pivot]).

huffman([]) -> [];
huffman([Arb|[]]) -> Arb;
huffman([{[F1|E1],I1,D1},{[F2|E2],I2,D2}|[]]) 
	-> Suma = F1+F2, NuevaRaiz = [Suma|null], {NuevaRaiz,{[F1|E1],I1,D1},{[F2|E2],I2,D2}};
huffman([{[F1|E1],I1,D1},{[F2|E2],I2,D2}|T])
	-> Suma = F1+F2, NuevaRaiz = [Suma|null], Arb = {NuevaRaiz,{[F1|E1],I1,D1},{[F2|E2],I2,D2}},
	ListaActualizada = [Arb] ++ T, huffman(sortAscendingArboles(ListaActualizada)).





