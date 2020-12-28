%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(control_tests). 
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").

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

    ?debugMsg("Start print_status"),
    spawn(fun()->print_status() end),

    ?debugMsg("Start dbase_test"),
    ?assertEqual(ok,dbase_test:start()),
    ?debugMsg("stop dbase_test"),

    ?debugMsg("Start deploy_test"),
    ?assertEqual(ok,deploy_test:start()),
    ?debugMsg("stop deploy_test"),

    ?debugMsg("Start create_delete_test"),
    ?assertEqual(ok,create_delete_test:start()),
    ?debugMsg("stop create_delete_test"),

      %% End application tests
  
    cleanup(),
    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    ssh:start(),
    ?debugMsg("Start boot_test"),
    ?assertEqual(ok,boot_test:start()),
    ?debugMsg("stop boot_test"),
    ?assertEqual(ok,application:start(control)),

    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
print_status()->
    timer:sleep(30*1000),
    io:format(" *************** "),
    io:format(" ~p",[{time(),?MODULE}]),
    io:format(" *************** ~n"),
    io:format("~p~n",["some info"]),
    spawn(fun()->print_status() end).




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
    init:stop(),
    ok.
