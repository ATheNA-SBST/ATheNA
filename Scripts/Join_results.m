%% Join the results in a single .mat file
clearvars
close all
clc

% Set up staliro
CurDir = cd;
cd staliro;
setup_staliro('skip_mex');
cd(CurDir);

%% Load file

FileStr = {'STaliro_WT1_orig_04-May-2022.mat';
    'AthenaM_WT1_orig_04-May-2022.mat';
    'Athena_WT1_orig_04-May-2022.mat'};

load(['Results/',FileStr{1}])

A = load(['Results/',FileStr{1}],'Results','History','Opt','Avg_iter','Avg_rob','Med_iter','Med_rob','SuccRate','n_iter','bestRob','fals','timeElaps');
B = load(['Results/',FileStr{2}],'Results','History','Opt','Avg_iter','Avg_rob','Med_iter','Med_rob','SuccRate','n_iter','bestRob','fals','timeElaps');
C = load(['Results/',FileStr{3}],'Results','History','Opt','Avg_iter','Avg_rob','Med_iter','Med_rob','SuccRate','n_iter','bestRob','fals','timeElaps');

%% Join variables

Results = [A.Results; B. Results; C.Results];
History = [A.History; B. History; C.History];
Opt = [A.Opt; B. Opt; C.Opt];

Avg_iter = [A.Avg_iter, B.Avg_iter, C.Avg_iter];
Med_iter = [A.Med_iter, B.Med_iter, C.Med_iter];
Avg_rob = [A.Avg_rob, B.Avg_rob, C.Avg_rob];
Med_rob = [A.Med_rob, B.Med_rob, C.Med_rob];
SuccRate = [A.SuccRate, B.SuccRate, C.SuccRate];

fals = [A.fals, B.fals, C.fals];
n_iter = [A.n_iter, B.n_iter, C.n_iter];
bestRob = [A.bestRob, B.bestRob, C.bestRob];

timeElaps = A.timeElaps+B.timeElaps+C.timeElaps;

%% Save results

idx = strfind(FileStr{1},'_');
FileStr = ['AthenaFull', FileStr{1}(idx:end)];
clearvars idx A B C
save(['Results/',FileStr])