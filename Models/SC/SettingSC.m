% This script is used to define all the variables needed to run the SC
% benchmark on Athena

% Call the global variables
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_dimY;
global staliro_opt;

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
preds(1).Normalized = 1;
preds(1).NormBounds = 0.5;

% Define options
staliro_opt = staliro_options;
staliro_opt.SampTime=0.01;
staliro_opt.interpolationtype={'pchip'};
staliro_opt.optim_params.n_tests = 300;

% Define other parameters
staliro_SimulationTime = 35;
cp_array = 20;
temp_ControlPoints = cp_array;
staliro_InputBounds = [3.99 ,4.01];
init_cond = [];
staliro_dimX = 0;
staliro_dimY = 4;

input_data.range = staliro_InputBounds;
input_data.name = {'$Steam~flow~rate$'};
output_data.range = [85, 95; 8500, 10000; 100, 130; 80, 90];
output_data.name = {'$Temperature$', {'$Cooling~water$','$flow~rate$'}, '$Heat~dissipated$', '$Steam~pressure$'};