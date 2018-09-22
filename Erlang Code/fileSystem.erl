-module(s).
-compile(export_all).
-import(lists, [nth/2, sublist/2, map/2, seq/2, append/2, append/1, member/2, filter/2 , max/1]).
-import(random, [seed/1, uniform/1]).
-import(string , [substr/3 , substr/2 , words/2, join/2]).

%Mortadela
%{Nombre, Tamaño, Contenido}

%START HERE
inicio() ->
    lists:map(fun(N) -> spawn(?MODULE, negro, [N]) end, lists:seq(1,5)),
    server().

%Mortadeleria
%Funcion encargada de iniciar el server
server() ->
    {ok, ListenSocket} = gen_tcp:listen(8008, [{active, true}]),
    dispatcher(ListenSocket, 1).

%Mortadelero
dispatcher(ListenSocket, N) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(?MODULE, dispatcher, [ListenSocket, N+1]),
    cliente(Socket, N).

%Cliente antes de sacar numero para la mortadela
%Los gramos de mortadela indican el id del cliente
cliente(Socket, N) ->
    receive
        {tcp, Socket, Msg} ->
            {Cmd , _} = parse(Msg),
            case Cmd of
                con ->  io:format("Hola, necesito ~p gramos de mortadela~n",[N*100]),
                        io:format("~p~n", [funcionRandomDeLaCosa()]),
                        Ke_Fasil = "OK ID " ++ integer_to_list(N) ++ "\n",
                        %TOTALMENTE NECESARIO EL KE FASIL
                        gen_tcp:send(Socket, Ke_Fasil),
                        Trabajador = sovietanthem(),
                        io:format("Trabajador ~p~n", [Trabajador]),
                        register(getUserName(N) , self()),
                        atiendeboludos(Socket, N, Trabajador);
                _Else -> gen_tcp:send(Socket, "Error: Cliente no conectado\n")
            end
    end,
    cliente(Socket, N).

%Cliente pidiendo MORTADELAMORTADELA
%Funcion encargada de recibir las solicitudes de los clientes
atiendeboludos(Socket, Boludo, Nigguh) ->
	receive {tcp, Socket, Msg} ->
            {Com , Args} = parse(Msg),
            if  Com == error -> gen_tcp:send(Socket, Args) , atiendeboludos(Socket, Boludo, Nigguh);
                true ->
                    Nigguh ! {boludo, Com, [Args], Boludo},
                    receive
                        {response} -> io:format("Cacona~n");
                        {error , Msg2} ->
                            io:format("ERROR ~p~n", [Msg2]),
                            gen_tcp:send(Socket, "ERROR " ++ Msg2 ++ "\n"),
                            atiendeboludos(Socket, Boludo, Nigguh);
                        {ok , Msg2} ->
                            io:format("OK ~p~n", [Msg2]),
                            gen_tcp:send(Socket, "OK " ++ Msg2 ++ "\n"),
                            atiendeboludos(Socket, Boludo, Nigguh);
                        {bye} -> gen_tcp:send(Socket, "Goodbye Blue Sky\n"),
                        		 gen_tcp:close(Socket)
                        		%exit(self(), normal)
                    end
            end
            %atiendeboludos(Socket, Boludo, Nigguh);
            %_Peronlaconchadetumadre -> atiendeboludos(Socket, Boludo, Nigguh)
    end.

%Retorna el registro de un worker al azar
sovietanthem() ->
	random:seed(erlang:now()),
    Y = random:uniform(5),
    list_to_atom([$a | integer_to_list(Y)]).

%Worker (negro esclavo colector de diamantes)
%---Argumentos:
%* PidList: Lista de Pids de los demas workers
%* Files:Lista de archivos
%* Cacho: Cache para procesamiento interno
%* RequestList: Lista de solicitudes de clientes
%* LastFD: Ultimo descriptor de archivos utilizado
%* MsgCounter: Contador de mensajes
%* Safe: Indica si se envio el mensaje a otro worker, se la utiliza par aevitar envias
% de manera erronea (errores de conteo)
negro(L)->
    register(list_to_atom([$a | integer_to_list(L)]), self()),
    PidList = lists:filter(fun(X) -> nigga(L) =/= X end,[a1,a2,a3,a4,a5]),
    negro(PidList, [], [], [], 0, 0, no).
negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe) ->
    %Bloque de procesamiento
    if  length(RequestList) == 0 -> ok;
        true -> [{Command, Arguments, ClientIf} | Tail] = RequestList,
            case Command of
                lsd ->  if  MsgCounter == 0 -> negro(PidList, Files, Files, RequestList, LastFD, 1 , no);

                            MsgCounter == 5 -> getUserName(ClientIf) ! {ok, merle(getFileList(Cacho))},
                                                negro(PidList, Files, [], Tail, LastFD, 0 , no);

                            Safe == no      ->  lists:nth(MsgCounter, PidList) ! {giveList, self()},
                                                negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter , si);

                            true -> ok
                        end;

                del -> 	FileNombre = lists:nth(1, Arguments),
                		NombreQueTeGuste = getFile(Files, name, FileNombre),
                	if  MsgCounter == 0 ->
                    		case NombreQueTeGuste of
                    			{error} -> negro(PidList, Files, Cacho, RequestList, LastFD, 1, no);

                    			{_, _, 0, _} -> getUserName(ClientIf) ! {ok , ""},
                    							negro(PidList, removeFile(Files, FileNombre), Cacho, Tail, LastFD, 0, no);

                    			{_, _, _NonZero, _} -> getUserName(ClientIf) ! {error , "El archivo esta abierto"},
                    								  negro(PidList, Files, Cacho, Tail, LastFD, MsgCounter , no)
                    		end;
                		MsgCounter == 5 ->	case Cacho of
                							    [verdad] -> getUserName(ClientIf) ! {ok, ""},
                							    			io:format("aca??~n"),
                						    				negro(PidList, Files, [], Tail, LastFD, 0 , no);

                								[abierto] -> getUserName(ClientIf) ! {error, "El archivo esta abierto"},
                						    				negro(PidList, Files, [], Tail, LastFD, 0 , no);

                						    	_Else -> getUserName(ClientIf) ! {error, "El archivo no existe"},
                						    			 negro(PidList, Files, [], Tail, LastFD, 0 , no)
                						   	end;

                		Safe == no -> lists:nth(MsgCounter, PidList) ! {delFile, FileNombre, self()},
                                      negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter , si);
                        true -> ok
                    end;


                cre -> [Name | _] = Arguments,
                        if  MsgCounter == 0 ->
                                T1 = existFile(Files , Name),
                                case T1 of
                                    si ->   getUserName(ClientIf) ! {error , "El archivo ya existe"},
                                            negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    _else -> negro(PidList, Files, [], RequestList, LastFD, 1 , no)
                                end;
                            MsgCounter == 5 ->
                                T2 = existFile(Cacho , Name),
                                case T2 of
                                    si ->   getUserName(ClientIf) ! {error , "El archivo ya existe"},
                                            negro(PidList, Files, [], Tail, LastFD, 0, no);

                                    _else -> getUserName(ClientIf) ! {ok , []},
                                    	     negro(PidList, createFile(Files , Name), [], Tail, LastFD, 0, no)
                                end;

                            Safe == no ->   lists:nth(MsgCounter, PidList) ! {giveList, self()},
                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, si);
                            true -> ok
                        end;

                opn -> [Name | _] = Arguments,
                        io:format("soyunpelotudo~p~n",[MsgCounter]),
                		if MsgCounter == 0 ->
                    		T1 = getFile(Files, name, Name),
                            io:format("Holaaa ~p~n", [T1]),
                    			case T1 of
                    				{_, _, 0, _} -> pidCast(PidList, {incFD}),
                                                    getUserName(ClientIf) ! {ok, "FD "++integer_to_list(LastFD + 1)},
                                                    %io:format("1: ~p~n 2: ~p~n", [Files, openFile(Name, Files, ClientIf, LastFD + 1)]),
                                                    negro(PidList, openFile(Name, Files, ClientIf, LastFD + 1), Cacho, Tail, LastFD + 1, 0, no);

                                    {_, _, _N, _} -> getUserName(ClientIf) ! {error, "El archivo ya esta abierto"},
                                                    negro(PidList, Files, [], Tail, LastFD, 0, no);

                                    _else        -> negro(PidList, Files, Cacho, RequestList, LastFD, 1, no)
                                end;
                            MsgCounter == 5 ->  case Cacho of
                                                    [verdad, Fede] -> getUserName(ClientIf) ! {ok, "FD "++integer_to_list(Fede)},
                                                            negro(PidList, Files, [], Tail, LastFD, 0 , no);
                                                    [abierto, _Fede] -> getUserName(ClientIf) ! {error, "El archivo esta abierto"},
                                                            negro(PidList, Files, [], Tail, LastFD, 0 , no);
                                                    _Else -> getUserName(ClientIf) ! {error, "El archivo no existe"},
                                                            negro(PidList, Files, [], Tail, LastFD, 0 , no)
                                                end;
                            Safe == no -> lists:nth(MsgCounter, PidList) ! {openFile, Name, self(), ClientIf},
                                          negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter , si);
                            true -> ok
                        end;
                %[1,3,"Papa"]
                wrt -> [Fd, Size, Palabra] = Arguments,
                        if MsgCounter == 0 ->
                            T1 = getFile(Files, fd, Fd),
                            %io:format("TE 1~p~n", [T1]),
                           % io:format("~p~n", [ClientIf == 1]),
                            case T1 of
                                {_, _, 0, _} -> getUserName(ClientIf) ! {error, "El archivo esta cerrado"},
                                                negro(PidList, Files, [], Tail, LastFD, 0, no);

                                {_, _, _N, ClientIf} -> getUserName(ClientIf) ! {ok, ""},
                                                %io:format("1: ~p~n 2: ~p~n", [Files, writeFile(Files, Fd, Size, Palabra)]),
                                                negro(PidList, writeFile(Files, Fd, Size, Palabra), [], Tail, LastFD, 0, no);

                                {_, _, _, _} -> getUserName(ClientIf) ! {error, "Acces Denied!"},
                                                negro(PidList, Files, [], Tail, LastFD, 0, no);

                                _else        -> negro(PidList, Files, Cacho, RequestList, LastFD, 1, no)
                            end;
                            MsgCounter == 5 ->
                                case Cacho of
                                    [archCerrado] -> getUserName(ClientIf) ! {error, "El archivo esta cerrado"},
                                                       negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    [denied] -> getUserName(ClientIf) ! {error, "aseso denegado"},
                                                negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    [archWrt] ->  getUserName(ClientIf) ! {ok, ""},
                                                    %io:format("Asd~p~n", [Files]),
                                                    negro(PidList, Files, [], Tail, LastFD, 0 , no);
                                    _Elsa2 -> getUserName(ClientIf) ! {error, "No hay archivo"},
                                              negro(PidList, Files, [], Tail, LastFD, 0 , no)
                                end;

                            Safe == no -> lists:nth(MsgCounter, PidList) ! {writeFile, Fd, self(), ClientIf, Palabra, Size},
                                          negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter , si);
                            true -> ok
                        end;

                rea ->  [Fd, Size] = Arguments,
                        if MsgCounter == 0 ->
                            T1 = getFile(Files, fd, Fd),
                            case T1 of
                                {_, _, 0, _} -> getUserName(ClientIf) ! {error, "El archivo esta cerrado"},
                                                negro(PidList, Files, [], Tail, LastFD, 0, no);

                                {_, _, _N, ClientIf} -> Pinoccio = readFile(Files, Fd, Size),
                                                case Pinoccio of

                                                    {ok, Peron} -> getUserName(ClientIf) ! {ok, integer_to_list(Size) ++ " " ++ Peron},
                                                                    negro(PidList, Files, [], Tail, LastFD, 0, no);

                                                    _Elsa3 -> getUserName(ClientIf) ! {error, "0 "},
                                                                negro(PidList, Files, [], Tail, LastFD, 0, no)
                                                end;

                                {_, _, _, _} -> getUserName(ClientIf) ! {error, "Acces Denied!"},
                                                negro(PidList, Files, [], Tail, LastFD, 0, no);

                                _else        -> negro(PidList, Files, Cacho, RequestList, LastFD, 1, no)
                            end;

                            MsgCounter == 5 ->
                                case Cacho of
                                    [archCerrado] -> getUserName(ClientIf) ! {error, "El archivo esta cerrado"},
                                                       negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    [toma, Blas] ->  getUserName(ClientIf) ! {ok, integer_to_list(Size) ++ " " ++ Blas},
                                                    negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    [nada] -> getUserName(ClientIf) ! {error, "0 "},
                                              negro(PidList, Files, [], Tail, LastFD, 0, no);

                                    [denied] -> getUserName(ClientIf) ! {error, "Acces Denied!"},
                                                negro(PidList, Files, [], Tail, LastFD, 0, no);

                                    _Elsa2 -> getUserName(ClientIf) ! {error, "Ola bb no te vayas ok? NO CIERRA"},
                                              negro(PidList, Files, [], Tail, LastFD, 0 , no)
                                end;

                            Safe == no ->   lists:nth(MsgCounter, PidList) ! {readFile , self() , Fd, ClientIf, Size},
                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, si);
                            true -> ok
                    end;

                clo ->  [Fd | _] = Arguments,
                        if  MsgCounter == 0 ->
                            T1 = getFile(Files , fd , Fd),
                                case T1 of
                                    {_, _, 0, _} -> getUserName(ClientIf) ! {error, "El archivo esta cerrado"},
                                                    negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    {_, _, _N, ClientIf} -> getUserName(ClientIf) ! {ok, ""},
                                                            negro(PidList, closeFile(Files, Fd), [], Tail, LastFD, 0 , no);

                                    {_, _, _N, _} -> getUserName(ClientIf) ! {error, "No pode cerrarlo vo eh"},
                                                    negro(PidList, Files, [], Tail, LastFD, 0 , no);

                                    _Elsa -> negro(PidList, Files, [], RequestList, LastFD, 1 , no)
                                end;
                            MsgCounter == 5 ->
                                    io:format("papita~p~n", [Cacho]),
                                case Cacho of
                                    [closedAlready] -> getUserName(ClientIf) ! {error, "El archivo esta cerrado"},
                                                       negro(PidList, Files, [], Tail, LastFD, 0 , no);
                                    [iClosedIt] ->  getUserName(ClientIf) ! {ok, ""},
                                                    negro(PidList, Files, [], Tail, LastFD, 0 , no);
                                    [ureNotAllowed] -> getUserName(ClientIf) ! {error, "No tienes permiso oye"},
                                                       negro(PidList, Files, [], Tail, LastFD, 0 , no);
                                    _Elsa2 -> getUserName(ClientIf) ! {error, "Ola bb no te vayas ok? NO CIERRA"},
                                              negro(PidList, Files, [], Tail, LastFD, 0 , no)
                                end;

                            Safe == no ->   lists:nth(MsgCounter, PidList) ! {closeFile , self() , Fd , ClientIf},
                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, si);
                            true -> ok
                    end;

                bye ->  justKill(ClientIf , PidList),
                        getUserName(ClientIf) ! {bye},
                        negro(PidList, closeAllUserFile(Files , ClientIf), [], Tail, LastFD, 0 , no);
                _Else -> ok
            end
    end,
    %Bloque de recepcion
    receive
        {boludo, Com, [Args], Boludo} ->
            T = lists:append(RequestList, [{Com, Args, Boludo}]),
            negro(PidList, Files, Cacho, T, LastFD, MsgCounter, Safe);

        {giveList, NegPid} -> NegPid ! {takeList, Files};
        {takeList, FileReceived} -> negro(PidList, Files, lists:append(Cacho, FileReceived), RequestList, LastFD, MsgCounter + 1, no);

        {incFD} -> negro(PidList, Files, Cacho, RequestList, LastFD + 1, MsgCounter, Safe);
        {delFile, FileName, NegPid} -> HasFile = getFile(Files, name, FileName),
        							   case HasFile of
        							   		{_, _, 0, _} -> NegPid ! {isRemoved, verdad},
        							   						negro(PidList, removeFile(Files, FileName), Cacho, RequestList, LastFD, MsgCounter, Safe);
        							   		{_, _, _K, _} -> NegPid ! {isRemoved, abierto};

        							   		_Sino -> NegPid ! {isRemoved, falso}
        							   	end;

        {isRemoved, BooleanState} ->
        							case BooleanState of
        								verdad -> io:format("Si?¡?~n"),
        								negro(PidList, Files, [verdad], RequestList, LastFD, 5, no);
        								abierto -> negro(PidList, Files, [abierto], RequestList, LastFD, 5, no);
        								_Nosi -> negro(PidList, Files, [noarchivo], RequestList, LastFD, MsgCounter + 1, no)
        							 end;

        {closeFile , NegPid , TakeFd , Usr} -> HasFile = getFile(Files, fd, TakeFd),
                                               case HasFile of
                                                    {_, _, 0, _} -> NegPid ! {takeThisClose, alreadyClosed},
                                                                    negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe);
                                                    {_, _, _K, Usr} ->  NegPid ! {takeThisClose, okClose},
                                                                        negro(PidList, closeFile(Files, TakeFd), Cacho, RequestList, LastFD, MsgCounter, Safe);

                                                    {_, _, _K, _Usr} -> NegPid ! {takeThisClose, cantCloseItDude};
                                                    _Sino -> NegPid ! {takeThisClose, error}
                                                end;

        {takeThisClose, Argumento} -> case Argumento of
                                           alreadyClosed -> negro(PidList, Files, [closedAlready], RequestList, LastFD, 5, no);
                                           okClose -> negro(PidList, Files, [iClosedIt], RequestList, LastFD, 5, no);
                                           cantCloseItDude -> negro(PidList, Files, [ureNotAllowed], RequestList, LastFD, 5, no);
                                           _Otracosa -> negro(PidList, Files, [oiekhe], RequestList, LastFD, MsgCounter + 1, no)
                                      end;

        {openFile, FileName, NegPid, Usr} -> HasFile = getFile(Files, name, FileName),
         io:format("Haaa~n~p", [HasFile]),
                                       case HasFile of
                                            {_, _, 0, _} ->  NegPid ! {opened, yes, LastFD + 1},
                                                             pidCast(PidList, incFD),
                                                             negro(PidList, openFile(FileName, Files, Usr, LastFD + 1), Cacho, RequestList, LastFD + 1, MsgCounter, Safe);
                                            {_, _, _K, _} -> NegPid ! {opened, nopuedoamiwo, acatmabien};

                                            _Sino -> NegPid ! {opened, error, seeeeeeeeeeee}
                                        end;

        {writeFile, Fed, NegPid, Usr, Palabras, Saize} -> HasFile = getFile(Files, fd, Fed),
         %io:format("Haaa~n~p", [HasFile]),
                                       case HasFile of
                                            {_, _, 0, _} -> NegPid ! {writeAtom, nope},
                                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe);

                                            {_, _, _K, Usr} -> NegPid ! {writeAtom, yes},
                                                              negro(PidList, writeFile(Files, Fed, Saize, Palabras), Cacho, RequestList, LastFD, MsgCounter, Safe);
                                            {_, _, _, _} -> NegPid ! {writeAtom, denied},
                                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe);

                                            _Sino -> NegPid ! {writeAtom, error},
                                                     negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe)
                                        end;

        {writeAtom, Quehay} -> case Quehay of
                                      nope -> negro(PidList, Files, [archCerrado], RequestList, LastFD, 5, no);
                                      yes -> negro(PidList, Files, [archWrt], RequestList, LastFD, 5, no);
                                      denied -> negro(PidList, Files, [denied], RequestList, LastFD, 5, no);
                                      _Sinoes -> negro(PidList, Files, [khe], RequestList, LastFD, MsgCounter + 1, no)
                                  end;

        %readFile , self() , Fd, ClientIf, Size
        {readFile, NegPid, Fed, Usr, Saize} -> HasFile = getFile(Files, fd, Fed),
                                       case HasFile of
                                            {_, _, 0, _} -> NegPid ! {readAtom, nope, basura},
                                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe);

                                            {_, _, _K, Usr} -> EstoNoEstaMal = readFile(Files, Fed, Saize),
                                                            case EstoNoEstaMal of
                                                                {ok, Peronismo} -> NegPid ! {readAtom, yes, Peronismo},
                                                                                negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe);

                                                                _Eles -> NegPid ! {readAtom, nope2, basura},
                                                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe)
                                                            end;

                                            {_, _, _, _} -> NegPid ! {readAtom, denied, basura},
                                                            negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe);

                                            _Sino -> NegPid ! {readAtom, error, basura},
                                                     negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe)
                                        end;

        {readAtom, Quehay, Basurita} -> case Quehay of
                                      nope -> negro(PidList, Files, [archCerrado], RequestList, LastFD, 5, no);
                                      nope2 -> negro(PidList, Files, [nada], RequestList, LastFD, 5, no);
                                      yes -> negro(PidList, Files, [toma, Basurita], RequestList, LastFD, 5, no);
                                      denied -> negro(PidList, Files, [denied], RequestList, LastFD, 5, no);
                                      _Sinoes -> negro(PidList, Files, [khe], RequestList, LastFD, MsgCounter + 1, no)
                                  end;


        {opened, Quehay, Efe} -> case Quehay of
                                      yes -> negro(PidList, Files, [verdad, Efe], RequestList, LastFD, 5, no);
                                      nopuedoamiwo -> negro(PidList, Files, [abierto, Efe], RequestList, LastFD, 5, no);
                                      _Sinoes -> negro(PidList, Files, [khe, Efe], RequestList, LastFD, MsgCounter + 1, no)
                                  end;

        %{takeCloseFile , State} -> negro(PidList, Files, lists:append(Cacho, [State]), RequestList, LastFD, MsgCounter + 1, no);

        {bye , Usr} -> negro(PidList, closeAllUserFile(Files , Usr) , Cacho, RequestList, LastFD, MsgCounter, Safe)
    end,
    negro(PidList, Files, Cacho, RequestList, LastFD, MsgCounter, Safe).

