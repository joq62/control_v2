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
-export([orphans/0,
	 deploy_app/2,
	 depricate_app/1,
	 create_spec/4,
	 read_spec/2,
	 delete_spec/2,
	 check_update/0
	]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

orphans()->
    % Active services
    AllServices=if_db:sd_read_all(), %{"control","1.0.0","asus","10250",'10250@asus'},
    Ping=[{rpc:call(Vm,list_to_atom(ServiceId),ping,[],5000),ServiceId,Vsn,HostId,VmId,Vm}||{ServiceId,Vsn,HostId,VmId,Vm}<-AllServices],
    ActiveService=[{ServiceId,Vsn,HostId,VmId,Vm}||{{pong,_,_},ServiceId,Vsn,HostId,VmId,Vm}<-Ping],
 %   io:format("ActiveService = ~p~n",[{ActiveService,?MODULE,?LINE}]),
    Result= case if_db:deployment_read_all() of
		[]->
%		    io:format(" = ~p~n",[{?MODULE,?LINE}]),
		    [if_db:sd_delete(ServiceId,ServiceVsn,ServiceVm)||{ServiceId,ServiceVsn,_HostId,_VmId,ServiceVm}<-ActiveService],
		    [IaasVm]=if_db:sd_get("iaas"),
		    [rpc:call(IaasVm,vm,free,[Vm],10000)||{_ServiceId,_Vsn,_HostId,_VmId,Vm}<-ActiveService],
		    Orphans=ActiveService,
		    {ok,Orphans};
		Deployments ->
%		    io:format("Deployments = ~p~n",[{Deployments,?MODULE,?LINE}]),
		    % Remove all services that are present in Deployments
		    % Deployments=[{DeplId,SpecId,Vsn,Date,Time,HostId,VmId,SdList,Status}]
		    % SdList=[{"control","1.0.0",'10250@asus'}]
		    % ActiveService={ServiceId,Vsn,HostId,VmId,Vm}
		    
		    ListOfSdLists=[SdList||{_DeplId,_SpecId,_Vsn,_Date,_Time,_HostId,_VmId,SdList,_Status}<-Deployments],
		    WantedService=lists:append(ListOfSdLists),
		 %   io:format("WantedService = ~p~n",[{WantedService,?MODULE,?LINE}]),
		    Orphans=remove_orphan(ActiveService,WantedService,[]),
		    {ok,Orphans}
	    end,
    Result.

remove_orphan([],_,Orphans)->
    Orphans;
remove_orphan([{ServiceId,ServiceVsn,_HostId,_VmId,ServiceVm}|T],WantedService,Acc)->
    NewAcc=case lists:member({ServiceId,ServiceVsn,ServiceVm},WantedService) of
	       false->
		%   io:format("remove = ~p~n",[{ServiceId,ServiceVsn,ServiceVm,?MODULE,?LINE}]),
		   if_db:sd_delete(ServiceId,ServiceVsn,ServiceVm),
		   [IaasVm]=if_db:sd_get("iaas"),
		   rpc:call(IaasVm,vm,free,[ServiceVm],10000),
		   [{remove,ServiceId,ServiceVsn,ServiceVm}|Acc];
	       true ->
		   Acc
    end,
    remove_orphan(T,WantedService,NewAcc).
    
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
deploy_app(AppId,AppVsn)->
    DeployResult=case if_db:deployment_spec_read(AppId,AppVsn) of
		     []->
			 {error,[eexists,AppId,AppVsn,?MODULE,?LINE]};
		     DeploymentInfo->
			 [{AppId,AppVsn,Restriction,ServiceList}]=DeploymentInfo,
			 case Restriction of
			     no_restrictions->
				 [{"iaas",_,_HostId,_VmId,IaasVm}|_]=if_db:sd_read("iaas"),
			%	 {ok,WorkerHostId,WorkerVmId}=ensure_not_reactivated_vm(),
				case rpc:call(IaasVm,iaas,allocate_vm,[],2*5000) of
				     {ok,WorkerHostId,WorkerVmId}->
					StartResult=[{rpc:call(node(),service,create,[ServiceId,ServiceVsn,WorkerHostId,WorkerVmId],1*60*5000),ServiceId,ServiceVsn,WorkerHostId,WorkerVmId}||{ServiceId,ServiceVsn}<-ServiceList],
					case [Result||{Result,_ServiceId,_ServiceVsn,_WorkerHostId,_WorkerVmId}<-StartResult,
						      Result/=ok] of
					    []-> %ok!
						[if_db:sd_create(YServiceId,YServiceVsn,YWorkerHostId,YWorkerVmId,list_to_atom(YWorkerVmId++"@"++YWorkerHostId))||{ok,YServiceId,YServiceVsn,YWorkerHostId,YWorkerVmId}<-StartResult],
						SdList=[{ZServiceId,ZServiceVsn,list_to_atom(ZWorkerVmId++"@"++ZWorkerHostId)}||{ok,ZServiceId,ZServiceVsn,ZWorkerHostId,ZWorkerVmId}<-StartResult],
						DeplId={node(),erlang:system_time()},
						if_db:deployment_create(DeplId,AppId,AppVsn,date(),time(),WorkerHostId,WorkerVmId,SdList,started),
						{ok,DeplId};
					    _->
						io:format("Error StartResult = ~p~n",[{StartResult,?MODULE,?LINE}]), 
						rpc:call(IaasVm,iaas,free_vm,[list_to_atom(WorkerVmId++"@"++WorkerHostId)],5000),
						{error,[StartResult]}
					end;
				    {error,Err}->
					{error,Err}
				end;
			     _ ->
				 {error,[not_implemented,?MODULE,?LINE]}
			 end
		 end,
    
    DeployResult.

    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

depricate_app(DeplId)->
    Result= case if_db:deployment_read(DeplId) of
		[]->
		    {error,[eexists,DeplId]};
		DeploymentInfo->
		    {_DeplId,_SpecId,_Vsn,_Date,_Time,HostId,VmId,SdList,_Status}=DeploymentInfo,
		    [if_db:sd_delete(ServiceId,ServiceVsn,ServiceVm)||{ServiceId,ServiceVsn,ServiceVm}<-SdList],
		    if_db:deployment_delete(DeplId),
		    [IaasVm]=if_db:sd_get("iaas"),
		    ok=rpc:call(IaasVm,vm,free,[list_to_atom(VmId++"@"++HostId)],10000),
		    ok
	    end,
    Result.

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%
%% --------------------------------------------------------------------
create_spec(AppId,AppVsn,Restriction,ServiceList)->
    Reply=case if_db:deployment_spec_read(AppId,AppVsn) of
	      []->
		  if_db:deployment_spec_create(AppId,AppVsn,Restriction,ServiceList),
		  ok;
	      Err->
		  {error,[already_defined,Err,AppId,AppVsn]}
	  end,
    Reply.

read_spec(AppId,AppVsn)->
    if_db:deployment_spec_read(AppId,AppVsn).

delete_spec(AppId,AppVsn)->
    if_db:deployment_spec_delete(AppId,AppVsn).



%% --------------------------------------------------------------------
%% 
%%
%% --------------------------------------------------------------------
 % 1. Host running -> Vm running -> 3. Services running  == ok
    % 1. Host running -> Vm running -> 3. Services not running -> start new deployment , delete old and store new
    % 1  Host not running -> sd_delete(AllServices on Host) 
    % 2. Vm not running -> sd_delete(AllServices on Vm) 
    % 3. Host running ->  Vm not running ->  Vm not running
    % 1. Host running ->  Vm not running -> Services running -> sd_delete(AllServices on Vm) , 

check_update()->
    case if_db:deployment_read_all() of
	[]->
	    [];
	DeploymentInfoList ->  %[{DeplId,SpecId,Vsn,Date,Time,HostId,VmId,SdList,_Status}]
	    [IaasVm]=if_db:sd_get("iaas"),
	    AvailableComputers=rpc:call(IaasVm,iaas,computer_status,[available],10000),  
	    NotAvailableComputers=rpc:call(IaasVm,iaas,computer_status,[not_available],10000),
	    case lists:append(AvailableComputers,NotAvailableComputers) of
		[]->
		    [];
		LostComputers->
	%	    io:format(" LostComputers= ~p~n",[{LostComputers,?MODULE,?LINE}]),
		    LostDeployments=act_lost_computers(DeploymentInfoList,LostComputers,[]),	 
	%	    io:format(" LostDeployments= ~p~n",[{LostDeployments,?MODULE,?LINE}])
		    ok
	    end
    end,
    act_lost_deployments().

act_lost_computers([],_,LostServices)->
    LostServices;
act_lost_computers([{DeplId,AppId,AppVsn,_Date,_Time,HostId,VmId,SdList,_Status}|T],LostComputers,Acc)->
    NewAcc=case lists:member(HostId,LostComputers) of
	       true->
		   [{if_db:sd_delete(ServiceId,ServiceVsn,Vm),rpc:call(Vm,application,stop,[list_to_atom(ServiceId)]),ServiceId,ServiceVsn,Vm}||{ServiceId,ServiceVsn,Vm}<-SdList],
		   if_db:deployment_update_status(DeplId,stopped),
		   [{DeplId,AppId,AppVsn,_Date,_Time,HostId,VmId,SdList,_Status}|Acc];
	       false->
		   Acc
	   end,
    act_lost_computers(T,LostComputers,NewAcc).
    
	    

act_lost_deployments()->
    LostDeployments=if_db:deployment_status(stopped),
    act_lost_deployments(LostDeployments,[]).
act_lost_deployments([],UpdateResult)->
    UpdateResult;
act_lost_deployments([{DeplId,AppId,AppVsn,_Date,_Time,_HostId,_VmId,_SdList,_Status}|T],Acc)->
    NewAcc=case  rpc:call(node(),control,deploy_app,[AppId,AppVsn]) of
	       {ok,NewDeplId}->
		   io:format("NewDeplId = ~p~n",[{NewDeplId,?MODULE,?LINE}]), 
		   rpc:call(node(),control,delete_deployment,[DeplId],5000),
						%depricate_app(DeplId),
		   timer:sleep(200),
		   [{ok,NewDeplId,AppId,AppVsn}||Acc];
	       {error,Err}->
		   io:format(" {error,Err} = ~p~n",[{ {error,Err},?MODULE,?LINE}]), 
		   [{error,Err,AppId,AppVsn}||Acc];
	       {badrpc,Err}->
		   io:format(" {badrpc,Err} = ~p~n",[{ {badrpc,Err},?MODULE,?LINE}]), 
		   [{badrpc,Err,AppId,AppVsn}||Acc]
	   end,
    act_lost_deployments(T,NewAcc).
        
