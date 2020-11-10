%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(service).
 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%-compile(export_all).
-export([create/4,
	 delete/4]).

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%
%% --------------------------------------------------------------------
create(ServiceId,Vsn,HostId,VmId)->
    Vm=list_to_atom(VmId++"@"++HostId),
    false=rpc:call(Vm,filelib,is_dir,[filename:join([".",VmId,ServiceId])]),
    [{ServiceId,Vsn,GitRepoUser}]=db_service_def:read(ServiceId,Vsn),
    io:format("ServiceId,Vsn,GitRepoUser ~p~n",[{?MODULE,?LINE,ServiceId,Vsn,GitRepoUser}]),
    [{_,PassWd}]=db_passwd:read(GitRepoUser),
    ok=rpc:call(Vm,file,make_dir,[VmId++"/"++ServiceId],5000),
    rpc:call(Vm,os,cmd,["git clone  https://"++GitRepoUser++":"++PassWd++"@github.com/"++GitRepoUser++"/"++ServiceId++".git"],5000),

%    io:format("~p~n",[{?MODULE,?LINE,"git clone  https://"++GitRepoUser++":"++PassWd++"@github.com/"++GitRepoUser++"/"++ServiceId++".git"}]),

  %  timer:sleep(200*1000),

 %   io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["git clone  https://"++GitRepoUser++":"++PassWd++"@github.com/"++GitRepoUser++"/"++ServiceId++".git"],5000)}]),
    
    io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["cp -r "++ServiceId++"/*"++" "++VmId++"/"++ServiceId],5000)}]),
     io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["git clone  https://"++GitRepoUser++":"++PassWd++"@github.com/"++GitRepoUser++"/include.git"],5000)}]),
     io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["mv include "++VmId],5000)}]),
     io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["cp "++VmId++"/"++ServiceId++"/src/"++ServiceId++".app "++VmId++"/"++ServiceId++"/ebin"],5000)}]),
     io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["erlc -o "++VmId++"/"++ServiceId++"/ebin "++VmId++"/"++ServiceId++"/src/*.erl"],5000)}]),
     io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,os,cmd,["rm -rf "++VmId++"/"++"include"],5000)}]),
    true=rpc:call(Vm,code,add_path,["./"++VmId++"/"++ServiceId++"/ebin"]),
    timer:sleep(1000),
			io:format("~p~n",[{?MODULE,?LINE, rpc:call(Vm,application,start,[list_to_atom(ServiceId)])}]),
%    ok=rpc:call(Vm,application,start,[list_to_atom(ServiceId)]),

    ok.

delete(ServiceId,_Vsn,HostId,VmId)->
    Vm=list_to_atom(VmId++"@"++HostId),
    ok=rpc:call(Vm,application,stop,[list_to_atom(ServiceId)]),
    rpc:call(Vm,os,cmd,["rm -rf "++VmId++"/"++ServiceId],5000),
    ok.

%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% 
%%
%% --------------------------------------------------------------------