%********************************************************************************%
%                           Funciones auxiliares
%********************************************************************************%

%Dado un entero retorna el identificador de worker
nigga(X) ->
    list_to_atom([$a | integer_to_list(X)]).

% Retorna el identificador de un usuario dado su numero
%---Argumentos
%* Numero de usuario
getUserName(N)->
    H = "usr" ++ integer_to_list(N),
    list_to_atom(H).

%Merle
%Dada una lista de Strings concatena los String separados por un espacio
merle([])->
    "";
merle(X)->
	io:format("~p~n", [X]),
    string:join(X, " ").

%limpia la pantalla
clear()->
    io:format("\e[H\e[J").

% Broadcast a una lista de pids
%---Argumentos
%* Lista de Pids
%* Mensaje a enviar
pidCast([], _Args) ->
	ok;
pidCast([H|T], Args) ->
	H ! Args,
	pidCast(T, Args).

%Hace lo que dice
funcionRandomDeLaCosa()->
    random:seed(erlang:now()),
    N = random:uniform(5),
    case N of
        1 -> "Maxi se cae de la silla";
        2 -> "Sermentation Violation";
        3 -> "Error Keyboard is not detected, please press F11 to repair this";
        4 -> "Please restart your pc";
        5 -> "Use Assembler please";
        _Else -> "No se que decir"
    end.

