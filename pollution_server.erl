-module(pollution_server).
-author("Agata").

%% API
-export([init/0, loop/1]).
-export([start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMovingMean/3]).

start()->
  register(pollutionServer, spawn_link(?MODULE, init, [])).

init()->
  loop(pollution:createMonitor()).

addStation(Name, {Vertical, Horizontal})->
  pollutionServer ! {addStationS, Name, {Vertical, Horizontal}, self()},
  receiveAnswer().

addValue({Vertical, Horizontal}, Type, Value, DateTime)->
  pollutionServer ! {addValueS, {Vertical, Horizontal}, Type, Value, DateTime, self()},
  receiveAnswer();
addValue(Name, Type, Value, DateTime)->
  pollutionServer ! {addValueS, Name, Type, Value, DateTime, self()},
  receiveAnswer().

removeValue({Vertical, Horizontal}, DateTime, Type)->
  pollutionServer ! {removeValueS, {Vertical, Horizontal}, DateTime, Type, self()},
  receiveAnswer();
removeValue(Name, DateTime, Type)->
  pollutionServer ! {removeValueS, Name, DateTime, Type, self()},
  receiveAnswer().

getOneValue(Name, DateTime, Type)->
  pollutionServer ! {getOneValueS, Name, DateTime, Type, self()},
  receiveAnswer().

getStationMean(Name, Type)->
  pollutionServer ! {getStationMeanS, Name, Type, self()},
  receiveAnswer().

getDailyMean(Type, {Y, M, D})->
  pollutionServer ! {getDailyMeanS, Type, {Y, M, D}, self()},
  receiveAnswer().

getMovingMean(Type, {Y, M, D}, {Vertical, Horizontal})->
  pollutionServer ! {getMovingMeanS, Type, {Y, M, D}, {Vertical, Horizontal}, self()},
  receiveAnswer().

loop(Pollution)->
  receive
    {addStationS, Name, {Vertical, Horizontal}, Pid} -> loop(pars(Pollution, Pid, pollution:addStation(Name, {Vertical, Horizontal}, Pollution)));
    {addValueS, {Vertical, Horizontal}, Type, Value, DateTime, Pid} -> loop(pars(Pollution, Pid, pollution:addValue({Vertical, Horizontal}, Type, Value, DateTime, Pollution)));
    {addValueS, Name, Type, Value, DateTime, Pid} -> loop(pars(Pollution, Pid, pollution:addValue(Name, Type, Value, DateTime, Pollution)));
    {removeValueS, {Vertical, Horizontal}, DateTime, Type, Pid} -> loop(pars(Pollution, Pid, pollution:removeValue({Vertical, Horizontal}, DateTime, Type, Pollution)));
    {removeValueS, Name, DateTime, Type, Pid} -> loop(pars(Pollution, Pid, pollution:removeValue(Name, DateTime, Type, Pollution)));
    {getOneValueS, Name, DateTime, Type, Pid} ->
      Pid ! pollution:getOneValue(Name, DateTime, Type, Pollution),
      loop(Pollution);
    {getStationMeanS, Name, Type, Pid} ->
      Pid ! pollution:getStationMean(Name, Type, Pollution),
      loop(Pollution);
    {getDailyMeanS, Type, {Y, M, D}, Pid} ->
      Pid ! pollution:getDailyMean(Type, {Y, M, D}, Pollution),
      loop(Pollution);
    {getMovingMeanS, Type, {Y, M, D}, {Vertical, Horizontal}, Pid} ->
      Pid ! pollution:getMovingMean(Type, {Y, M, D}, {Vertical, Horizontal}, Pollution),
      loop(Pollution)
  end.

pars(Pollution, Pid, {error, Reason})->
  Pid ! {error, Reason},
  Pollution;
pars(_, Pid, Pollution2)->
  Pid ! ok,
  Pollution2.

stop() -> ok.

receiveAnswer() ->
  receive
    _ -> ok
  end.

%c(pollution_server).
%pollution_server:start().
%pollution_server:init().
%pollution_server:addStataion("abc", {1, 2}).
%pollution_server:addValue ("abc", "z1", 21, calendar:local_time()).



