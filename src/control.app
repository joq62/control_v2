%% This is the application resource file (.app file) for the 'base'
%% application.
{application, control,
[{description, "control" },
{vsn, "0.0.1" },
{modules, 
	  [control_app,control_sup,control,control,
		orchistrate]},
{registered,[control]},
{applications, [kernel,stdlib]},
{mod, {control_app,[]}},
{start_phases, []}
]}.
