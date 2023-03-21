clearvars
clearvars -global
close all
clc

addpath(genpath('Athena'))
rmpath(genpath('Athena/staliro/benchmarks'))
rmpath(genpath('Athena/staliro/demos'))

%% Define parameters for run of Athena

% Define the RID (Requirement ID).
    % The case (lowercase/uppercase) does not affect the result.
rid = 'wt2';

% Define the number of runs.
n_runs = 1;
if n_runs < 1
    error('The number of runs must be bigger than 1.')
end

% Define the value of the parameter p.
p_param = 0.5;
if p_param < 0 || p_param > 1
    error('The parameter p must be between 0 and 1 (included).')
end

% Define the set of input assumptions.
range = 0;
if range ~= 0 && range ~= 1
    error('The set of input assumptions must be either 0 (for R) or 1 (for R'').')
end

%% Load the correct parameters for Athena

% Start time
tstart = tic;

% Remove from path all the already loaded models
warning off MATLAB:rmpath:DirNotFound
rmpath(genpath('Models'));
warning on MATLAB:rmpath:DirNotFound

% Access the Athena parameter
global Athena_param;

% Read model setting file and choose the input range
if contains(rid,'afc','IgnoreCase',true)        % AFC benchmark
    addpath(genpath('Models/AFC'))
    SettingAFC;
    if strcmpi(rid,'afc33')
        input_range = [900  1100; 61.2 81.2];
        Athena_param.output_data.range = [-0.04, 0.04; 0, 1; 61.2 81.2];
    end

elseif contains(rid,'at','IgnoreCase',true)     % AT benchmark
    addpath(genpath('Models/AT'));
    if contains(rid,'at5','IgnoreCase',true)
        SettingAT5;
    else
        SettingAT;
    end
    
    if strcmpi(rid,'at1') && range == 1
        input_range = [0, 110; 0, 100];
    elseif strcmpi(rid,'at2') && range == 1
        input_range = [0, 90; 32, 325];
    elseif strcmpi(rid,'at6a') && range == 1
        input_range = [0, 47; 172, 325];
    elseif strcmpi(rid,'at6b') && range == 1
        input_range = [0, 48; 169, 325];
    elseif strcmpi(rid,'at6c') && range == 1
        input_range = [0, 44; 182, 325];
    elseif strcmpi(rid,'at6abc') && range == 1
        input_range = [0, 44; 182, 325];
    end

elseif contains(rid,'cc','IgnoreCase',true)     % CC benchmark
    addpath(genpath('Models/CC'));
    SettingCC;
    if strcmpi(rid,'cc1') && range == 1
        input_range = [0, 0.82; 0.18, 1];
    end

elseif contains(rid,'f16','IgnoreCase',true)    % F16 benchmark
    addpath(genpath('Models/F16'));
    rmpath(genpath('Models/F16/F16_model'))
    SettingF16;
    if strcmpi(rid,'f16') && range == 1
        init_cond = [pi/4+[-pi/5 pi/30]; -(pi/2)*0.8+[0 pi/5]; -pi/4+[-pi/3 pi/8]];
        Athena_param.output_data.range(3:4,:) = init_cond(1:2,:);
    end

elseif contains(rid,'hev','IgnoreCase',true)    % HEV benchmark
    addpath(genpath('Models/HEV'));
    SettingHEV;

elseif contains(rid,'mv','IgnoreCase',true)     % MV benchmark
    addpath(genpath('Models/MV'));
    SettingMV;

elseif contains(rid,'nn','IgnoreCase',true)     % NN benchmark
    addpath(genpath('Models/NN'));
    SettingNN;
    if strcmpi(rid,'nn') && range == 1
        input_range = [1 2];
    elseif strcmpi(rid,'nnx')
        if range == 0
            input_range = [1.95 2.05];
        elseif range == 1
            input_range = [1.95 2.14];
        end
    end

elseif contains(rid,'sc','IgnoreCase',true)     % SC benchmark
    addpath(genpath('Models/SC'));
    SettingSC;
    if strcmpi(rid,'sc') && range == 1
        input_range = [3.984 ,4.016];
    end

elseif contains(rid,'wt','IgnoreCase',true)     % WT benchmark
    addpath(genpath('Models/WT'));
    SettingWT;
    if strcmpi(rid,'wt1') && range == 1
        input_range = [7.5 16.5];
    end

else
    error('The requirement does not match any of the available models.')
end

% Update the input ranges
if ~strcmpi(rid,'f16')
    Athena_param.input_data.range = input_range;
else
    Athena_param.input_data.range = init_cond;
end

% Choose the appropriate requirement and fitness function
try
    phi = eval(lower(rid));
catch
    error('The requirement does not match any of the available ones for the selected model.')
end

%% Run the Athena algorithm

% Set the chosen parameters
athena_opt.athena_runs = n_runs;
athena_opt.coeffRob = p_param;

% Save file name
saveStr = "Results/Athena_"+upper(rid)+"_range"+string(range)+"_p"+...
    string(p_param)+"_"+string(datetime("today"))+".mat";

% Set other parameters (look at 'athena_options' for more information).
athena_opt.IntermediateSave = true;
athena_opt.SaveFile = saveStr;
athena_opt.dispinfo = -1;

% Run Athena algorithm
[Results, History, Opt] = athena(model, init_cond, input_range, cp_array, phi, preds, sim_time, athena_opt);

%% Extract and evaluate quality parameters from runs

% Extract relevant information for each run
fals = false(n_runs,1);
n_iter = zeros(size(fals));
best_Rob = zeros(size(fals));

for ii = 1:n_runs

    % Number of runs
    n_iter(ii) = Results{ii}.run.nTests;

    % Lowest robustness
    best_Rob(ii) = double(Results{ii}.run.bestRob);

    % Falsified or not
    fals(ii) = (best_Rob(ii) <= 0);

end

% Compute quality parameters
SuccRate = sum(fals)/length(fals);

% Average and median number of runs (only for runs that were falsified)
Avg_iter = round(mean(n_iter(fals)));
Med_iter = round(median(n_iter(fals)));

% Average and median minimum robustness (only for runs that were not
% falsified)
Avg_rob = mean(best_Rob(~fals));
Med_rob = median(best_Rob(~fals));

% Print results
fprintf('\n\t\t\t*\t*\t*\n\n')
if isa(model,'function_handle')
    fprintf('Model:\t\t%s\n',func2str(model))
else
    fprintf('Model:\t\t%s\n',model)
end
fprintf('Requirement:\t%s - %s\n\n',upper(rid),phi)

fprintf('\t\t\t%s\n','Athena')
fprintf('Success rate:\t\t%.0f%%\n',SuccRate*100)
fprintf('Average iterations:\t%i\n',Avg_iter)
fprintf('Median iterations:\t%i\n',Med_iter)
fprintf('Average robustness:\t%.3f\n',Avg_rob)
fprintf('Median robustness:\t%.3f\n\n',Med_rob)

%% Save results

timeElaps = toc(tstart);
fprintf('The calculation required %i seconds.\n\n',round(timeElaps))
save(saveStr)
fprintf('\nData saved in %s\n\n',saveStr)