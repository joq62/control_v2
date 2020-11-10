%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(orchistrate).
 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").

%-compile(export_all).
-export([simple_campaign/0]).




%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% 
%%
%% --------------------------------------------------------------------
%% 1 Check missing services - try to start them
simple_campaign()->
    AppInfo=config_service:get_info(app_info),
%    io:format("AppInfo ~p~n",[{?MODULE,?LINE,AppInfo}]),
   AvailableServices=sd_service:fetch_all(all),
%   io:format("AvailableServices ~p~n",[{?MODULE,?LINE,AvailableServices}]),
    Missing=[{ServiceId,Node}||{ServiceId,Node}<-AppInfo,
			       false==lists:member({ServiceId,Node},AvailableServices)],
%    io:format("Missing ~p~n",[{?MODULE,?LINE,Missing}]),
    case Missing of
	[]->
	    FailedStarts=[],
	    ok;
	Missing->
	    ?LOG_INFO(event,['Missing services ',Missing]),
	    % io:format("StartInfoMissing ~p~n",[{?MODULE,?LINE,StartInfoMissing}]),
	    StartResult=[{Node,rpc:call(Node,vm_service,start_service,[ServiceId])}||{ServiceId,Node}<-Missing],
	    %io:format("Debug ~p~n",[{?MODULE,?LINE,Debug}]),
	    FailedStarts=[{Node,{error,Err}}||{Node,{error,Err}}<-StartResult],
	    case FailedStarts of
		[]->
		    ok;
		 FailedStarts->
		    ?LOG_INFO(error,['failed to start',FailedStarts])
	    end
    end,
    
    Obsolite=[{ServiceId,Node}||{ServiceId,Node}<-AvailableServices,
			    false==lists:member({ServiceId,Node},AppInfo)],	
 %   io:format("Obsolite ~p~n",[{?MODULE,?LINE,Obsolite}]),
    case Obsolite of
	[]->
	    ok;
	Obsolite->
	    ?LOG_INFO(event,['obsolite services',Obsolite]),
	    [rpc:call(Node,vm_service,stop_service,[ServiceId])||{ServiceId,Node}<-Obsolite]
    end,

    {Missing,Obsolite,FailedStarts}.
