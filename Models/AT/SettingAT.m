% This script is used to define all the variables needed to run the AT
% benchmark on Athena

% Call the global variables
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_dimY;
global staliro_opt;

% Choose the model
model = 'Autotrans_shift';

% Write requirements
at1 = '[]_[0,20] speed120';
at2 = '[]_[0,10] rpm4750';
at51 = '[]_[0, 30] ((!(gearleq1 /\ geargeq1) /\ <>_[0.001,0.1] (gearleq1 /\ geargeq1))-> <>_[0.001,0.1] []_[0.0,2.5] (gearleq1 /\ geargeq1))';
at52 = '[]_[0, 30] ((!(gearleq2 /\ geargeq2) /\ <>_[0.001,0.1] (gearleq2 /\ geargeq2))-> <>_[0.001,0.1] []_[0.0,2.5] (gearleq2 /\ geargeq2))';
at53 = '[]_[0, 30] ((!(gearleq3 /\ geargeq3) /\ <>_[0.001,0.1] (gearleq3 /\ geargeq3))-> <>_[0.001,0.1] []_[0.0,2.5] (gearleq3 /\ geargeq3))';
at54 = '[]_[0, 30] ((!(gearleq4 /\ geargeq4) /\ <>_[0.001,0.1] (gearleq4 /\ geargeq4))-> <>_[0.001,0.1] []_[0.0,2.5] (gearleq4 /\ geargeq4))';
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

preds(3).str='gearleq1';
preds(3).A = [0 0 1];
preds(3).b = 1;
preds(3).Normalized = 1;
preds(3).NormBounds = 3;

preds(4).str='geargeq1';
preds(4).A = [0 0 -1];
preds(4).b = -1;
preds(4).Normalized = 1;
preds(4).NormBounds = 3;

preds(5).str='gearleq2';
preds(5).A = [0 0 1];
preds(5).b = 2;
preds(5).Normalized = 1;
preds(5).NormBounds = 2;

preds(6).str='geargeq2';
preds(6).A = [0 0 -1];
preds(6).b = -2;
preds(6).Normalized = 1;
preds(6).NormBounds = 2;

preds(7).str='gearleq3';
preds(7).A = [0 0 1];
preds(7).b = 3;
preds(7).Normalized = 1;
preds(7).NormBounds = 2;

preds(8).str='geargeq3';
preds(8).A = [0 0 -1];
preds(8).b = -3;
preds(8).Normalized = 1;
preds(8).NormBounds = 2;

preds(9).str='gearleq4';
preds(9).A = [0 0 1];
preds(9).b = 4;
preds(9).Normalized = 1;
preds(9).NormBounds = 3;

preds(10).str='geargeq4';
preds(10).A = [0 0 -1];
preds(10).b = -4;
preds(10).Normalized = 1;
preds(10).NormBounds = 3;

preds(11).str='speed35';
preds(11).A = [1 0 0];
preds(11).b = 35;
preds(11).Normalized = 1;
preds(11).NormBounds = 35;

preds(12).str='speed50';
preds(12).A = [1 0 0];
preds(12).b = 50;
preds(12).Normalized = 1;
preds(12).NormBounds = 50;

preds(13).str='speed65';
preds(13).A = [1 0 0];
preds(13).b = 65;
preds(13).Normalized = 1;
preds(13).NormBounds = 65;

preds(14).str='rpmlt3000';
preds(14).A = [0 1 0];
preds(14).b = 3000;
preds(14).Normalized = 1;
preds(14).NormBounds = 2500;

% Define options
staliro_opt = staliro_options;
staliro_opt.SampTime=0.01;
staliro_opt.interpolationtype={'pconst','pconst'};
staliro_opt.optim_params.n_tests = 300;

% Define other parameters
staliro_SimulationTime = 50;
cp_array = [7, 3];
temp_ControlPoints = cp_array;
staliro_InputBounds = [0 100; 0 325];
init_cond = [];
staliro_dimX = 0;
staliro_dimY = 3;

input_data.range = staliro_InputBounds;
input_data.name = {'$Throttle~[\%]$', '$Brake~[lb-ft]$'};
output_data.range = [0, 150; 0, 5000; 1, 4];
output_data.name = {'$Speed~[mph]$', '$RPM~[rpm]$', '$Gear~[/]$'};