%Envia la order a los demas workers para que cierren los archivos abiertos por un usuario
%---Argumentos
%* Id del usuario
%* Lista de archivos
justKill(_ , [])->
    ok;
justKill(UserId , [H|T])->
    H ! {bye , UserId},
    justKill(UserId , T).


%********************************************************************************%
%                           Funciones de archivos
% Los archivos tienen la estructura {nombre , contenido , fd , user} -> {Name , Content , Fd , UserId}
%********************************************************************************%

% Intenta leer un archivo de una lista
%---Argumentos
%* Lista de archivos
%* descriptor de archivo
%* Tamaño a leer
readFile([H|T], Fd, Size) ->
    {_, Contenido, Fed, _} = H,
    Sorete = length(Contenido),
    if  Fd == Fed -> if  Sorete >= Size -> {ok, string:sub_string(Contenido, 1, Size)};
                        true -> {error}
                    end;
        true -> readFile(T, Fd, Size)
    end.

% Intenta escribir en un archivo
%---Argumentos
%* Lista de archivos
%* descriptor de archivo
%* Tamaño a escribir
%* Texto a escribir
writeFile(Files, Fd, Size, Word) ->
    writeFile(Files, Fd, Size, Word, []).
writeFile([], _, _, _, Cache) ->
    Cache;
