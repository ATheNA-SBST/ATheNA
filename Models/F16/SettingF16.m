% This script is used to define all the variables needed to run the F16
% benchmark on Athena

% Data for system simulation
global analysisOn,
global printOn, 
global plotOn,
global model_err 
global InitAlt
global initialState
global x_f16_0
global sys

% Call the global variables for S-Taliro
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_dimY;
global staliro_opt;

InitAlt = 2338; 
model_err = false;
analysisOn = false;
printOn = false;
plotOn = false;
backCalculateBestSamp = false;

staliro_SimulationTime = 15;
assignin('base','t_end',staliro_SimulationTime)

% Write requirements
f16 = '[]_[0, 15] (!(p1))';

preds(1).str = 'p1';
preds(1).A =  1;
preds(1).b =  0;
preds(1).proj = 1;
preds(1).Normalized = 1;
preds(1).NormBounds = 2400;

% Run configuration script
cd('F16/AeroBenchVV-develop/src/main'); % Is it necessary? SimConfig is in AeroBenchVV-develop/src/main/Simulink
SimConfig;
cd('../../../..');

initialState(12) = InitAlt;     % Inital Altitude of the System set appropriately
x_f16_0(12) = InitAlt;          % Inital Altitude of the System set appropriately
assignin('base','x_f16_0',x_f16_0)

sys = 'AeroBenchSim';
load_system(sys)

% Choose the model
model = @blackboxF16;

% Define options
staliro_opt = staliro_options;
staliro_opt.SampTime = 0.01;
staliro_opt.interpolationtype = {};
staliro_opt.optim_params.n_tests = 300;
staliro_opt.black_box = 1;

% Define other parameters
cp_array = [];
temp_ControlPoints = cp_array;
staliro_InputBounds = [];
init_cond = [pi/4+[-pi/20 pi/30]; -(pi/2)*0.8+[0 pi/20]; -pi/4+[-pi/8 pi/8]];
staliro_dimX = 0;
staliro_dimY = 0;

input_data.range = init_cond;
input_data.name = {'$Initial~condition~1$','$Initial~condition~2$','$Initial~condition~3$'};
output_data.range = [0, 2300; 0, 2; init_cond(1,:); init_cond(2,:)];
output_data.name = {'$Altitude$', '$GCAS$', '$Roll$', '$Pitch$'};