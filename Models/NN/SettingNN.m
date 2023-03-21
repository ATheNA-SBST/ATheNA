% This script is used to define all the variables needed to run the NN
% benchmark on Athena.

% Choose the model
model = 'nn_model';

alpha = 0.005;
assignin('base','alpha',alpha)
beta = 0.03;
assignin('base','beta',beta)
u_ts = 0.01;                   % Electrical current sampling time
assignin('base','u_ts',u_ts)

% Write requirements
nn = '[]_[1,37] (!(nnpred)->(<>_[0,2]([]_[0,1] (nnpred))))';
nnx = '(<>_[0,1] (!(nnxpred1))) /\ (<>_[1,1.5] ([]_[0,0.5] (!(nnxpred2) /\ nnxpred3))) /\ ([]_[2,3] (!(nnxpred4) /\ nnxpred5))';

preds(1).str='nnpred';
preds(1).A = [1 0];
preds(1).b = 0;
preds(1).Normalized = 1;
preds(1).NormBounds = 0.09;

preds(2).str='nnxpred1';
preds(2).A = [0 1];
preds(2).b = 3.2;
preds(2).Normalized = 1;
preds(2).NormBounds = 0.2;

preds(3).str='nnxpred2';
preds(3).A = [0 1];
preds(3).b = 1.75;
preds(3).Normalized = 1;
preds(3).NormBounds = 0.2;

preds(4).str='nnxpred3';
preds(4).A = [0 1];
preds(4).b = 2.25;
preds(4).Normalized = 1;
preds(4).NormBounds = 0.2;

preds(5).str='nnxpred4';
preds(5).A = [0 1];
preds(5).b = 1.825;
preds(5).Normalized = 1;
preds(5).NormBounds = 0.2;

preds(6).str='nnxpred5';
preds(6).A = [0 1];
preds(6).b = 2.175;
preds(6).Normalized = 1;
preds(6).NormBounds = 0.2;

% Define options
athena_opt = athena_options;
athena_opt.SampTime=0.01;
athena_opt.interpolationtype={'pchip'};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'nn')
    athena_opt.fitnessFcn = 'customNN';
elseif strcmpi(rid,'nnx')
    athena_opt.fitnessFcn = 'customNNX';
else
    error('The model NN does not contain the requirement %s.',rid);
end

% Define other parameters
sim_time = 40;
cp_array = 3;
input_range = [1 3];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Reference~position$'};
Athena_param.OutRange = [-0.5, 2.5; 0, 5];
Athena_param.OutName = {'$Error^{*}$','$Position$'};

