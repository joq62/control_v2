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
-export([deploy_app/2,
	 depricate_app/1,
	 create_spec/4,
	 read_spec/2,
	 delete_spec/2]).

%% ====================================================================
%% External functions
%% ====================================================================
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