writeFile([H|T], Fd, Size, Word, Cache) ->
    {Name, Contenido, Fed, User} = H,
    OyeAmigo = Contenido ++ string:sub_string(Word, 1, Size),
    if  Fd == Fed -> lists:append([Cache, [{Name, OyeAmigo, Fed, User}], T]);
        true -> writeFile(T, Fd, Size, Word, lists:append(Cache, [H]))
    end.

% Intenta eliminar un archivo
%---Argumentos
%* Lista de archivos
%* Nombre del archivo
removeFile(Table, FileName) ->
	removeFile(Table, FileName, []).
removeFile([], _, Cache) ->
	Cache;
removeFile([H|T], FileName, Cache) ->
	{Name, _, _, _} = H,
	if FileName == Name -> lists:append(Cache, T);
		true -> removeFile(T, FileName, lists:append(Cache, [H]))
	end.

%Retorna la lista de nombres de archivos
%---Argumentos
%* Lista de archivos
getFileList(FileList) ->
    getFileList(FileList, []).
getFileList([], Cache)->
    Cache;
getFileList([H|T], Cache)->
    {Name, _, _ , _} = H,
    getFileList(T, lists:append(Cache, [Name])).

%Retorna la tabla de archivos con un nuevo archivo dentro basandose en un nombre
%---Argumentos
%* Lista de archivos
%* Nombre del archivo
createFile(FileList, Name) ->
    lists:append(FileList, [{Name, [], 0, 0}]).

