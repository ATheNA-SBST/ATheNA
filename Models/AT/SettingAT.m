% This script is used to define all the variables needed to run the AT
% benchmark on Athena.

% Choose the model
model = 'Autotrans_shift';

% Write requirements
at1 = '[]_[0,20] speed120';
at2 = '[]_[0,10] rpm4750';
at6a = '([]_[0.0, 30.0] rpmlt3000) -> ([]_[0.0, 4.0] speed35)';
at6b = '([]_[0.0, 30.0] rpmlt3000) -> ([]_[0.0, 8.0] speed50)';
at6c = '([]_[0.0, 30.0] rpmlt3000) -> ([]_[0.0, 20.0] speed65)';
at6abc = [at6a,'/\',at6b,'/\',at6c];

preds(1).str='speed120';
preds(1).A = [1 0 0];
preds(1).b = 120;
preds(1).Normalized = 1;
preds(1).NormBounds = 120;

preds(2).str='rpm4750';
preds(2).A = [0 1 0];
preds(2).b = 4750;
preds(2).Normalized = 1;
preds(2).NormBounds = 4000;

preds(3).str='speed35';
preds(3).A = [1 0 0];
preds(3).b = 35;
preds(3).Normalized = 1;
preds(3).NormBounds = 35;

preds(4).str='speed50';
preds(4).A = [1 0 0];
preds(4).b = 50;
preds(4).Normalized = 1;
preds(4).NormBounds = 50;

preds(5).str='speed65';
preds(5).A = [1 0 0];
preds(5).b = 65;
preds(5).Normalized = 1;
preds(5).NormBounds = 65;

preds(6).str='rpmlt3000';
preds(6).A = [0 1 0];
preds(6).b = 3000;
preds(6).Normalized = 1;
preds(6).NormBounds = 2500;

% Define options
athena_opt = athena_options;
athena_opt.SampTime=0.01;
athena_opt.interpolationtype={'pchip','pchip'};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'at1')
    athena_opt.fitnessFcn = 'customAT1';
elseif strcmpi(rid,'at2')
    athena_opt.fitnessFcn = 'customAT2';
elseif strcmpi(rid,'at6a')
    athena_opt.fitnessFcn = 'customAT6A';
%     athena_opt.useInterpInput = true;
elseif strcmpi(rid,'at6b')
    athena_opt.fitnessFcn = 'customAT6B';
%     athena_opt.useInterpInput = true;
elseif strcmpi(rid,'at6c')
    athena_opt.fitnessFcn = 'customAT6C';
%     athena_opt.useInterpInput = true;
elseif strcmpi(rid,'at6abc')
    athena_opt.fitnessFcn = 'customAT6ABC';
%     athena_opt.useInterpInput = true;
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


