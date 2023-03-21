% This script is used to define all the variables needed to run the WT
% benchmark on Athena

% Choose the model
model = 'windturbine';

% Run script to set up the model
init_SimpleWindTurbine;
assignin('base','Parameter',Parameter)
assignin('base','cP_modelrm',cP_modelrm)
assignin('base','cT_modelrm',cT_modelrm)

% Write requirements
wt1 = '[]_[30,630] (wt1pred)';
wt2 = '[]_[30,630](wt2pred1 /\ wt2pred2)';
wt3 = '[]_[30,630](wt3pred)';
wt4 = '[]_[30,630](<>_[0,5] (wt4pred1 /\ wt4pred2))';

preds(1).str = 'wt1pred';
preds(1).A = [0 0 0 0 0 1];
preds(1).b = 14.2;
preds(1).Normalized = 1;
preds(1).NormBounds = 1;

preds(2).str = 'wt2pred1';
preds(2).A = [0 0 -1 0 0 0];
preds(2).b = -21000;
preds(2).Normalized = 1;
preds(2).NormBounds = 3000;

preds(3).str = 'wt2pred2';
preds(3).A = [0 0 1 0 0 0];
preds(3).b = 47500;
preds(3).Normalized = 1;
preds(3).NormBounds = 3000;

preds(4).str = 'wt3pred';
preds(4).A = [0 0 0 0 1 0];
preds(4).b = 14.3;
preds(4).Normalized = 1;
preds(4).NormBounds = 1;

preds(5).str = 'wt4pred1';
preds(5).A = [-1 0 0 0 0 1];
preds(5).b = 1.6;
preds(5).Normalized = 1;
preds(5).NormBounds = 5;

preds(6).str = 'wt4pred2';
preds(6).A = [1 0 0 0 0 -1];
preds(6).b = 1.6;
preds(6).Normalized = 1;
preds(6).NormBounds = 5;

% Define options
athena_opt = athena_options;
athena_opt.SampTime=0.01;
athena_opt.interpolationtype={'pchip'};
athena_opt.optim_params.n_tests = 300;
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'wt1')
    athena_opt.fitnessFcn = 'customWT1';
elseif strcmpi(rid,'wt2')
    athena_opt.fitnessFcn = 'customWT2';
elseif strcmpi(rid,'wt3')
    athena_opt.fitnessFcn = 'customWT3';
elseif strcmpi(rid,'wt4')
    athena_opt.fitnessFcn = 'customWT4';
else
    error('The model WT does not contain the requirement %s.',rid);
end

% Define other parameters
sim_time = 630;
cp_array = 126;
input_range = [8, 16];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Wind~speed$'};
Athena_param.OutRange = [0, 15; 2, 3; 20000, 50000; 900, 1400; 9, 15; 0, 15];
Athena_param.OutName = {{'$Demanded~blade$','$pitch~angle$'}, '$Region$', '$Generator~torque$', ...
    '$Generator~speed$', '$Blade~speed$', '$Blade~pitch~angle$'};