%Retorna un archivo
%---Argumentos
%* Lista de archivos
%* Indica el tipo de patron de busqueda (medainte nombre o mediante descriptor)
%* Patron a buscar
getFile([] , _ , _)->
    {error};
getFile([H|T] , Key , Value)->
    {Name , _ , Fd , _} = H,
        %Papa = integer_to_list(Fd),
        case Key of
            name ->
                if  Value == Name -> H;
                    true -> getFile(T , Key , Value) end;
            fd ->
                if  Value == Fd -> H;
                    true -> getFile(T , Key , Value) end;
            _Else -> {error}
        end.

% Intenta cerrar un archivo
%---Argumentos
%* Lista de archivos
%* descriptor de archivos
closeFile(List , Fd)->
    closeFile(List, Fd, []).
closeFile([], _, New)->
    New;
closeFile([H|T], FD, New)->
    {Name, Content, Fed, _} = H,
    case FD of
        Fed   -> lists:append([New, [{Name, Content, 0, 0}], T]);
        _Else -> closeFile(T, FD, lists:append(New , [H]))
    end.

%Cierra todos los archivos correspondientes a un usuario
%---Argumentos
%* Lista de archivos
%* Usuario
closeAllUserFile(List , Prop)->
    closeAllUserFile(List , Prop , []).
