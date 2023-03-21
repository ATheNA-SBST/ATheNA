% This script is used to define all the variables needed to run the MV
% benchmark on Athena.
warning off codertarget:build:SupportPackageNotInstalled

% Setup model parameters
evalin('base','medicalVentilatorSystemParams');
evalin('base','controlParams');

% Choose the model
model = @blackbox_MechVent;

% Write requirements in STL
mv1 = '[]_[0,30] (press /\ vol1 /\ vol2)';

    % Proxima pressure must be lower than 30 cmH2O
preds(1).str = 'press';
preds(1).A = [1 0];
preds(1).b = 30;

    % Lung Volume must be greater than 0 L
preds(2).str = 'vol1';
preds(2).A = [0 -1];
preds(2).b = 0;

    % Lung Volume must be lower than 6 L
preds(3).str = 'vol2';
preds(3).A = [0 1];
preds(3).b = 6;

% Define options
athena_opt = athena_options;
athena_opt.black_box = 1;
athena_opt.SampTime=0.01;
athena_opt.interpolationtype={'pconst','const','const'};
athena_opt.optim_params.n_tests = 300;
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'mv1')
    athena_opt.fitnessFcn = 'customMV1';
end

% Define other parameters
sim_time = 30;
cp_array = [2, 1, 1];
input_range = [0 0.05; 35 39; 18 25];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Muscle~pressure~[bar]$', '$Room~Temp~[^{\circ}C]$', '$Body~Temp~[^{\circ}C]$'};
Athena_param.OutRange = [-50, 35; -0.5, 6.5];
Athena_param.OutName = {'$Lung~pressure~[cmH_{2}O]$', '$Lung~volume~[L]$'};

