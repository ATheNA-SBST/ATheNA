% This script is used to define all the variables needed to run the CC
% benchmark on Athena

% Call the global variables
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_dimY;
global staliro_opt;

% Choose the model
model = 'carsmodel';

% Write requirements
cc1 = '[]_[0,100] (cc1pred)';
cc2 = '[]_[0,70] (<>_[0,30] (cc2pred))';
cc3 = '[]_[0,80] (([]_[0,20] (cc3pred1))  \/ (<>_[0,20] (cc3pred2)))';
cc4 = '[]_[0,65] (<>_[0,30] ([]_[0,5] (cc4pred)))';
cc5 = '[]_[0,72] (<>_[0,8] (([]_[0,5] (cc5pred1)) -> ([]_(5,20) (cc5pred2))))';
ccx = '([]_[0,50] (ccxpred1)) /\ ([]_[0,50] (ccxpred2)) /\ ([]_[0,50] (ccxpred3)) /\ ([]_[0,50] (ccxpred4))';  

% Write atomic predicates
preds(1).str='cc1pred';
preds(1).A = [0 0 0 -1 1];
preds(1).b = 40;
preds(1).Normalized = 1;
preds(1).NormBounds = 30;

preds(2).str='cc2pred';
preds(2).A = [0 0 0 1 -1];
preds(2).b = -15;
preds(2).Normalized = 1;
preds(2).NormBounds = 25;

preds(3).str='cc3pred1';
preds(3).A = [-1 1 0 0 0];
preds(3).b = 20;
preds(3).Normalized = 1;
preds(3).NormBounds = 20;

preds(4).str='cc3pred2';
preds(4).A = [0 0 0 1 -1];
preds(4).b = -40;
preds(4).Normalized = 1;
preds(4).NormBounds = 30;

preds(5).str='cc4pred';
preds(5).A = [0 0 0 1 -1];
preds(5).b = -8;
preds(5).Normalized = 1;
preds(5).NormBounds = 1.5;

preds(6).str='cc5pred1';
preds(6).A = [1 -1 0 0 0];
preds(6).b = -9;
preds(6).Normalized = 1;
preds(6).NormBounds = 15;

preds(7).str='cc5pred2';
preds(7).A = [0 0 0 1 -1];
preds(7).b = -9;
preds(7).Normalized = 1;
preds(7).NormBounds = 40;

preds(8).str='ccxpred1';
preds(8).A = [1 -1 0 0 0];
preds(8).b = -7.5;
preds(8).Normalized = 1;
preds(8).NormBounds = 2.5;

preds(9).str='ccxpred2';
preds(9).A = [0 1 -1 0 0];
preds(9).b = -7.5;
preds(9).Normalized = 1;
preds(9).NormBounds = 2.5;

preds(10).str='ccxpred3';
preds(10).A = [0 0 1 -1 0];
preds(10).b = -7.5;
preds(10).Normalized = 1;
preds(10).NormBounds = 2.5;

preds(11).str='ccxpred4';
preds(11).A = [0 0 0 1 -1];
preds(11).b = -7.5;
preds(11).Normalized = 1;
preds(11).NormBounds = 2.5;

% Define options
staliro_opt = staliro_options;
staliro_opt.interpolationtype={'pchip','pchip'};
staliro_opt.optim_params.n_tests = 300;
staliro_opt.SampTime = 0.01;

% Define other parameters
staliro_SimulationTime = 100;
cp_array = [7, 3];
temp_ControlPoints = cp_array;
staliro_InputBounds = [0 1; 0 1];
init_cond = [];
staliro_dimX = 0;
staliro_dimY = 5;

input_data.range = staliro_InputBounds;
input_data.name = {'$Throttle$', '$Brake$'};
output_data.range = [-2000, 100; -2000, 100; -2000, 100; -2000, 100; -2000, 100];
output_data.name = {'$Position~car~1$', '$Position~car~2$', '$Position~car~3$', '$Position~car~4$', '$Position~car~5$'};