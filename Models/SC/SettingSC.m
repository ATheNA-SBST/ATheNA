% This script is used to define all the variables needed to run the SC
% benchmark on Athena.

% Choose the model
model = 'stc';

% Write requirements
sc = '[]_[30,35] (p1/\p2)';

preds(1).str = 'p1';
preds(1).A =  [0 0 0 1];
preds(1).b =  87.5;
preds(1).Normalized = 1;
preds(1).NormBounds = 0.5;

preds(2).str = 'p2';
preds(2).A =  [0 0 0 -1];
preds(2).b =  -87;
preds(2).Normalized = 1;
preds(2).NormBounds = 0.5;

% Define options
athena_opt = athena_options;
athena_opt.SampTime=0.01;
athena_opt.interpolationtype={'pchip'};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'sc')
    athena_opt.fitnessFcn = 'customSC';
else
    error('The model SC does not contain the requirement %s.',rid);
end

% Define other parameters
sim_time = 35;
cp_array = 20;
input_range = [3.99 ,4.01];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Steam~flow~rate$'};
Athena_param.OutRange = [75, 95; 8500, 10000; 100, 130; 80, 90];
Athena_param.OutName = {'$Temperature$', {'$Cooling~water$','$flow~rate$'}, '$Heat~dissipated$', '$Steam~pressure$'};


