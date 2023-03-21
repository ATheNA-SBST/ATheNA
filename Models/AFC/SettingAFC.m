% This script is used to define all the variables needed to run the AFC
% benchmark on Athena.

warning off Simulink:Logging:CannotLogStatesAsMatrix

% Choose the model
model = 'AbstractFuelControl_M1';

% Requirements parameters
beta = 0.008;
gamma = 0.007;

% Write requirements
afc27 = '[]_[11,50](((low /\ <>_[0,0.05] high) \/ (high /\ <>_[0,0.05] low)) -> ([]_[1,5](ubr /\ ubl)))';
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

preds(3).str = 'ubr';   % u <= beta
preds(3).A = [1 0 0];
preds(3).b = beta;
preds(3).Normalized = 1;
preds(3).NormBounds = 0.025;

preds(4).str = 'ubl';   % u >= -beta
preds(4).A = [-1 0 0];
preds(4).b = beta;
preds(4).Normalized = 1;
preds(4).NormBounds = 0.025;

preds(5).str = 'ugr';   % u <= gamma
preds(5).A = [1 0 0];
preds(5).b = gamma;
preds(5).Normalized = 1;
preds(5).NormBounds = 0.025;

preds(6).str = 'ugl';   % u >= -gamma
preds(6).A = [-1 0 0];
preds(6).b = gamma;
preds(6).Normalized = 1;
preds(6).NormBounds = 0.025;

% Define options
athena_opt = athena_options;
athena_opt.interpolationtype={'const','pconst'};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.SampTime = 0.01;
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'afc27')
    athena_opt.fitnessFcn = 'customAFC27';
elseif strcmpi(rid,'afc29')
    athena_opt.fitnessFcn = 'customAFC29';
elseif strcmpi(rid,'afc33')
    athena_opt.fitnessFcn = 'customAFC33';
else
    error('The model AFC does not contain the requirement %s.',rid);
end

% Define other parameters
sim_time = 50;
cp_array = [1, 10];
input_range = [900  1100; 0 61.2];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Engine~speed~[rpm]$', '$Throttle~angle~[deg]$'};
Athena_param.OutRange = [-0.04, 0.04; 0, 1; 0, 61.2];
Athena_param.OutName = {'$Verification~[/]$', '$Mode~[/]$', '$Throttle~angle~[deg]$'};

% Define variables for the model
assignin('base','simTime',sim_time)
assignin('base','en_speed',1000)
assignin('base','measureTime',1)
assignin('base','spec_num',1)
assignin('base','fuel_inj_tol',1)
assignin('base','MAF_sensor_tol',1)
assignin('base','AF_sensor_tol',1)
assignin('base','sim_time',sim_time)
assignin('base','fault_time',60)
