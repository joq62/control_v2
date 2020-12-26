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

    ?debugMsg("Start load_app_specs"),
    ?assertEqual(ok,load_app_specs()),
    ?debugMsg("stop load_app_specs"),

   ?debugMsg("Start read_app_specs"),
    ?assertEqual(ok,read_app_specs()),
    ?debugMsg("stop read_app_specs"),

    ?debugMsg("Start load_service_specs"),
    ?assertEqual(ok,load_service_specs()),
    ?debugMsg("stop load_service_specs"),

   ?debugMsg("Start read_service_specs"),
    ?assertEqual(ok,read_service_specs()),
    ?debugMsg("stop read_service_specs"),


    ?debugMsg("Start sd_test"),
    ?assertEqual(ok,sd_test()),
    ?debugMsg("stop sd_test"),

    
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
actual_test()->
    
    % Per app_spec actual state
    % Actual state
    ?assertEqual([{"calc_100.app_spec","1.0.0",
		   [],
		   ["adder_100.service_spec","multi_100.service_spec","divi_100.service_spec"]},
		  {"server_c_100.app_spec","1.0.0",
		   [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_a_100.app_spec","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_b_100.app_spec","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]}],
		 if_db:call(db_app_spec,read_all,[])),
    ?assertEqual(["calc_100.app_spec",
		  "server_c_100.app_spec",
		  "server_a_100.app_spec",
		  "server_b_100.app_spec"],
		 [AppSpecId||{AppSpecId,_AppSpecVsn,_Directive,_ServiceSpecs}<-if_db:call(db_app_spec,read_all,[])]),
    

    ?assertEqual([{"common","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"server","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},
		  {"dbase","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'}],
		 if_db:call(db_sd,app_spec,["server_a_100.app_spec"])),
    _AppInfo_Actual_server_a=if_db:call(db_sd,app_spec,["server_a_100.app_spec"]),
    % Wanted state
    % Directives 
    % 1. [] -> Any host 
    % 2. [{host,HostId}] -> Check if services are running tight Host
    % 3. [{host,HostId},{vm_id,VmId}] -> check hostid + vmid
    %
    ?assertEqual([{"server_a_100.app_spec","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]}],
		 if_db:call(db_app_spec,read,["server_a_100.app_spec"])),
    [AppInfoWanted_server_a]= if_db:call(db_app_spec,read,["server_a_100.app_spec"]),
     ?assertEqual([{"common","1.0.0","server_a_100.app_spec","c0","server_100",'server_100@c0'},
		   {"dbase","1.0.0","server_a_100.app_spec","c0","server_100",'server_100@c0'},
		   {"server","1.0.0","server_a_100.app_spec","c0","server_100",'server_100@c0'}],
		  wanted_service_info( AppInfoWanted_server_a)),
    [Calc]= if_db:call(db_app_spec,read,["calc_100.app_spec"]),
     ?assertEqual([{"adder_service","1.0.0","calc_100.app_spec",host_any,vm_id_any,vm_any},
		   {"multi_service","1.0.0","calc_100.app_spec",host_any,vm_id_any,vm_any},
		   {"divi_service","1.0.0","calc_100.app_spec",host_any,vm_id_any,vm_any}],
		  wanted_service_info(Calc)),
    
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
wanted_service_info({AppId,_AppVns,Directive,ServicSpecs})->
 %   {"divi_100.service_spec","divi_service","1.0.0",
 %    {application,start,[divi_service]},
 %    "https://github.com/joq62/divi_service.git"},
%[{"common","1.0.0","server_a_100.app_spec","1.0.0","c0","server_100",'server_100@c0'},    
    HostId=case lists:keyfind(host,1,Directive) of
	       false->
		   host_any;
	       {host,XHost}->
		   XHost
	   end,
    VmId=case lists:keyfind(vm_id,1,Directive) of
	       false->
		   vm_id_any;
	       {vm_id,XVmId}->
		   XVmId
	   end,
    Vm=case {HostId,VmId} of
	   {host_any, vm_id_any}->
	       vm_any;
	   {HostId,VmId}->
	       list_to_atom(VmId++"@"++HostId)
       end,
   % io:format("ServiceSpecs ~p~n",[ServicSpecs]),
    
    ServiceInfo=lists:append([if_db:call(db_service_def,read,[ServiceSpec])||ServiceSpec<-ServicSpecs]),
   % io:format("ServiceInfo ~p~n",[ServiceInfo]),
 %   C=[X||X<-ServiceInfo],
  %  io:format("C ~p~n",[C]),
 %   C.
    [{ServiceId,ServiceVsn,AppId,HostId,VmId,Vm}||{_ServiceSpec,ServiceId,ServiceVsn,_StartCmd,_GitPath}<-ServiceInfo].
    

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
		   [],
		   ["adder_100.service_spec","multi_100.service_spec","divi_100.service_spec"]},
		  {"server_c_100.app_spec","1.0.0",
		   [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_a_100.app_spec","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_b_100.app_spec","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]}],
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
    

 % 
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
sd_test()->
    ServiceId="S1",
    ServiceVsn="1.2.3",
    AppId="A11",
    AppVsn="2.0.0",
    HostId="c0",
    VmId="server_100",
    Vm='server_100@c0',
    ?assertEqual({atomic,ok},if_db:call(db_sd,create,[ServiceId,ServiceVsn,AppId,AppVsn,HostId,VmId,Vm])),
    ?assertEqual(['server_100@c0'],if_db:call(db_sd,get,[ServiceId,ServiceVsn])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,create,[ServiceId,ServiceVsn,AppId,AppVsn,HostId,VmId,Vm])),
    ?assertEqual(['server_100@c0'],if_db:call(db_sd,get,[ServiceId,ServiceVsn])),

    ?assertEqual({atomic,ok},if_db:call(db_sd,create,[ServiceId,ServiceVsn,AppId,AppVsn,HostId,VmId,'server_100@c1'])),
    ?assertEqual(['server_100@c0','server_100@c1'],if_db:call(db_sd,get,[ServiceId,ServiceVsn])),

    ?assertEqual([{"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c0'},
		  {"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c1'}],
		 if_db:call(db_sd,read,[ServiceId,ServiceVsn])),

    ?assertEqual([{"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c0'},
		  {"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c1'}],
	      if_db:call(db_sd,host,["c0"])),
    ?assertEqual([{"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c0'},
		  {"S1","1.2.3","A11","2.0.0","c0","server_100",'server_100@c1'}],
	      if_db:call(db_sd,app_spec,[AppId])),
    
    
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
    ?assertEqual([{"calc_100.app_spec","1.0.0",
		   [],
		   ["adder_100.service_spec","multi_100.service_spec","divi_100.service_spec"]},
		  {"server_c_100.app_spec","1.0.0",
		   [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_a_100.app_spec","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_b_100.app_spec","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]}],
		 if_db:app_spec_read_all()),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
read_app_specs()->
    ?assertEqual([{"calc_100.app_spec","1.0.0",
		   [],
		   ["adder_100.service_spec","multi_100.service_spec","divi_100.service_spec"]},
		  {"server_c_100.app_spec","1.0.0",
		   [{host,"c2"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_a_100.app_spec","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]},
		  {"server_b_100.app_spec","1.0.0",
		   [{host,"c1"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]}],
		 control:read_app_specs()),

    ?assertEqual([ {"server_a_100.app_spec","1.0.0",
		   [{host,"c0"},{vm_id,"server_100"},{vm_dir,"server_100"}],
		   ["common_100.service_spec","dbase_100.service_spec","server_100.service_spec"]}],
		 control:read_app_spec("server_a_100.app_spec")),
 %   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load_service_specs()->

    ?assertEqual(ok,control:load_service_specs(?ServiceSpecsDir,?GitUser,?GitPassWd)),
    ?assertEqual([{"multi_100.service_spec","multi_service","1.0.0",
		  {application,start,[multi_service]},
		  "https://github.com/joq62/multi_service.git"},
		 {"server_100.service_spec","server","1.0.0",
		  {application,start,[server]},
		  "https://github.com/joq62/server.git"},
		 {"adder_100.service_spec","adder_service","1.0.0",
		  {application,start,[adder_service]},
		  "https://github.com/joq62/adder_service.git"},
		 {"divi_100.service_spec","divi_service","1.0.0",
		  {application,start,[divi_service]},
		  "https://github.com/joq62/divi_service.git"},
		 {"common_100.service_spec","common","1.0.0",
		  {application,start,[common]},
		  "https://github.com/joq62/common.git"},
		 {"dbase_100.service_spec","dbase","1.0.0",
		  {application,start,[dbase]},"https://github.com/joq62/dbase.git"}],
		 if_db:call(db_service_def,read_all,[])),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
read_service_specs()->
    ?assertEqual([{"multi_100.service_spec","multi_service","1.0.0",
		  {application,start,[multi_service]},
		  "https://github.com/joq62/multi_service.git"},
		 {"server_100.service_spec","server","1.0.0",
		  {application,start,[server]},
		  "https://github.com/joq62/server.git"},
		 {"adder_100.service_spec","adder_service","1.0.0",
		  {application,start,[adder_service]},
		  "https://github.com/joq62/adder_service.git"},
		 {"divi_100.service_spec","divi_service","1.0.0",
		  {application,start,[divi_service]},
		  "https://github.com/joq62/divi_service.git"},
		 {"common_100.service_spec","common","1.0.0",
		  {application,start,[common]},
		  "https://github.com/joq62/common.git"},
		 {"dbase_100.service_spec","dbase","1.0.0",
		  {application,start,[dbase]},"https://github.com/joq62/dbase.git"}],
		 control:read_service_specs()),

    ?assertEqual([{"adder_100.service_spec","adder_service","1.0.0",
		   {application,start,[adder_service]},
		   "https://github.com/joq62/adder_service.git"}],
		 control:read_service_spec("adder_100.service_spec")),
 %   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

cleanup()->

    ok.
