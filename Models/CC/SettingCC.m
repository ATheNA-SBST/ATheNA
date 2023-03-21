% This script is used to define all the variables needed to run the CC
% benchmark on Athena.

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
athena_opt = athena_options;
athena_opt.interpolationtype={'pchip','pchip'};
athena_opt.optim_params.n_tests = 300;    % Maximum iterations of staliro
athena_opt.SampTime = 0.01;
athena_opt.Nfig = -1;
athena_opt.useInterpInput = false;          % Compute manual fitness function with control points
athena_opt.RunSummary = true;

% Define robustness coefficient and manual fitness function
if strcmpi(rid,'cc1')
    athena_opt.fitnessFcn = 'customCC1';
elseif strcmpi(rid,'cc2')
    athena_opt.fitnessFcn = 'customCC2';
elseif strcmpi(rid,'cc3')
    athena_opt.fitnessFcn = 'customCC3';
elseif strcmpi(rid,'cc4')
    athena_opt.fitnessFcn = 'customCC4';
elseif strcmpi(rid,'cc5')
    athena_opt.fitnessFcn = 'customCC5';
elseif strcmpi(rid,'ccx')
    athena_opt.fitnessFcn = 'customCCX';
else
    error('The model CC does not contain the requirement %s.',rid);
end

% Define other parameters
sim_time = 100;
cp_array = [7, 3];
input_range = [0 1; 0 1];
init_cond = [];

% Define input and ouput ranges
global Athena_param;
Athena_param.InRange = input_range;
Athena_param.InName = {'$Throttle$', '$Brake$'};
Athena_param.OutRange = [-2000, 100; -2000, 100; -2000, 100; -2000, 100; -2000, 100];
Athena_param.OutName = {'$Position~car~1$', '$Position~car~2$', '$Position~car~3$', '$Position~car~4$', '$Position~car~5$'};

