%% This script analyzes all the results obtained and present them separately for each requirement

clearvars
close all
clc
warning off

% Set up staliro
CurDir = cd;
cd staliro;
setup_staliro('skip_mex');
cd(CurDir);

%% 1 - Read results file
% Get file name
FileStr = dir('Results');
FileStr = {FileStr.name};
idx = contains(FileStr,'Athena','IgnoreCase',false);
FileStr = FileStr(idx);

% Declare empty variables
N_run = zeros(1,length(FileStr));
TitleStr = {'S-Taliro','ATheNA-SM','ATheNA'};

for ii = 1:length(FileStr)
    
    Data(ii) = load(['Results/',FileStr{ii}],'Results','History','model','phi','requirement','preds','opt','cp_array','BEE_param','Athena_param','init_cond');

    %% 2 - Split experiments according to the function to be minimized
    
    N_run(ii) = length(Data(ii).Results)/3;     % Number of runs in this experiment
    if N_run(ii) ~= round(N_run(ii))
        warning('The experiments can not be divided in 3 equal batches.')
        return
    end

    Res_STa = Data(ii).Results(1:N_run(ii));
    Res_AThM = Data(ii).Results(N_run(ii)+1:2*N_run(ii));
    Res_ATh = Data(ii).Results(2*N_run(ii)+1:end);

    %% 3 - Extract parameters from runs
    fals = false(N_run(ii),3);
    n_iter = zeros(size(fals));
    best_Rob = zeros(size(fals));

    for jj = 1:N_run(ii)
        % Number of runs
        n_iter(jj,1) = Res_STa{jj}.run.nTests;
        n_iter(jj,2) = Res_AThM{jj}.run.nTests;
        n_iter(jj,3) = Res_ATh{jj}.run.nTests;
    
        % Lowest robustness (= automatic fitness)
        best_Rob(jj,1) = Res_STa{jj}.run.bestRob;
        best_Rob(jj,2) = Res_AThM{jj}.run.bestRob;
        best_Rob(jj,3) = Res_ATh{jj}.run.bestRob;

        % Falsified or not
        fals(jj,:) = (best_Rob(jj,:) <= 0);
    end

    %% 4 - Compute quality parameters
    Avg_iter = max(n_iter,[],'all')*ones(1,3);
    Med_iter = max(n_iter,[],'all')*ones(1,3);
    Avg_rob = max(best_Rob,[],'all')*ones(1,3);
    Med_rob = max(best_Rob,[],'all')*ones(1,3);

    % Success Rate
    SuccRate = round(sum(fals)/size(fals,1),2);
    
    for jj = 1:length(Avg_iter)
        % Average and median number of runs (only for runs that were falsified)
        Avg_iter(jj) = floor(mean(n_iter(fals(:,jj),jj)));
        Med_iter(jj) = floor(median(n_iter(fals(:,jj),jj)));

        % Average and median minimum robustness (only for runs that were not
        % falsified)
        Avg_rob(jj) = mean(best_Rob(~fals(:,jj),jj));
        Med_rob(jj) = median(best_Rob(~fals(:,jj),jj));
    end

    %% 5 - Print out quality parameters
    if isa(Data(ii).model,'function_handle')
        Data(ii).model = func2str(Data(ii).model);
    end
    fprintf('Model:\t\t%s\n',Data(ii).model)
    fprintf('Requirement:\t%s - %s\n',Data(ii).requirement,Data(ii).phi)
    if isfield(Data(ii),'BEE_param')
        InStr = Data(ii).BEE_param.InStr;
        InRange = Data(ii).BEE_param.InRange;
    else
        InStr = Data(ii).Athena_param.InStr;
        InRange = Data(ii).Athena_param.InRange;
    end
    for jj = 1:length(InStr)
        fprintf('Input range - %s:\t%i\t%i\n',InStr{jj},InRange(jj,1),InRange(jj,2))
    end
    disp(' ')
    
    fprintf('\t\t\t%s\t%s\t%s\n',TitleStr{1},TitleStr{2},TitleStr{3})
    fprintf('Success rate:\t\t%.0f%%\t\t%.0f%%\t\t%.0f%%\n',SuccRate(1)*100,SuccRate(2)*100,SuccRate(3)*100)
    fprintf('Average iterations:\t%i\t\t%i\t\t%i\n',Avg_iter(1),Avg_iter(2),Avg_iter(3))
    fprintf('Median iterations:\t%i\t\t%i\t\t%i\n',Med_iter(1),Med_iter(2),Med_iter(3))
    fprintf('Average robustness:\t%.3f\t\t%.3f\t\t%.3f\n',Avg_rob(1),Avg_rob(2),Avg_rob(3))
    fprintf('Median robustness:\t%.3f\t\t%.3f\t\t%.3f\n\n',Med_rob(1),Med_rob(2),Med_rob(3))
    fprintf('\t\t\t*\t*\t*\n\n')

end