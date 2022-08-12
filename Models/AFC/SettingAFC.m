% This script is used to define all the variables needed to run the AFC
% benchmark on Athena

% Call the global variables
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_dimY;
global staliro_opt;

% Choose the model
model = 'AbstractFuelControl_M1';

% Requirements parameters
beta = 0.008;
gamma = 0.007;

% Write requirements
afc27 = '[]_[11,50](((low /\ <>_[0,0.05] high) \/ (high /\ <>_[0,0.05] low)) -> ([]_[1,5](ubr /\ ubl)))';
% afc27 = '[]_[11,50](!(low /\ <>_[0,0.05] high))';
afc29 = '[]_[11,50](ugr /\ ugl)';
afc33 = '[]_[11,50](ugr /\ ugl)';

preds(1).str = 'low';   % for the pedal input signal
preds(1).A = [0 0 1];
preds(1).b = 8.8;
preds(1).Normalized = 1;
preds(1).NormBounds = 55;

preds(2).str = 'high';  % for the pedal input signal
preds(2).A = [0 0 -1];
preds(2).b = -40;
preds(2).Normalized = 1;
preds(2).NormBounds = 40;

preds(3).str = 'norm';  % mode < 0.5 (normal mode = 0)
preds(3).A = [0 1 0];
preds(3).b = 0.5;
preds(3).Normalized = 1;
preds(3).NormBounds = 0.5;

preds(4).str = 'pwr';   % mode > 0.5 (power mode = 1)
preds(4).A = [0 -1 0];
preds(4).b = -0.5;
preds(4).Normalized = 1;
preds(4).NormBounds = 0.5;

preds(5).str = 'ubr';   % u <= beta
preds(5).A = [1 0 0];
preds(5).b = beta;
preds(5).Normalized = 1;
preds(5).NormBounds = 0.025;

preds(6).str = 'ubl';   % u >= -beta
preds(6).A = [-1 0 0];
preds(6).b = beta;
preds(6).Normalized = 1;
preds(6).NormBounds = 0.025;

preds(7).str = 'ugr';   % u <= gamma
preds(7).A = [1 0 0];
preds(7).b = gamma;
preds(7).Normalized = 1;
preds(7).NormBounds = 0.025;

preds(8).str = 'ugl';   % u >= -gamma
preds(8).A = [-1 0 0];
preds(8).b = gamma;
preds(8).Normalized = 1;
preds(8).NormBounds = 0.025;

% Define options
staliro_opt = staliro_options;
staliro_opt.interpolationtype={'const','pconst'};
staliro_opt.optim_params.n_tests = 300;
staliro_opt.SampTime = 0.01;

% Define other parameters
simTime = 50;
staliro_SimulationTime = simTime;
cp_array = [1, 10];
temp_ControlPoints = cp_array;
staliro_InputBounds = [900  1100; 0 61.2];
init_cond = [];
staliro_dimX = 0;
staliro_dimY = 3;

input_data.range = staliro_InputBounds;
input_data.name = {'$Engine~speed~[rpm]$', '$Throttle~angle~[deg]$'};
output_data.range = [-0.04, 0.04; 0, 1; 0, 61.2];
output_data.name = {'$Verification~[/]$', '$Mode~[/]$', '$Throttle~angle~[deg]$'};

% Define variables for the model
assignin('base','simTime',simTime)
assignin('base','en_speed',1000)
assignin('base','measureTime',1)
assignin('base','spec_num',1)
assignin('base','fuel_inj_tol',1)
assignin('base','MAF_sensor_tol',1)
assignin('base','AF_sensor_tol',1)
assignin('base','sim_time',50)
assignin('base','fault_time',60)
