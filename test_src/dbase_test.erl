%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(dbase_test). 
    
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


    ?assertEqual(ok,cleanup()),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
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
		 if_db:app_spec_read_all()),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
read_app_specs()->
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
