% This script is used to define all the variables needed to run the F16
% benchmark on Athena.

% Data for system simulation
global analysisOn,
global printOn, 
global plotOn,
global model_err 
global InitAlt
global initialState
global x_f16_0
global sys

% Data for system simulation
InitAlt = 2338; 
model_err = false;
analysisOn = false;
printOn = false;
plotOn = false;
backCalculateBestSamp = false;

% Write requirements
f16 = '[]_[0, 15] (!(p1))';

preds(1).str = 'p1';
preds(1).A =  1;
preds(1).b =  0;
preds(1).proj = 1;
preds(1).Normalized = 1;
preds(1).NormBounds = 2400;

% Run configuration script
cd('Models/F16/AeroBenchVV-develop/src/main'); % Is it necessary? SimConfig is in AeroBenchVV-develop/src/main/Simulink
evalin('base','SimConfig;');
cd('../../../../..');

initialState(12) = InitAlt;     % Inital Altitude of the System set appropriately
x_f16_0(12) = InitAlt;          % Inital Altitude of the System set appropriately
assignin('base','x_f16_0',x_f16_0)

sys = 'AeroBenchSim';
load_system(sys)

% Choose the model
model = @blackboxF16;

% Define options
athena_opt = athena_options;
athena_opt.SampTime = 0.01;
athena_opt.interpolationtype = {};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.black_box = 1;
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'f16')
    athena_opt.fitnessFcn = 'customF16';
else
    error('The model F16 does not contain the requirement %s.',rid);
end

% Define other parameters
cp_array = [];
input_range = [];
init_cond = [pi/4+[-pi/20 pi/30]; -(pi/2)*0.8+[0 pi/20]; -pi/4+[-pi/8 pi/8]];
sim_time = 15;
assignin('base','t_end',sim_time)

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = init_cond;
Athena_param.InName = {'$Initial~condition~1$','$Initial~condition~2$','$Initial~condition~3$'};
Athena_param.OutRange = [0, 2300; 0, 2; init_cond(1,:); init_cond(2,:)];
Athena_param.OutName = {'$Altitude$', '$GCAS$', '$Roll$', '$Pitch$'};

