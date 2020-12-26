%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(deploy_test). 
    
%% --------------------------------------------------------------------
%% Include files

-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(DepSpecsDir,"deployment_specs").
-define(GitUser,"joq62").
-define(GitPassWd,"20Qazxsw20").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),

    ?debugMsg("Start load_specs"),
    ?assertEqual(ok,load_specs()),
    ?debugMsg("stop load_specs"),

   ?debugMsg("Start read_specs"),
    ?assertEqual(ok,read_specs()),
    ?debugMsg("stop read_specs"),

    ?assertEqual(ok,cleanup()),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

setup()->

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load_specs()->

    io:format("~p~n",[control:load_deployment_specs(?DepSpecsDir,?GitUser,?GitPassWd)]),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
read_specs()->
    io:format("~p~n",[control:read_deployment_specs(?DepSpecsDir)]),
 %   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

cleanup()->

    ok.