closeAllUserFile([] , _ , Cache)->
    Cache;
closeAllUserFile([H|T] , Prop , Cache)->
    {Name , Content , _ , Usr} = H,
    if  Usr == Prop -> closeAllUserFile(T , Prop , lists:append(Cache , [{Name , Content , 0 , 0}]));
        true -> closeAllUserFile(T , Prop , lists:append(Cache , [H])) end.

%Indica si existe un archivo
%---Argumentos
%* Lista de archivos
%* Nombre del archivo
existFile([] , _)->
    no;
existFile([{Name , _ , _ , _} | T] , FileName)->
    if FileName == Name -> si;
        true -> existFile(T , FileName)
    end.

%Intenta abrir un archivo
%---Argumentos
%* Archivo a abrir
%* Lista de archivos
%* Usuario
%* descriptor
openFile(File , Table , Usr , Fd)->
    openFile(File , Table , Usr , Fd , []).
openFile(_ , [] , _ , _ , Cache)->
	io:format("No deberia pasar~n"),
    Cache;
openFile(File , [H | T] , Usr , Fd, Cache)->
    {Name , Content , Fed , _} = H,
    if
        File == Name -> lists:append([Cache , [{Name , Content , Fd, Usr}] , T]);
        true -> openFile(File, T, Usr, Fed, lists:append(Cache , [H]))
    end.


