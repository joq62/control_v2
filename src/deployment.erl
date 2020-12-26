%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(deployment).
 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%-compile(export_all).
-export([load_app_specs/3,
	 read_app_specs/0,
	 read_app_spec/1,
	 load_service_specs/3,
	 read_service_specs/0,
	 read_service_spec/1
	]).

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_app_spec(AppId)->
    if_db:call(db_app_spec,read,[AppId]).
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_app_specs()->
    if_db:call(db_app_spec,read_all,[]).
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

load_app_specs(AppSpecDir,GitUser,GitPassWd)->
     %% Get initial configuration
    os:cmd("rm -rf "++AppSpecDir),
    GitCmd="git clone https://"++GitUser++":"++GitPassWd++"@github.com/"++GitUser++"/"++AppSpecDir++".git",
    os:cmd(GitCmd),
    Result=case file:list_dir(AppSpecDir) of
	       {ok,FileNames}->
		   SpecFileNames=[filename:join(AppSpecDir,FileName)||FileName<-FileNames,
					       ".app_spec"==filename:extension(FileName)],
		   L1=[file:consult(FileName)||FileName<-SpecFileNames],
		   L2=[Info||{ok,[Info]}<-L1],
		   DbaseResult=[R||R<-dbase:init_table_info(L2),
				   R/={atomic,ok}],
		   case DbaseResult of
			[]->
			   ok;
		       Reason->
			   {error,Reason}
		   end;
	       {error,Reason} ->
		   {error,Reason}
	   end, 
    Result.
    

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_service_spec(Id)->
    if_db:call(db_service_def,read,[Id]).
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_service_specs()->
    if_db:call(db_service_def,read_all,[]).
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

load_service_specs(SpecDir,GitUser,GitPassWd)->
     %% Get initial configuration
    os:cmd("rm -rf "++SpecDir),
    GitCmd="git clone https://"++GitUser++":"++GitPassWd++"@github.com/"++GitUser++"/"++SpecDir++".git",
    os:cmd(GitCmd),
    Result=case file:list_dir(SpecDir) of
	       {ok,FileNames}->
		   SpecFileNames=[filename:join(SpecDir,FileName)||FileName<-FileNames,
								   ".service_spec"==filename:extension(FileName)],
		   L1=[file:consult(FileName)||FileName<-SpecFileNames],
		   L2=[Info||{ok,[Info]}<-L1],
		   L3=dbase:init_table_info(L2),
		   DbaseResult=[R||R<-L3,
				   R/={atomic,ok}],
		   
		   case DbaseResult of
			[]->
			   ok;
		       Reason->
			   {error,Reason}
		   end;
	       {error,Reason} ->
		   {error,Reason}
	   end, 
    Result.
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
