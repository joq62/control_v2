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
-define(AppSpecsDir,"app_specs").
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

    ?debugMsg("Start load_app_specs"),
    ?assertEqual(ok,load_app_specs()),
    ?debugMsg("stop load_app_specs"),

   ?debugMsg("Start read_app_specs"),
    ?assertEqual(ok,read_app_specs()),
    ?debugMsg("stop read_app_specs"),

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
load_app_specs()->

    ?assertEqual(ok,control:load_app_specs(?AppSpecsDir,?GitUser,?GitPassWd)),
    ?assertEqual([{"server_a","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]},
		  {"server_b","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]},
		  {"server_c","1.0.0",
		   [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]},
		  {"calc","1.0.0",
		   [],
		   [{"adder_service","1.0.0"},{"multi_service","1.0.0"},{"divi_service","1.0.0"}]}],
		 if_db:app_spec_read_all()),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
read_app_specs()->
    ?assertEqual([{"server_a","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]},
		  {"server_b","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]},
		  {"server_c","1.0.0",
		   [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]},
		  {"calc","1.0.0",
		   [],
		   [{"adder_service","1.0.0"},{"multi_service","1.0.0"},{"divi_service","1.0.0"}]}],
		 control:read_app_specs()),

    ?assertEqual([{"server_b","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   [{"common","1.0.0"},{"dbase","1.0.0"},{"server","1.0.0"}]}],
		 control:read_app_spec("server_b","1.0.0")),
 %   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

cleanup()->

    ok.