%********************************************************************************%
%                                       Parser
%********************************************************************************%

%Parser
%---Argumentos
%* String a parsear
parse(Str)->
    Tok = " \r\n",
    if
        length(Str) < 3 -> {error , []} ;
        true -> {Com , Args} = splitFirst(Str , Tok), NArgs = string:words(Args),
            case Com of
                "CON" -> {con , []};
                "LSD" -> {lsd , []};
                "DEL" ->
                    if NArgs < 1 -> {error , ["Parse error, Argumentos inválidos\n"]};
                    true ->
                        {L1 , _} = splitFirst(Args , Tok),
                        {del , [L1]}
                    end;
                "CRE" ->
                    if NArgs < 1 -> {error , ["Parse error, Argumentos inválidos"]};
                    true ->
                        {L1 , _} = splitFirst(Args , Tok),
                        {cre , [L1]}
                    end;
                "OPN" ->
                    if NArgs < 1 -> {error , ["Parse error, Argumentos inválidos"]};
                    true ->
                        {L1 , _} = splitFirst(Args , Tok),
                        {opn , [L1]}
                    end;
                "WRT" ->
                    if NArgs < 5 -> {error , ["Parse error, Argumentos inválidos"]};
                    true ->
                        {L1 , LL1} = splitFirst(Args , Tok),
                        {L2 , LL2} = splitFirst(LL1 , Tok),
                        {L3 , LL3} = splitFirst(LL2 , Tok),
                        {L4 , LL4} = splitFirst(LL3 , Tok),
                        {L5 , _} = splitFirst(LL4 , Tok),
                        if  (L1 == "FD") and (L3 == "SIZE") -> {wrt , [list_to_integer(L2) , list_to_integer(L4) , L5]};
                            true -> {error , ["Parse error, Argumentos inválidos"]}
                        end
                    end;
                "REA" ->
                    if NArgs < 4 -> {error , ["Parse error, Argumentos inválidos"]};
                    true ->
                        {L1 , LL1} = splitFirst(Args , Tok),
                        {L2 , LL2} = splitFirst(LL1 , Tok),
                        {L3 , LL3} = splitFirst(LL2 , Tok),
                        {L4 , _} = splitFirst(LL3 , Tok),
                        if  (L1 == "FD") and (L3 == "SIZE") -> {rea , [list_to_integer(L2) , list_to_integer(L4)]};
                            true -> {error , ["Parse error, Argumentos inválidos"]}
                        end
                    end;
                "CLO" ->
                    if NArgs < 2 -> {error , ["Parse error, Argumentos inválidos"]};
                    true ->
                        {L1 , L2} = splitFirst(Args , Tok),
                        {L3 , _} = splitFirst(L2 , Tok),
                        if  L1 == "FD" -> {clo , [list_to_integer(L3)]};
                            true -> {error , ["Parse error, Argumentos inválidos"]}
                        end
                    end;
                "BYE" -> {bye , []};
                _Else -> {error , "Parse error, Comando inválido\n"}
            end
    end.

%Divide un String en una tupla con la primer palabra en la primer componente y el resto en la segunda
%---Argumentos
%* Cadena a analizar
%* Token de para aplicar split
splitFirst(Str , Tok)->
    splitFirst(Str , Tok , 1).
splitFirst(Str , Tok , Idx)->
    if
        length(Str) < Idx -> {Str , []};
        true ->
                B = lists:member(lists:nth(Idx , Str) , Tok),
                if
                    B -> {string:substr(Str , 1 , Idx - 1) , string:substr(Str , Idx + 1)};
                    true -> splitFirst(Str , Tok , Idx + 1)
                end
    end.
