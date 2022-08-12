% This script is used to define all the variables needed to run the NN
% benchmark on Athena

% Call the global variables
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_dimY;
global staliro_opt;

% Choose the model
model = 'nn';

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
staliro_opt = staliro_options;
staliro_opt.SampTime=0.01;
staliro_opt.interpolationtype={'pchip'};
staliro_opt.optim_params.n_tests = 300;

% Define other parameters
staliro_SimulationTime = 40;
cp_array = 3;
temp_ControlPoints = cp_array;
staliro_InputBounds = [1 3];
init_cond = [];
staliro_dimX = 0;
staliro_dimY = 2;
input_data.range = staliro_InputBounds;
input_data.name = {'$Reference~position$'};
output_data.range = [-0.5, 2.5; 0, 5];
output_data.name = {'$Error^{*}$','$Position$'};
