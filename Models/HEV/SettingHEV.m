% This script is used to define all the variables needed to run the HEV
% benchmark on Athena.
warning off codertarget:build:SupportPackageNotInstalled

% Call the global variables
global projID;

% Open project
projID = openProject('Models/HEV/HEV_SeriesParallel.prj');
cd('../..')

% Choose the model
model = 'HEV_SeriesParallel';

% Load Driving cycle in main workspace
assignin('base','Drive_Cycle_Num',1);
evalin('base','load("UrbanCycle1.mat")');
evalin('base','load("UrbanCycle2.mat")');
evalin('base','load("UrbanCycle3.mat")');
evalin('base','load("UrbanCycle4.mat")');
evalin('base','load("UrbanCycle5.mat")');

% Set model parameters in main workspace
ModelVariants = {'System Level', 'Mean Value', 'Detailed'};
BattVariants = {'Predefined', 'Generic',  'Cells'};
VehVariants = {'Simple', 'Full'};

MV_testInd = 1;
Batt_testInd = 1;
Veh_testInd = 1;

set_param([model '/Vehicle Dynamics'],'OverrideUsingVariant',VehVariants{Veh_testInd});
set_param([model '/Electrical'],'popup_electricalvariant',ModelVariants{MV_testInd});
set_param([model '/Electrical'],'popup_batteryvariantsystem',BattVariants{Batt_testInd});

% Write requirements in STL
hev = '[]_[0,400] (deltaspeed)';

    % Speed difference must be below 3 kph
preds(1).str='deltaspeed';
preds(1).A = 1;
preds(1).b = 3; 
preds(1).Normalize = 1;
preds(1).NormBounds = 3;

% Define options
athena_opt = athena_options;
athena_opt.SampTime=0.5;
athena_opt.interpolationtype={'pchip'};
athena_opt.optim_params.n_tests = 300;
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'hev')
    athena_opt.fitnessFcn = 'customHEV';
end

% Define other parameters
sim_time = 400;
cp_array = 5;
input_range = [0 4];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Speed~demand~[kph]$'};
Athena_param.OutRange = [0, 4];
Athena_param.OutName = {'$Speed~error~[kph]$'};

