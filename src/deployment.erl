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
    Result=case if_db:deployment_spec_read(AppId,AppVsn) of
	       []->
		   {error,[eexists,AppId,AppVsn,?MODULE,?LINE]};
	       DeploymentInfo->
		   [{AppId,AppVsn,Restriction,ServiceList}]=DeploymentInfo,
		   case Restriction of
		       no_restrictions->
			   [{"iaas",_,_HostId,_VmId,IaasVm}|_]=if_db:sd_read("iaas"),
			   {ok,WorkerHostId,WorkerVmId}=rpc:call(IaasVm,iaas,allocate_vm,[],5000),
			   StartResult=[{service:create(ServiceId,ServiceVsn,WorkerHostId,WorkerVmId),ServiceId,ServiceVsn,WorkerHostId,WorkerVmId}||{ServiceId,ServiceVsn}<-ServiceList],
			   case [Result||{Result,ServiceId,ServiceVsn,WorkerHostId,WorkerVmId}<-StartResult,
					 Result/=ok] of
			       []-> %ok!
				   [if_db:sd_create(ServiceId,ServiceVsn,WorkerHostId,WorkerVmId,list_to_atom(WorkerHostId++"@"++WorkerVmId))||{ok,ServiceId,ServiceVsn,WorkerHostId,WorkerVmId}<-StartResult],
				   StartResult;
			       _->
				   StartResult
			   end;
		       _ ->
			   {error,[not_implemented,?MODULE,?LINE]}
		   end
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

depricate_app(DeplId)->
    not_implemented.

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
