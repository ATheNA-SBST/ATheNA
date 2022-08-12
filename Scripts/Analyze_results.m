%% This script analyzes all the results obtained and present them in aggregate form
clearvars
close all
clc

%% Get file names containing Athena
FileName = dir('Results');
FileName = {FileName.name};
idx = contains(FileName,'Athena','IgnoreCase',false);
FileName = FileName(idx)';

%% Load file
n_runs = 50;                            % Number of runs with each algorithm per file
Data = cell(length(FileName),1);        % Raw data from files
Res_STa = cell(length(FileName),n_runs);     % Results with S-Taliro
Res_AThM = cell(length(FileName),n_runs);    % Results with ATheNA-SM
Res_ATh = cell(length(FileName),n_runs);     % Results with ATheNA-S

for ii = 1:length(FileName)
    Data{ii} = load(['Results/',FileName{ii}],'Results');
    
    for jj = 1:n_runs
        Res_STa{ii,jj} = Data{ii}.Results(jj);
        Res_AThM{ii,jj} = Data{ii}.Results(n_runs+jj);
        Res_ATh{ii,jj} = Data{ii}.Results(2*n_runs+jj);
    end
end

%% Get number of iterations and Success Rate
N_iter_STa = cell(size(FileName));
N_iter_AThM = cell(size(FileName));
N_iter_ATh = cell(size(FileName));

Fals_STa = cell(size(FileName));
Fals_AThM = cell(size(FileName));
Fals_ATh = cell(size(FileName));

SR_STa = zeros(size(FileName));
SR_AThM = zeros(size(FileName));
SR_ATh = zeros(size(FileName));

AvgIter_STa = zeros(size(FileName));
AvgIter_AThM = zeros(size(FileName));
AvgIter_ATh = zeros(size(FileName));

for ii = 1:length(FileName)
    for jj = 1:n_runs
        tempSTa = Res_STa{ii,jj};
        N_iter_STa{ii}(jj) = tempSTa{1}.run.nTests;
        tempAThM = Res_AThM{ii,jj};
        N_iter_AThM{ii}(jj) = tempAThM{1}.run.nTests;
        tempATh = Res_ATh{ii,jj};
        N_iter_ATh{ii}(jj) = tempATh{1}.run.nTests;
    
        Fals_STa{ii}(jj) = tempSTa{1}.run.bestRob<=0;
        Fals_AThM{ii}(jj) = tempAThM{1}.run.bestRob<=0;
        Fals_ATh{ii}(jj) = tempATh{1}.run.bestRob<=0;
    end

    % Remove all the runs that reached the maximum number of iterations
    N_iter_STa{ii} = N_iter_STa{ii}(Fals_STa{ii});
    N_iter_AThM{ii} = N_iter_AThM{ii}(Fals_AThM{ii});
    N_iter_ATh{ii} = N_iter_ATh{ii}(Fals_ATh{ii});

    % Evaluate the Success Rate
    SR_STa(ii) = length(N_iter_STa{ii})/n_runs;
    SR_AThM(ii) = length(N_iter_AThM{ii})/n_runs;
    SR_ATh(ii) = length(N_iter_ATh{ii})/n_runs;

    % Compute the average number of iterations
    AvgIter_STa(ii) = mean(N_iter_STa{ii});
    AvgIter_AThM(ii) = mean(N_iter_AThM{ii});
    AvgIter_ATh(ii) = mean(N_iter_ATh{ii});

end

% If a requirement has never been falsified, the average number of
% iterations is the maximum: 300
AvgIter_STa(isnan(AvgIter_STa)) = 300;
AvgIter_AThM(isnan(AvgIter_AThM)) = 300;
AvgIter_ATh(isnan(AvgIter_ATh)) = 300;

%% RQ1: ATheNA is the best
idx = (SR_ATh >= SR_STa) & (SR_ATh >= SR_AThM);
fprintf('ATheNA beats S-Taliro and ATheNA-SM %i times out of %i.\n\n',sum(idx),length(FileName));

% ATheNA vs S-Taliro
diff = SR_ATh(idx)-SR_STa(idx);
fprintf('Comparison ATheNA vs S-Taliro:\tAverage:\t%.1f %%\n',round(mean(diff)*100,1))
fprintf('\t\t\t\tMaximum:\t%i %%\n',round(max(diff)*100))
fprintf('\t\t\t\tMinimum:\t%i %%\n',round(min(diff)*100))
fprintf('\t\t\t\tSt Dev:\t\t%.1f %%\n\n',round(std(diff)*100,1))

% ATheNA vs ATheNA-SM
diff = SR_ATh(idx)-SR_AThM(idx);
fprintf('Comparison ATheNA vs ATheNA-SM:\tAverage:\t%.1f %%\n',round(mean(diff)*100,1))
fprintf('\t\t\t\tMaximum:\t%i %%\n',round(max(diff)*100))
fprintf('\t\t\t\tMinimum:\t%i %%\n',round(min(diff)*100))
fprintf('\t\t\t\tSt Dev:\t\t%.1f %%\n\n',round(std(diff)*100,1))

