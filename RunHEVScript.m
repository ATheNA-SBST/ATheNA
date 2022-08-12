% This function runs a complete test (only robustness, only fitness and
% mixed) for the given requirement and saves the results.

% Input:
    % requirement: string variable containing the name of the benchmark and
    % the requirement to be falsified.
    % e.g.: requirement = 'AT6a'

%% Preliminary operations

close all
clc
clearvars

% Add to current path staliro and all the subfolders.
addpath(genpath('staliro'))
rmpath(genpath('staliro/benchmarks'))
rmpath(genpath('staliro/demos'))

addpath(genpath('fitness'))

% Set up staliro
CurDir = cd;
cd staliro;
setup_staliro('skip_mex');
cd(CurDir);

% Call global variables
global staliro_SimulationTime;
global staliro_InputBounds;
global staliro_opt;

% Write the fitness parameters
global BEE_param;

%% Load the correct settings

addpath(genpath('HEV_SeriesParallel'));

phi = '[]_[0,400] (deltaspeed)';

preds(1).str='deltaspeed';
preds(1).A = 1;
preds(1).b = 3; 

Configure_HEV_Simulation;
Setup_HEV_Model_Configurations;
HEV_Model_PARAM;
expModel = 'HEV_SeriesParallel';
open_system(expModel);

ModelVariants = {'System Level' 'Mean Value' 'Detailed'};
BattVariants = {'Predefined' 'Generic'  'Cells'};
VehVariants = {'Simple' 'Full'};

SimDuration = 400;
staliro_SimulationTime=SimDuration;
MV_testInd = 1;
Batt_testInd = 1;
Veh_testInd = 1;

set_param([expModel '/Vehicle Dynamics'],'OverrideUsingVariant',VehVariants{Veh_testInd});
set_param([expModel '/Electrical'],'popup_electricalvariant',ModelVariants{MV_testInd});
set_param([expModel '/Electrical'],'popup_batteryvariantsystem',BattVariants{Batt_testInd});

requirement = 'HEV';
input_range=[0,4];
input_data.range=input_range;

input_data.name='speeddemand';
output_data.range=[0,10];
output_data.name='actualspeed';
model='HEV_SeriesParallel';
init_cond = [];
cp_array = 5;

Drive_Cycle_Num=1;
load('UrbanCycle1.mat')
load('UrbanCycle2.mat')
load('UrbanCycle3.mat')
load('UrbanCycle4.mat')
load('UrbanCycle5.mat')

staliro_opt = staliro_options;
%staliro_opt.interpolationtype={'linear'};

staliro_opt.interpolationtype={'pchip'};
%staliro_opt.interpolationtype={'pconst'};
%staliro_opt.ode_solver='ode45';


BEE_param.fitnessFcn = ['custom',upper(requirement)];

% Write the global variables
BEE_param.InRange = input_data.range;
BEE_param.InStr = input_data.name;
BEE_param.OutRange = output_data.range;
BEE_param.OutStr = output_data.name;
BEE_param.Nfig = 0;

%% Run BEE algorithm

n_runs = 1;

ii=1;
alphaStr = '\alpha~=~0';

    % Setup plot
    if BEE_param.Nfig > 0
        % Input
        figure(BEE_param.Nfig)
        clf
        for jj = 1:length(cp_array)
            subplot(length(cp_array),1,jj)
            xlabel('$Time~[s]$','Interpreter','latex','FontSize',16)
            ylabel(BEE_param.InStr{jj},'Interpreter','latex','FontSize',16)
            ylim(input_data.range(jj,:))
        end
        TitleStr = sprintf('$Input~-~Run~%i/%i~-~%s~-~%s$',ii,3*n_runs,alphaStr,upper(requirement));
        sgtitle(TitleStr,'Interpreter','latex','FontSize',20)

        % Output
        figure(BEE_param.Nfig+1)
        clf
        for jj = 1:length(output_data.name)
            subplot(length(output_data.name),1,jj)
            xlabel('$Time~[s]$','Interpreter','latex','FontSize',16)
            ylabel(BEE_param.OutStr{jj},'Interpreter','latex','FontSize',16)
            ylim(output_data.range(jj,:))
        end
        TitleStr = sprintf('$Output~-~Run~%i/%i~-~%s~-~%s$',ii,3*n_runs,alphaStr,upper(requirement));
        sgtitle(TitleStr,'Interpreter','latex','FontSize',20)
    end

       
staliro_opt.runs=1;
staliro_opt.SampTime=0.5;
staliro_opt.optim_params.n_tests=300;

global iternum;


iternum=0;
tfalsif=tic;
canaloptimized=1;
BEE_param.coeffRob = 0.5;
alphaStr = 'ATheNAS';
[resultsathens, historyresultsathens, optresultsathens] = staliro(model, init_cond, input_range, cp_array, phi, preds, staliro_SimulationTime, staliro_opt);
experimenttime=tfalsif
save('HEVATheNAS')

