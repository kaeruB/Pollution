%%%-------------------------------------------------------------------
%%% @author Agata
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. kwi 2017 12:40
%%%-------------------------------------------------------------------
-module(eunit).
-author("Agata").

-include_lib("eunit/include/eunit.hrl").

all_test() ->
L = pollution:createMonitor(),
P1 = pollution:addStation("Aleja Slowackiego", {50.2345, 18.3445}, L),
Nyan2 = pollution:addValue("Aleja Slowackiego", "PM2.6", 115, calendar:local_time(), P1),
Nyan3 = pollution:addValue("Aleja Slowackiego", "PM", 115, calendar:local_time(), Nyan2),
Nyan4 = pollution:addValue("Aleja Slowackiego", "PM", 125, calendar:local_time(), Nyan3),
P10 = pollution:addStation("Aleja Slowackiego 2", {1, 1}, Nyan4),
Nyan5 = pollution:addValue("Aleja Slowackiego 2", "PM", 125, calendar:local_time(), P10).

create_monitor_test() -> ?assert ([] =:= pollution:createMonitor()).

getDailyMean_test() ->
  L = pollution:createMonitor(),
  L2 = pollution:addStation("Stacja 1", {0, 0}, L),
  L3 = pollution:addStation("Stacja 2", {1, 1}, L2),
  L4 = pollution:addStation("Stacja 3", {2, 3}, L3),
  L5 = pollution:addValue("Stacja 1", "Z1", 100, {{2017,5,6},{20,6,30}}, L4),
  L6 = pollution:addValue("Stacja 1", "Z1", 200, {{2017,5,6},{20,6,30}}, L5),
  L7 = pollution:addValue("Stacja 2", "Z1", 150, {{2017,5,6},{20,6,30}}, L6),
  L8 = pollution:addValue("Stacja 3", "Z1", 125, {{2017,5,6},{20,6,30}}, L7),
  L9 = pollution:addValue("Stacja 3", "Z1", 175, {{2017,5,6},{20,6,30}}, L8),
  ?assertEqual((pollution:getDailyMean("Z1", {2017,5,6}, L9)), 150.0).

getMovingMean_test() ->
  L = pollution:createMonitor(),
  L2 = pollution:addStation("Stacja 1", {0, 0}, L),
  L3 = pollution:addStation("Stacja 2", {1, 1}, L2),
  L4 = pollution:addStation("Stacja 3", {2, 3}, L3),
  L5 = pollution:addValue("Stacja 1", "Z1", 10, {{2017,5,6},{23,6,30}}, L4),
  L6 = pollution:addValue("Stacja 1", "Z1", 20, {{2017,5,6},{22,6,30}}, L5),
  L7 = pollution:addValue("Stacja 2", "Z1", 150, {{2017,5,6},{20,6,30}}, L6),
  L8 = pollution:addValue("Stacja 3", "Z1", 125, {{2017,5,6},{20,6,30}}, L7),
  L9 = pollution:addValue("Stacja 3", "Z1", 175, {{2017,5,6},{20,6,30}}, L8),
  L10 = pollution:addValue("Stacja 1", "Z1", 30, {{2017,5,6},{21,6,30}}, L9),
  L11 = pollution:addValue("Stacja 1", "Z1", 40, {{2017,5,6},{20,6,30}}, L10),
  ?assertEqual(pollution:getMovingMean("Z1", {2017,5,6}, {0, 0}, L11), 19.7).