%% RQ1: ATheNA loses
% S-Taliro vs ATheNA
idx = (SR_ATh < SR_STa);
fprintf('ATheNA loses to S-Taliro %i times out of %i.\n\n',sum(idx),length(FileName));

diff = SR_STa(idx)-SR_ATh(idx);
fprintf('Comparison S-Taliro vs ATheNA:\tAverage:\t%.1f %%\n',round(mean(diff)*100,1))
fprintf('\t\t\t\tMaximum:\t%i %%\n',round(max(diff)*100))
fprintf('\t\t\t\tMinimum:\t%i %%\n',round(min(diff)*100))
fprintf('\t\t\t\tSt Dev:\t\t%.1f %%\n\n',round(std(diff)*100,1))

% ATheNA-SM vs ATheNA
idx = (SR_ATh < SR_AThM);
fprintf('ATheNA loses to ATheNA-SM %i times out of %i.\n\n',sum(idx),length(FileName));

diff = SR_AThM(idx)-SR_ATh(idx);
fprintf('Comparison ATheNA-SM vs ATheNA:\tAverage:\t%.1f %%\n',round(mean(diff)*100,1))
fprintf('\t\t\t\tMaximum:\t%i %%\n',round(max(diff)*100))
fprintf('\t\t\t\tMinimum:\t%i %%\n',round(min(diff)*100))
fprintf('\t\t\t\tSt Dev:\t\t%.1f %%\n\n',round(std(diff)*100,1))

%% Full comparison and Wilcoxon rank-sum test

fprintf('Considering all the experiments.\n\n')

% ATheNA vs S-Taliro
diff = SR_ATh-SR_STa;
fprintf('Comparison ATheNA vs S-Taliro (full range):\tAverage:\t%.1f %%\n',round(mean(diff)*100,1))
fprintf('\t\t\t\t\t\tMaximum:\t%i %%\n',round(max(diff)*100))
fprintf('\t\t\t\t\t\tMinimum:\t%i %%\n',round(min(diff)*100))
fprintf('\t\t\t\t\t\tSt Dev:\t\t%.1f %%\n',round(std(diff)*100,1))
[p, h] = ranksum(SR_ATh,SR_STa,'tail','right','alpha',0.175);
% [p, h] = ranksum(SR_ATh,SR_STa,'tail','left','alpha',0.05);
fprintf('\t\t\t\t\t\tProb:\t\t%.3f [%i]\n\n',p,h)

diff = AvgIter_STa-AvgIter_ATh;
fprintf('\t\t\t\t\t\tAverage:\t%.1f iter\n',mean(diff))
fprintf('\t\t\t\t\t\tMaximum:\t%.1f iter\n',max(diff))
fprintf('\t\t\t\t\t\tMinimum:\t%.1f iter\n',min(diff))
fprintf('\t\t\t\t\t\tSt Dev:\t\t%.1f iter\n',std(diff))
% [p, h] = ranksum(AvgIter_ATh,AvgIter_STa,'tail','right','alpha',0.05);
[h, p] = ttest2(AvgIter_ATh,AvgIter_STa,'alpha',0.10);
fprintf('\t\t\t\t\t\tProb:\t\t%.3f [%i]\n\n',p,h)

% ATheNA vs ATheNA-SM
diff = SR_ATh-SR_AThM;
fprintf('Comparison ATheNA vs ATheNA-SM (full range):\tAverage:\t%.1f %%\n',round(mean(diff)*100,1))
fprintf('\t\t\t\t\t\tMaximum:\t%i %%\n',round(max(diff)*100))
fprintf('\t\t\t\t\t\tMinimum:\t%i %%\n',round(min(diff)*100))
fprintf('\t\t\t\t\t\tSt Dev:\t\t%.1f %%\n',round(std(diff)*100,1))
[p, h] = ranksum(SR_ATh,SR_AThM,'tail','right','alpha',0.175);
fprintf('\t\t\t\t\t\tProb:\t\t%.3f [%i]\n\n',p,h)

diff = AvgIter_AThM-AvgIter_ATh;
fprintf('\t\t\t\t\t\tAverage:\t%.1f iter\n',mean(diff))
fprintf('\t\t\t\t\t\tMaximum:\t%.1f iter\n',max(diff))
fprintf('\t\t\t\t\t\tMinimum:\t%.1f iter\n',min(diff))
fprintf('\t\t\t\t\t\tSt Dev:\t\t%.1f iter\n',std(diff))
% [p, h] = ranksum(AvgIter_ATh,AvgIter_AThM,'tail','left','alpha',0.05);
[h, p] = ttest2(AvgIter_ATh,AvgIter_AThM,'alpha',0.10);
fprintf('\t\t\t\t\t\tProb:\t\t%.3f [%i]\n\n',p,h)