%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(scheduler).
  

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%-compile(export_all).
-export([wanted_services/0,
	 lost_services/0,
	 depricated_services/0,
	 get_host_allocation/1
	]).

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
get_host_allocation(lowest)->
    glurk.

    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
%% {DeplId,SpecId,Vsn,Date,Time,SdList,XStatus}

actual_state()->
    AllDeployments=if_db:deployment_read_all(),
    %% Available Hosts 

    %% Available Vms

    %%%
    R=AllDeployments,
    R.


    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% 
%%
%% --------------------------------------------------------------------
