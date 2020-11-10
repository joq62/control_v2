%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(services).
 


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


-include("common_macros.hrl").

%-compile(export_all).
-export([available/1,missing/2,obsolite/2]).




%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% 
%% 
%% {"master_sthlm_1",'master_sthlm_1@asus'}
%% --------------------------------------------------------------------
%% @doc: available get all running applications

-spec(available(Catalog::[{ServiceId::string(),Type::atom(),Source::string()}])->[{ServiceId::string(),Node::atom()}]|[]).
available(Catalog)->
    AvailableNodes=[node()|nodes()],
    Node_AppList=[{Node,rpc:call(Node,application,which_applications,[])}||Node<-AvailableNodes],
    Node_FilteredApplist=filter_applist(Node_AppList,Catalog,[]),
    
    Node_FilteredApplist.

filter_applist([],_,FilteredApplist)->
    FilteredApplist;
filter_applist([{Node,AppList}|T],Catalog,Acc) ->
    ServiceId_NodeList=[{atom_to_list(Service),Node}||{Service,_,_}<-AppList,
							true==lists:keymember(atom_to_list(Service),1,Catalog)],
    NewAcc=lists:append(ServiceId_NodeList,Acc),
    filter_applist(T,Catalog,NewAcc). 

%% @doc: missing nodes in the cluster

-spec(missing(Catalog::[{ServiceId::string(),Type::atom(),Source::string()}],AppSpec::[tuple()])->[{ServiceId::string(),Node::atom()}]| []).
missing(Catalog,AppSpec)->
    AvailableServices=available(Catalog),
    Missing=[{ServiceId,Node}||{ServiceId,Node}<-AppSpec,
			    false==lists:member({ServiceId,Node},AvailableServices)],
    Missing.

%% @doc: obsolite nodes in the cluster

-spec(obsolite(Catalog::[{ServiceId::string(),Type::atom(),Source::string()}],AppSpec::[tuple()])->[{NodeId::string(),Node::atom()}]| []).
obsolite(Catalog,AppSpec)->
    AvailableServices=available(Catalog),
    Obsolite=[{ServiceId,Node}||{ServiceId,Node}<-AvailableServices,
			    false==lists:member({ServiceId,Node},AppSpec)],
    Obsolite.
