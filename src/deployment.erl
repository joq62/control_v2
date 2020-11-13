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
				 {ok,WorkerHostId,WorkerVmId}=rpc:call(IaasVm,iaas,allocate_vm,[],5000),
				 StartResult=[{service:create(ServiceId,ServiceVsn,WorkerHostId,WorkerVmId),ServiceId,ServiceVsn,WorkerHostId,WorkerVmId}||{ServiceId,ServiceVsn}<-ServiceList],
				 case [Result||{Result,_ServiceId,_ServiceVsn,_WorkerHostId,_WorkerVmId}<-StartResult,
					       Result/=ok] of
				     []-> %ok!
					 [if_db:sd_create(YServiceId,YServiceVsn,YWorkerHostId,YWorkerVmId,list_to_atom(YWorkerVmId++"@"++YWorkerHostId))||{ok,YServiceId,YServiceVsn,YWorkerHostId,YWorkerVmId}<-StartResult],
					 SdList=[{ZServiceId,ZServiceVsn,list_to_atom(ZWorkerVmId++"@"++ZWorkerHostId)}||{ok,ZServiceId,ZServiceVsn,ZWorkerHostId,ZWorkerVmId}<-StartResult],
					 DeplId={node(),erlang:system_time()},
					 if_db:deployment_create(DeplId,AppId,AppVsn,date(),time(),WorkerHostId,WorkerVmId,SdList,tabort),
					 {ok,DeplId};
				     _->
					 {error,[StartResult]}
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
check_update()->
    Deployment_to_start =case if_db:deployment_read_all() of
			     []->
				 [];
			     DeploymentInfoList ->  %[{DeplId,SpecId,Vsn,Date,Time,HostId,VmId,SdList,_Status}]
				 
				 check(DeploymentInfoList,[])
			 end,
    
    Deployment_to_start.

check([],CheckResult)->
    CheckResult;			 
check([{DeplId,AppId,AppVsn,_Date,_Time,HostId,VmId,SdList,_Status}|T],Acc)->
      
    NewAcc=case net_adm:ping(list_to_atom(VmId++"@"++HostId)) of
	       pong-> %ok
		   case do_ping(SdList,ok) of
		       ok->
			   Acc;
		       error ->
			   R=deploy_app(AppId,AppVsn),
			   depricate_app(DeplId),
			   [R|Acc]		
		   end;
	       _ ->
		   [if_db:sd_delete(ServiceId,ServiceVsn,Vm)||{ServiceId,ServiceVsn,Vm}<-SdList],
		   R=deploy_app(AppId,AppVsn),
		   depricate_app(DeplId),
		   [R|Acc]	
	   end,
    check(T,NewAcc).
    
do_ping([],R)->
    R;
do_ping(_,error)->
    error;
do_ping([{ServiceId,ServiceVsn,Vm}|T],_)->
    Result=case rpc:call(Vm,list_to_atom(ServiceId),ping,[],2000) of
	       {pong,_,_}->
		   ok;
	       _ ->
		   if_db:sd_delete(ServiceId,ServiceVsn,Vm),
		   error
	   end,
    do_ping(T,Result).
