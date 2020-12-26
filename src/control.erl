%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(control). 

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{missing,obsolite,failed}).


%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(HbInterval,30*1000).

-export([load_deployment_specs/3,
	 read_deployment_specs/1
	]).

-export([create_service/4,delete_service/4,
	 create_deployment_spec/3,
	 delete_deployment_spec/2,
	 read_deployment_spec/2,
	 deploy_app/2,
	 depricate_app/1,
	 delete_deployment/1
	]).

-export([start/0,
	 stop/0,
	 ping/0,
	 heart_beat/1
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals



%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

%%-----------------------------------------------------------------------
load_deployment_specs(DepSpecDir,GitUser,GitPassWd)->
    gen_server:call(?MODULE, {load_deployment_specs,DepSpecDir,GitUser,GitPassWd},infinity). 
read_deployment_specs(DepSpecDir)->
    gen_server:call(?MODULE, {read_deployment_specs,DepSpecDir},infinity). 

create_service(ServiceId,Vsn,HostId,VmId)->
    gen_server:call(?MODULE, {create_service,ServiceId,Vsn,HostId,VmId},infinity).    
delete_service(ServiceId,Vsn,HostId,VmId)->
    gen_server:call(?MODULE, {delete_service,ServiceId,Vsn,HostId,VmId},infinity).  

deploy_app(AppId,AppVsn)->
    gen_server:call(?MODULE, {deploy_app,AppId,AppVsn},infinity).
depricate_app(DeploymentId)->
    gen_server:call(?MODULE, {depricate_app,DeploymentId},infinity).
delete_deployment(DeploymentId)->
    gen_server:call(?MODULE, {delete_deployment,DeploymentId},infinity).
    
create_deployment_spec(AppId,AppVsn,ServiceList)->
    gen_server:call(?MODULE, {create_deployment_spec,AppId,AppVsn,ServiceList},infinity).
delete_deployment_spec(AppId,AppVsn)->
    gen_server:call(?MODULE, {delete_deployment_spec,AppId,AppVsn},infinity).
read_deployment_spec(AppId,AppVsn)->
    gen_server:call(?MODULE, {read_deployment_spec,AppId,AppVsn},infinity).

heart_beat(Interval)->
    gen_server:cast(?MODULE, {heart_beat,Interval}).


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    spawn(fun()->h_beat(?HbInterval) end),     
    
    {ok, #state{}}.   
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({read_deployment_specs,DepSpecDir},_From,State) ->
    Reply=rpc:call(node(),deployment,read_deployment_specs,[DepSpecDir],2*5000),
    {reply, Reply, State};

handle_call({load_deployment_specs,DepSpecDir,GitUser,GitPassWd},_From,State) ->
    Reply=rpc:call(node(),deployment,load_deployment_specs,[DepSpecDir,GitUser,GitPassWd],2*5000),
    {reply, Reply, State};


handle_call({create_service,ServiceId,Vsn,HostId,VmId},_From,State) ->
    Reply=rpc:call(node(),service,create,[ServiceId,Vsn,HostId,VmId],2*5000),
    {reply, Reply, State};

handle_call({delete_service,ServiceId,Vsn,HostId,VmId},_From,State) ->
    Reply=rpc:call(node(),service,delete,[ServiceId,Vsn,HostId,VmId],5000),
    {reply, Reply, State};

handle_call({deploy_app,AppId,AppVsn},_From,State) ->
    Reply=rpc:call(node(),deployment,deploy_app,[AppId,AppVsn],25000),
    {reply, Reply, State};

handle_call({depricate_app,DeploymentId},_From,State) ->
    Reply=rpc:call(node(),deployment,depricate_app,[DeploymentId],5000),
    {reply, Reply, State};
handle_call({delete_deployment,DeploymentId},_From,State) ->
    Reply=if_db:deployment_delete(DeploymentId),
    {reply, Reply, State};

handle_call({create_deployment_spec,AppId,AppVsn,ServiceList},_From,State) ->
    Reply=rpc:call(node(),deployment,create_spec,[AppId,AppVsn,ServiceList],5000),
    {reply, Reply, State};

handle_call({delete_deployment_spec,AppId,AppVsn},_From,State) ->
    Reply=rpc:call(node(),deployment,delete_spec,[AppId,AppVsn],5000),
    {reply, Reply, State};

handle_call({read_deployment_spec,AppId,AppVsn},_From,State) ->
    Reply=rpc:call(node(),deployment,read_spec,[AppId,AppVsn],5000),
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    %?LOG_INFO(error,{unmatched_signal,Request,From}),
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
handle_cast({heart_beat,Interval}, State) ->
     spawn(fun()->h_beat(Interval) end),    
    {noreply, State};

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
h_beat(Interval)->
    case rpc:call(node(),iaas,machine_status,[all],3*1000) of
	{badrpc,Reason}->
	    % log as a ticket
	    io:format("Log ticket ~p~n",[{badrpc,Reason,?MODULE,?LINE}]),
	    ok;
	Status->
	    io:format("Status ~p~n",[{Status,?MODULE,?LINE}])   
    end,
    timer:sleep(Interval),
    rpc:cast(node(),?MODULE,heart_beat,[Interval]).

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
