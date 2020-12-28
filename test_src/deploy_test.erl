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
-define(ServiceSpecsDir,"service_specs").
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
    
    ?debugMsg("Start setup_actual_test"),
    ?assertEqual(ok,setup_actual_test()),
    ?debugMsg("stop setup_actual_test"),
    
    
    ?debugMsg("Start actual_test"),
    ?assertEqual(ok,actual_test()),
    ?debugMsg("stop actual_test"),
    
    ?debugMsg("Start wanted_test"),
    ?assertEqual(ok,wanted_test()),
    ?debugMsg("stop wanted_test"),



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
actual_test()->
    ?assertEqual(["server_c_100.app_spec","test1_100.app_spec"],
		 deployment:missing_apps()),

    ?assertEqual(["A11"],
	       deployment:depricated_apps()),


    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup_actual_test()->
    
    % Fake 
   % ?assertEqual({atomic,ok},if_db:call(db_sd,create,[ServiceId,ServiceVsn,AppId,AppVsn,HostId,VmId,Vm])),
    
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["adder_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["divi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["multi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["common","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["dbase","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["server","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["common","1.0.0","server_b_100.app_spec","1.0.0","c1","server_100",'server_100@c1'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["dbase","1.0.0","server_b_100.app_spec","1.0.0","c1","server_100",'server_100@c1'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,["server","1.0.0","server_b_100.app_spec","1.0.0","c1","server_100",'server_100@c1'])),

    ?assertEqual(['server_100@c0','server_100@c1'],if_db:call(db_sd,get,["common","1.0.0"])),

    ?assertEqual([{"multi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'}],
		 if_db:call(db_sd,read,["multi_service","1.0.0"])),

    ?assertEqual([{"adder_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'},
		  {"common","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"server","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"dbase","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"divi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'},
		  {"multi_service","1.0.0","calc_100.app_spec","not_relevant","c0","calc_100",'calc_100@c0'},
		  {"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c0'},
		  {"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c1'}],
		 if_db:call(db_sd,host,["c0"])),
    ?assertEqual([{"common","1.0.0","server_b_100.app_spec","1.0.0","c1","server_100",'server_100@c1'},
		  {"server","1.0.0","server_b_100.app_spec","1.0.0","c1","server_100",'server_100@c1'},
		  {"dbase","1.0.0","server_b_100.app_spec","1.0.0","c1","server_100",'server_100@c1'}],
		 if_db:call(db_sd,host,["c1"])),
    ?assertEqual([{"common","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"server","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"dbase","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'}],
		 if_db:call(db_sd,app_spec,["server_a_100.app_spec"])),

    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
wanted_test()->
    % read all appspecs
    ?assertEqual([{"calc_100.app_spec","1.0.0",
		  [{host,any},{vm_id,any},{vm_dir,any}],
		  ["adder_100.service_spec","multi_100.service_spec","divi_100.service_spec"]},
		 {"server_c_100.app_spec","1.0.0",
		  [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		  ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		 {"server_a_100.app_spec","1.0.0",
		  [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		  ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		 {"server_b_100.app_spec","1.0.0",
		  [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		  ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		 {"test1_100.app_spec","1.0.0",
		  [{host,"c0"},{vm_id,"test1_100"},{vm_dir,"test1_100"}],
		  ["common_100.service_spec","multi_100.service_spec"]}],
		 if_db:call(db_app_spec,read_all,[])),

    ?assertEqual([{"adder_100.service_spec","adder_service","1.0.0",
		   {application,start,[adder_service]},
		   "https://github.com/joq62/adder_service.git"}],
		 if_db:call(db_service_def,read,["adder_100.service_spec"])),
   
    
    %[{app_id,"server_b_100.app_spec","1.0.0"},{constraints,[{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}]},{spec_id,"common_100.service_spec"},
    % {service,"common","1.0.0"},{start_cmd,{application,start,[common]}},{gitpath,"https://github.com/joq62/common.git"}],
    _AllServiceInfo=service_info(if_db:call(db_app_spec,read_all,[]),[]),


    ok.

%-------------------------------
%% Wnated postion
%% Which services  



service_info([],ServiceInfoList)->
    ServiceInfoList;
service_info([{AppId,AppVsn,Constraints,ServiceSpecs}|T],Acc)->
    W1=lists:append([if_db:call(db_service_def,read,[SpecId])||SpecId<-ServiceSpecs]),
    W2=[[{app_id,AppId,AppVsn},{constraints,Constraints},{spec_id,SpecId},{service,ServiceId,ServiceVsn},{start_cmd,StartCmd},{gitpath,GitPath}]||{SpecId,ServiceId,ServiceVsn,StartCmd,GitPath}<-W1],
    service_info(T,lists:append(W2,Acc)).
    

 
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

cleanup()->
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["adder_service","1.0.0",'calc_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["divi_service","1.0.0",'calc_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["multi_service","1.0.0",'calc_100@c0'])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["common","1.0.0",'server_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["dbase","1.0.0",'server_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["server","1.0.0",'server_100@c0'])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["common","1.0.0",'server_100@c1'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["dbase","1.0.0",'server_100@c1'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["server","1.0.0",'server_100@c1'])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["S1","1.2.3",'server_100@c0'])),
    ?assertEqual({atomic,ok},if_db:call(db_sd,delete,["S1","1.2.3",'server_100@c1'])),

    ok.
