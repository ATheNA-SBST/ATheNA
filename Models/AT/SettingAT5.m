% This script is used to define all the variables needed to run the AT
% benchmark on Aristeo.

% Choose the model
model = @blackbox_autotrans;

% Write requirements
at51 = '[]_[0.0, 30.0] ((!(gear1) /\ <>_[0.001, 0.1] (gear1)) -> <>_[0.001, 0.1] []_[0.0, 2.5] (gear1))';
at52 = '[]_[0.0, 30.0] ((!(gear2) /\ <>_[0.001, 0.1] (gear2)) -> <>_[0.001, 0.1] []_[0.0, 2.5] (gear2))';
at53 = '[]_[0.0, 30.0] ((!(gear3) /\ <>_[0.001, 0.1] (gear3)) -> <>_[0.001, 0.1] []_[0.0, 2.5] (gear3))';
at54 = '[]_[0.0, 30.0] ((!(gear4) /\ <>_[0.001, 0.1] (gear4)) -> <>_[0.001, 0.1] []_[0.0, 2.5] (gear4))';

preds(1).str = 'gear1';
preds(1).A = [];
preds(1).b = [];
preds(1).loc = 1;

preds(2).str = 'gear2';
preds(2).A = [];
preds(2).b = [];
preds(2).loc = 2;

preds(3).str = 'gear3';
preds(3).A = [];
preds(3).b = [];
preds(3).loc = 3;

preds(4).str = 'gear4';
preds(4).A = [];
preds(4).b = [];
preds(4).loc = 4;

% Define options
athena_opt = athena_options;
athena_opt.black_box = 1;
athena_opt.loc_traj = 'end';
athena_opt.taliro_metric = 'hybrid_inf';
athena_opt.SampTime=0.01;
athena_opt.interpolationtype={'pchip','pchip'};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'at51')
    athena_opt.fitnessFcn = 'customAT51';
elseif strcmpi(rid,'at52')
    athena_opt.fitnessFcn = 'customAT52';
elseif strcmpi(rid,'at53')
    athena_opt.fitnessFcn = 'customAT53';
elseif strcmpi(rid,'at54')
    athena_opt.fitnessFcn = 'customAT54';
else
    error('The model AT does not contain the requirement %s.',rid);
end

% Define other parameters
sim_time = 50;
cp_array = [7, 3];
input_range = [0 100; 0 325];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Throttle~[\%]$', '$Brake~[lb-ft]$'};
Athena_param.OutRange = [0, 150; 0, 5000; 1, 4];
Athena_param.OutName = {'$Speed~[mph]$', '$RPM~[rpm]$', '$Gear~[/]$'};