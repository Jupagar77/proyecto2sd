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
-export([tablaSimbolos/1]).

-export([compress/1]).
-export([findCode/2]).
-export([toCode/2]).
%-export([toBytes/1]).
-export([countValues/1]).
-export([completeByte/1]).
-export([decompress/1]).
-export([removeRepeated/2]).

%COMPRESOR

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

removeRepeated([],_S)->[];
removeRepeated([H|T],H)->removeRepeated(T,H);
removeRepeated([H|T],S)->[H]++removeRepeated(T,S).

getSymbolsNumber([])->[];
getSymbolsNumber([H|T])->Number = countSymbol(H,T) ,
						 %io:fwrite("~9..0B |~10w| ~9..0B ~n", [trunc(N), H, Number]), 
						 %Old = T -- generateList(H,Number), bajo performance
						 New = removeRepeated(T,H),
						 [[1 + Number|H]] ++ getSymbolsNumber(New).

%Generar arbol a partir de lista de simbolos:
%Ordenar lista generada por getSymbolsNumber de mayor a menor segun la Frecuencia. Basado en Quicksort
sortAscending([]) -> [];
sortAscending([[Pivot|Char]|T]) -> sortAscending([[X|Y] || [X|Y] <- T, X < Pivot]) ++ [[Pivot|Char]] ++ sortAscending([[X|Y] || [X|Y] <- T, X >= Pivot]).

crearListaArboles([]) -> [];
crearListaArboles(L) -> crearListaArboles(L,[]).
crearListaArboles([],Aux) -> Aux;
crearListaArboles([[F|E]|T],Aux) -> Laux = Aux ++ [{[F|E],{},{}}], crearListaArboles(T,Laux).

sortAscendingArboles([]) -> [];
sortAscendingArboles([{[Pivot|Char],I,D}|T]) -> sortAscendingArboles([{[X|Y],I,D} || {[X|Y],I,D} <- T, X < Pivot]) ++ 
												[{[Pivot|Char],I,D}] ++ 
												sortAscendingArboles([{[X|Y],I,D} || {[X|Y],I,D} <- T, X >= Pivot]).
huffman([]) -> [];
huffman([Arb|[]]) -> Arb;
huffman([{[F1|E1],I1,D1},{[F2|E2],I2,D2}|[]]) 
	-> Suma = F1+F2, NuevaRaiz = [Suma|null], {NuevaRaiz,{[F1|E1],I1,D1},{[F2|E2],I2,D2}};
huffman([{[F1|E1],I1,D1},{[F2|E2],I2,D2}|T])
	-> Suma = F1+F2, NuevaRaiz = [Suma|null], Arb = {NuevaRaiz,{[F1|E1],I1,D1},{[F2|E2],I2,D2}},
	ListaActualizada = [Arb] ++ T, huffman(sortAscendingArboles(ListaActualizada)).

tablaSimbolos({})->[];
tablaSimbolos(Arb) -> tablaSimbolos(Arb,[]).
tablaSimbolos({[_F|E],{},{}},Path) -> [[E,Path]];
tablaSimbolos({_R,I,D},Path) -> tablaSimbolos(I,Path++[0])++tablaSimbolos(D,Path++[1]).

findCode(_S,[])->[];
findCode(S,[[Symbol,Code]|_T]) when Symbol == S -> Code;
findCode(S,[_H|T])-> findCode(S,T).

toCode([],_T)->[];
toCode([H|T],Table)-> findCode(H,Table) ++ toCode(T,Table).

countValues([])->0;
countValues([_H|T])->countValues(T)+1.
completeByte(L)->completeByte(L,countValues(L)).
completeByte(L,X) when X > 7->L;
completeByte(L,_X)-> completeByte(L ++ [0],countValues(L)+1).

%toBytes(L)-> toBytes(L,8,[]).
%toBytes([],_N,Acum)->[completeByte(Acum)];
%toBytes([H|T],1,Acum)-> [Acum ++ [H]] ++ toBytes(T,8,[]);
%toBytes([H|T],N,Acum)-> toBytes(T,N-1,Acum++[H]).

compress(F) -> BinList = getBinaryToList(F), 
			   Tabla = tablaSimbolos(huffman(crearListaArboles(sortAscending(getSymbolsNumber(BinList))))),
			   Code = toCode(BinList,Tabla),
			   Compress = [Code, Tabla, filename:extension(F)],
			   file:write_file(filename:rootname(F),erlang:term_to_binary(Compress)),
			   Compress.


%DECOMPRESOR

decompress(F)->erlang:binary_to_term(getFileContent(F)).