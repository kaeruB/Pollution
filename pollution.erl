%%%-------------------------------------------------------------------
%%% @author Agata
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. kwi 2017 21:15
%%%-------------------------------------------------------------------
-module(pollution).
-author("Agata").

%% API
-export([createMonitor/0, getStation/3, addStation/3, addValue/5, addValuePom/5, removeValue/4, removeValuePom/4,
  getOneValue/4, getValuePom/1, getStationMean/3, getAverageFromList/1, averagePom/3,valueList/2, getDailyMean/3, getDailyMeanPom/4,
  getMovingAverage/1, getMovingMean/4, getCurrentHour/0, getWeight/2]).

%%type - czy temp. czy stezenie
-record (coords, {verticalCoords, horizontalCoords}).
-record(station, {name, coords, measurement = []}).
-record(measurement, {type, value, dateTime}).

createMonitor() -> [].

getStation(_, _, []) -> false;
getStation(Name, {_, _}, [#station{name = Name, coords = #coords{verticalCoords = _, horizontalCoords = _}} | _]) -> true;
getStation(_, {Vertical, Horizontal}, [#station{name = _, coords = #coords{verticalCoords = Vertical, horizontalCoords = Horizontal}} | _]) -> true;
getStation(Name, {Vertical, Horizontal}, [_ | T]) -> getStation(Name, {Vertical, Horizontal}, T).


addStation(Name, {Vertical, Horizontal}, StationList)->
  case getStation(Name, {Vertical, Horizontal}, StationList) of
    false -> [#station{name = Name, coords = #coords{verticalCoords = Vertical, horizontalCoords = Horizontal}} | StationList];
    _ -> {error, "Taka stacja juz istnieje"}
  end.


%%Date = {Year, Month, Day}
%%Time = {Hour, Minute, Second}

addValue({Vertical, Horizontal}, Type, Value, DateTime, List) ->
  case lists:any(fun(#station{coords = #coords{verticalCoords = VC, horizontalCoords = HC}, measurement = Mes}) ->
    (Vertical == VC) and (Horizontal = HC)
      and not (lists:any(fun(#measurement{type = Ty, value = Val, dateTime = DT}) ->
      (Ty == Type) and (Val == Value) and (DT == DateTime) end, Mes)) end, List) of
    true -> addValuePom({Vertical, Horizontal}, Type, Value, DateTime, List);
    _ -> {error, "Nie ma takiej stacji lub podany pomiar juz zostal dodany."}
  end;

addValue(Name, Type, Value, DateTime, List) ->
  case lists:any(fun(#station{name = Nam, measurement = Mes}) -> (Nam == Name)
    and not (lists:any(fun(#measurement{type = Ty, value = Val, dateTime = DT}) ->
      (Ty == Type) and (Val == Value) and (DT == DateTime) end, Mes)) end, List) of
    true -> addValuePom(Name, Type, Value, DateTime, List);
    _ -> {error, "Nie ma takiej stacji lub podany pomiar juz zostal dodany."}
  end.

addValuePom({Vertical, Horizontal}, Type, Value, DateTime, []) ->
  [#station{coords = #coords{verticalCoords = Vertical, horizontalCoords = Horizontal},
    measurement = #measurement{type = Type, value = Value, dateTime = DateTime}}];
addValuePom({Vertical, Horizontal}, Type, Value, DateTime, [H = #station{coords = #coords{verticalCoords = Vertical, horizontalCoords = Horizontal}} | T]) ->
  [#station{name = H#station.name, coords = #coords{horizontalCoords = Horizontal, verticalCoords = Vertical},
    measurement = H#station.measurement ++ [#measurement{type = Type, value = Value, dateTime = DateTime}]} | T];
addValuePom({Vertical, Horizontal}, Type, Value, DateTime, [H | T]) -> [H | addValuePom({Vertical, Horizontal}, Type, Value, DateTime, T)];


addValuePom(Name, Type, Value, DateTime, []) ->
  [#station{name = Name, measurement = #measurement{type = Type, value = Value, dateTime = DateTime}}];
addValuePom(Name, Type, Value, DateTime, [H = #station{name = Name} | T]) ->
  [#station{name = Name, coords = #coords{horizontalCoords = H#station.coords#coords.horizontalCoords, verticalCoords = H#station.coords#coords.verticalCoords},
    measurement = H#station.measurement ++ [#measurement{type = Type, value = Value, dateTime = DateTime}]} | T];
addValuePom(Name, Type, Value, DateTime, [H | T]) -> [H | addValuePom(Name, Type, Value, DateTime, T)].


removeValue({Vertical, Horizontal}, DateTime, Type, List) ->
  case lists:any(fun(#station{coords = #coords{verticalCoords = VC, horizontalCoords = HC}, measurement = Mes}) ->
    (Vertical == VC) and (Horizontal = HC) andalso (lists:any(fun(#measurement{type = Ty, dateTime = DT}) -> (Ty == Type) and (DT == DateTime) end, Mes)) end, List) of
    true -> removeValuePom({Vertical, Horizontal}, Type, DateTime, List);
    _ -> {error, "Nie ma takiej stacji lub nie ma takiego pomiaru, wiec nie mozna go usunac."}
  end;
removeValue(Name, DateTime, Type, List) ->
  case lists:any(fun(#station{name = Nam, measurement = Mes}) -> (Nam == Name)
    andalso (lists:any(fun(#measurement{type = Ty, dateTime = DT}) -> (Ty == Type) and (DT == DateTime) end, Mes)) end, List) of
    true -> removeValuePom(Name, Type, DateTime, List);
    _ -> {error, "Nie ma takiej stacji lub nie ma takiego pomiaru, wiec nie mozna go usunac."}
  end.

removeValuePom(_, _, _, []) -> [];
removeValuePom(Name, Type, DateTime, [H = #station{name = Name} | T]) ->
  [#station{name = Name, coords = #coords{horizontalCoords = H#station.coords#coords.horizontalCoords, verticalCoords = H#station.coords#coords.verticalCoords},
    measurement = lists:filter((fun(#measurement{type = Typ, dateTime = DT}) -> (Typ /= Type) and (DT /= DateTime) end), H#station.measurement)} | T];
removeValuePom(Name, Type, DateTime, [H | T]) -> [H | removeValue(Name, Type, DateTime, T)];

removeValuePom({_, _}, _, _, []) -> [];
removeValuePom({Vertical, Horizontal}, Type, DateTime, [H = #station{coords = #coords{verticalCoords = Vertical, horizontalCoords = Horizontal}} | T]) ->
  [#station{name = H#station.name, coords = #coords{horizontalCoords = Horizontal, verticalCoords = Vertical},
    measurement = lists:filter((fun(#measurement{type = Typ, dateTime = DT}) -> (Typ /= Type) and (DT /= DateTime) end), H#station.measurement)} | T];
removeValuePom({Vertical, Horizontal}, Type, DateTime, [H | T]) -> [H | removeValue({Vertical, Horizontal}, Type, DateTime, T)].

getOneValue(_, _, _, []) -> {error, "Zadany pomiar nie zostal odnaleziony."};
getOneValue(Name, DateTime, Type, [H = #station{name = Name} | _]) -> getValuePom(lists:filter((fun (#measurement {dateTime = DT, type = Typ}) -> (Type == Typ) and (DateTime == DT) end), H#station.measurement));
getOneValue(Name, DateTime, Type, [_ | T]) -> getOneValue(Name, DateTime, Type, T).

getValuePom([#measurement{value = Val}]) -> Val.


%srednia wartosc parametru danego typu z zadanej stacji
getStationMean(_, _, []) -> 0;
getStationMean(Name, Type, [H = #station{name = Name} | _]) -> getAverageFromList(lists:filter(fun (#measurement {type = Typ}) -> (Type == Typ) end, H#station.measurement));
getStationMean(Name, Type, [_ | T]) -> getStationMean(Name, Type, T).

getAverageFromList([]) -> {error, "Brak pomiarow"};
getAverageFromList(List) -> valueList(List, []).

valueList([], L) -> averagePom(L, 0, 0);
valueList([H | T], L) -> valueList(T, [H#measurement.value | L]).

averagePom([], Sum, NumberOfEl) -> Sum / NumberOfEl;
averagePom([H | T], Sum, NumberOfEl) -> averagePom(T, Sum + H, NumberOfEl + 1).




getDailyMean(_, _, []) -> 0;
getDailyMean(Type, {Y, M, D}, L) -> getDailyMeanPom(Type, {Y, M, D}, L, []).

getDailyMeanPom(_, _, [], Wynik) -> getAverageFromList(Wynik);
getDailyMeanPom(Type, {Y, M, D}, [H | T], Wynik) ->
  getDailyMeanPom(Type, {Y, M, D}, T, lists:filter(fun (#measurement {type = Typ, dateTime = {{Year, Month, Day}, _ }}) -> (Type == Typ) and (Year == Y) and (Month == M) and (Day == D) end, H#station.measurement) ++ Wynik).

getCurrentHour() ->
  {_, {H, _, _}} = calendar:local_time(),
  H.

getMovingMean(_, _, _, []) -> 0;
getMovingMean(Type, {Y, M, D}, {Vertical, Horizontal}, [H = #station{coords = #coords{verticalCoords = Vertical, horizontalCoords = Horizontal}} | _]) ->
  getMovingAverage(lists:filter(fun (#measurement {type = Typ, dateTime = {{Year, Month, Day}, _ }}) -> (Type == Typ) and (Year == Y) and (Month == M) and (Day == D) end, H#station.measurement));
getMovingMean(Type, {Y, M, D}, {Vertical, Horizontal}, [_ | T]) -> getMovingMean(Type, {Y, M, D}, {Vertical, Horizontal}, T).

getMovingAverage([]) -> {error, "Brak pomiarow"};
getMovingAverage(List) -> getMovingAvgPom(getCurrentHour(), List, 0, 0).

getMovingAvgPom(_, [], Sum, Weights) -> Sum / Weights;
getMovingAvgPom(CurrentHour, [H | T], Sum, Weights) ->
  getMovingAvgPom(CurrentHour, T,
    Sum + (getWeight(pom(H#measurement.dateTime), CurrentHour) * H#measurement.value),
    Weights + getWeight(pom(H#measurement.dateTime), CurrentHour)).

pom({_, {Hour, _, _}}) -> Hour.

getWeight(Hour, CurrentHour) ->
  case CurrentHour - Hour of
    0 -> 24;
    1 -> 23;
    2 -> 22;
    3 -> 21;
    4 -> 20;
    5 -> 19;
    6 -> 18;
    7 -> 17;
    8 -> 16;
    9 -> 15;
    10 -> 14;
    11 -> 13;
    12 -> 12;
    13 -> 11;
    14 -> 10;
    15 -> 9;
    16 -> 8;
    17 -> 7;
    18 -> 6;
    19 -> 5;
    20 -> 4;
    21 -> 3;
    22 -> 2;
    23 -> 1;
    24 -> 0
  end.




