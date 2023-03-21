clearvars
clearvars -global
close all
clc

addpath(genpath('Athena/staliro'))

%% Find all data files

fileList = dir('Results/RQ2-RQ3-RQ4');
fileName = {fileList.name}';

% Remove files that do not start with 'Athena'
nameTemp = strfind(fileName,'Athena');
boolTemp = cell(size(nameTemp));
boolTemp(:) = {1};
boolMask = cellfun(@isequal,nameTemp,boolTemp);

fileList = fileList(boolMask);
fileName = fileName(boolMask);

% Create table containing file references
fileTable = table('Size',[length(fileList),5],'VariableTypes',{'string','string','double','string','string'}, ...
    'VariableNames',{'Requirement','Input_range','Coeff_rob','Date','File_name'});

for ii = 1:length(fileName)

    % Drop the format '.mat'
    fileTemp = erase(fileName{ii},'.mat');

    % Split name into single information
    fileInfo = split(fileTemp,'_');

    % Save information in table
    fileTable.Requirement(ii) = string(fileInfo(2));

    if strcmp(fileInfo(3),'origRange')
        fileTable.Input_range(ii) = "Original";
    elseif strcmp(fileInfo(3),'modRange')
        fileTable.Input_range(ii) = "Modified";
    end

    fileTable.Coeff_rob(ii) = str2double(fileInfo(5))/100;
    fileTable.Date(ii) = string(fileInfo(6));
    fileTable.File_name(ii) = string(fileName(ii));
end

% Obtain list of requirement
reqList = unique(fileTable.Requirement);
if length(reqList) == 27
    orderTemp = [4:10,12,13,11,1:3,21,22,24:27,14:19,20,23]';
    reqList = reqList(orderTemp);
else
    reqList = sort(reqList);
end

% Obtain list of values of p
pList = unique(fileTable.Coeff_rob);
pList = sort(pList);

% Delete temporary variables
clear('*Temp')

%% Compute Success Rate (SR) for each requirement
% SR = Percentage of runs that find a failure-revealing test case.

% Initialize the Success-Rate matrix as a matrix of NaN's.
succRate = NaN(length(reqList),length(pList)*2);

% Number of experiments under consideration:
    % Experiment = Requirement x Input assumption
n_exp = 0;

% Loop over the requirements.
for ii = 1:length(reqList)

    % Choose a requirement from the list
    reqTemp = reqList(ii);

    % Check that the requirement is one of the available ones
    if ~strcmpi(reqTemp,{'at1','at2','at51','at52','at53','at54','at6a','at6b','at6c','at6abc','cc1','cc2',...
            'cc3','cc4','cc5','ccx','wt1','wt2','wt3','wt4','afc27','afc29','afc33','nn','nnx','f16','sc'})
        error('The chosen requirement %s is not one used for ATheNA.',upper(reqTemp))
    end
    
    % Filter the files related to the chosen requirement
    boolTemp = strcmpi(reqTemp,fileTable.Requirement);
    reqTable = fileTable(boolTemp,:);
    
    % Check if the current requirement has been evaluated also outside the
    % original range.
    modBool = any(contains(reqTable.Input_range,"Modified"));
    n_exp = n_exp+(1+modBool);
    
    % Loop over all the values of p
    for jj = 1:2*length(pList)

        % Check first the files with the original input range.
        if jj <= length(pList)
            rangeTemp = "Original";
            pTemp = pList(jj);

        % Then check the files with the modified input range (if it
        % exists).
        else
            if modBool
                rangeTemp = "Modified";
                pTemp = pList(jj-length(pList));
            else
                break
            end
        end

        nameTemp = reqTable.File_name(strcmpi(reqTable.Input_range,rangeTemp) & reqTable.Coeff_rob == pTemp);
        
        % Check that the file name is acceptable and load the corresponding
        % results.
        if length(nameTemp) > 1
            error('There are multiple files on the same experiment:\n\tRequirement:\t%s\n\tInput range:\t%s\n\tRobustness Coefficient:\t%.2f\n',reqTemp,rangeTemp,pTemp)
        elseif isempty(nameTemp)
            warning('There is no file on this experiment:\n\tRequirement:\t%s\n\tInput range:\t%s\n\tRobustness Coefficient:\t%.2f\n',reqTemp,rangeTemp,pTemp)
            continue
        else
            resTemp = load("Results/RQ2-RQ3-RQ4/"+nameTemp,'SuccRate');
            succRate(ii,jj) = resTemp.SuccRate;
        end
    end
end

% Delete temporary variables
clear('*Temp')

%% Compute results for RQ3

% Find best value for p overall
succRate = [succRate(:,1:length(pList)); succRate(:,length(pList)+1:end)];
if any(any(isnan(succRate),2) & ~all(isnan(succRate),2))
    warning('For one at least one combination requirement-input assumption, the Success Rate is missing.')
end
succRate = succRate(~any(isnan(succRate),2),:);

p_Opt = zeros(size(succRate,1),1);

for ii = 1:length(p_Opt)
    p_Temp = pList(succRate(ii,:) == max(succRate(ii,:)));
    p_Opt(ii) = mean(p_Temp);
end
p_Temp = mean(p_Opt);
p_best = pList(abs(pList-p_Temp) == min(abs(pList-p_Temp)));

fprintf('The value of p with the highest failure-revealing capabilities over all the experiments is p = %.1f.\n\n',p_best)

% Compute SR for each tool
idx00 = find(pList == 0);
idx05 = find(pList == 0.5);
idx10 = find(pList == 1);

man_SR = succRate(:,idx00);
aut_SR = succRate(:,idx10);
avg_SR = succRate(:,idx05);
best_SR = max(succRate,[],2);

man_SR = man_SR(~isnan(man_SR));
aut_SR = aut_SR(~isnan(aut_SR));
avg_SR = avg_SR(~isnan(avg_SR));
best_SR = best_SR(~isnan(best_SR));
resTemp = [man_SR, aut_SR, avg_SR, best_SR];

% Case 1: ATheNA-avg better or equal to ATheNA-man and ATheNA-aut
n_exp = length(avg_SR);
n_win = sum(avg_SR >= man_SR & avg_SR >= aut_SR,'all');

man_SR_Temp = man_SR(avg_SR >= man_SR & avg_SR >= aut_SR);
aut_SR_Temp = aut_SR(avg_SR >= man_SR & avg_SR >= aut_SR);
avg_SR_Temp = avg_SR(avg_SR >= man_SR & avg_SR >= aut_SR);

fprintf('For %i out of %i experiments (%.1f %%), ATheNA-S_avg produces more or as many failure-revealing runs as ATheNA-SA and ATheNA-SM.\n\n',n_win,n_exp,n_win/n_exp*100)

fprintf('\tATheNA-S_avg vs ATheNA-SA\n')
fprintf('\t\tAvg increment:\t\t%.1f %%\n',mean(avg_SR_Temp-aut_SR_Temp)*100)
fprintf('\t\tMin increment:\t\t%.0f %%\n',min(avg_SR_Temp-aut_SR_Temp)*100)
fprintf('\t\tMax increment:\t\t%.0f %%\n',max(avg_SR_Temp-aut_SR_Temp)*100)
fprintf('\t\tStDev increment:\t%.1f %%\n\n',std(avg_SR_Temp-aut_SR_Temp)*100)

fprintf('\tATheNA-S_avg vs ATheNA-SM\n')
fprintf('\t\tAvg increment:\t\t%.1f %%\n',mean(avg_SR_Temp-man_SR_Temp)*100)
fprintf('\t\tMin increment:\t\t%.0f %%\n',min(avg_SR_Temp-man_SR_Temp)*100)
fprintf('\t\tMax increment:\t\t%.0f %%\n',max(avg_SR_Temp-man_SR_Temp)*100)
fprintf('\t\tStDev increment:\t%.1f %%\n\n',std(avg_SR_Temp-man_SR_Temp)*100)

% Case 2: ATheNA-avg worse than ATheNA-aut
n_lose_aut = sum(aut_SR > avg_SR,'all');

aut_SR_Temp = aut_SR(aut_SR > avg_SR);
avg_SR_Temp = avg_SR(aut_SR > avg_SR);

fprintf('For %i out of %i experiments (%.1f %%), ATheNA-S_avg produces less failure-revealing runs than ATheNA-SA.\n\n',n_lose_aut,n_exp,n_lose_aut/n_exp*100)

fprintf('\tATheNA-SA vs ATheNA-S_avg\n')
fprintf('\t\tAvg decrease:\t\t%.1f %%\n',mean(aut_SR_Temp-avg_SR_Temp)*100)
fprintf('\t\tMin decrease:\t\t%.0f %%\n',min(aut_SR_Temp-avg_SR_Temp)*100)
fprintf('\t\tMax decrease:\t\t%.0f %%\n',max(aut_SR_Temp-avg_SR_Temp)*100)
fprintf('\t\tStDev decrease:\t\t%.1f %%\n\n',std(aut_SR_Temp-avg_SR_Temp)*100)

% Case 3: ATheNA-avg worse than ATheNA-man
n_lose_man = sum(man_SR > avg_SR,'all');

man_SR_Temp = man_SR(man_SR > avg_SR);
avg_SR_Temp = avg_SR(man_SR > avg_SR);

fprintf('For %i out of %i experiments (%.1f %%), ATheNA-S_avg produces less failure-revealing runs than ATheNA-SM.\n\n',n_lose_man,n_exp,n_lose_man/n_exp*100)

fprintf('\tATheNA-SM vs ATheNA-S_avg\n')
fprintf('\t\tAvg decrease:\t\t%.1f %%\n',mean(man_SR_Temp-avg_SR_Temp)*100)
fprintf('\t\tMin decrease:\t\t%.0f %%\n',min(man_SR_Temp-avg_SR_Temp)*100)
fprintf('\t\tMax decrease:\t\t%.0f %%\n',max(man_SR_Temp-avg_SR_Temp)*100)
fprintf('\t\tStDev decrease:\t\t%.1f %%\n\n',std(man_SR_Temp-avg_SR_Temp)*100)

% Case 4: All the experiments
fprintf('Now considering all %i experiments:\n\n',n_exp)

fprintf('\tATheNA-S_avg vs ATheNA-SA\n')
fprintf('\t\tAvg increment:\t\t%.1f %%\n',mean(avg_SR-aut_SR)*100)
fprintf('\t\tMin increment:\t\t%.0f %%\n',min(avg_SR-aut_SR)*100)
fprintf('\t\tMax increment:\t\t%.0f %%\n',max(avg_SR-aut_SR)*100)
fprintf('\t\tStDev increment:\t%.1f %%\n\n',std(avg_SR-aut_SR)*100)

fprintf('\tATheNA-S_avg vs ATheNA-SM\n')
fprintf('\t\tAvg increment:\t\t%.1f %%\n',mean(avg_SR-man_SR)*100)
fprintf('\t\tMin increment:\t\t%.0f %%\n',min(avg_SR-man_SR)*100)
fprintf('\t\tMax increment:\t\t%.0f %%\n',max(avg_SR-man_SR)*100)
fprintf('\t\tStDev increment:\t%.1f %%\n\n',std(avg_SR-man_SR)*100)

fprintf('\tATheNA-S_best vs ATheNA-SA\n')
fprintf('\t\tAvg increment:\t\t%.1f %%\n',mean(best_SR-aut_SR)*100)
fprintf('\t\tMin increment:\t\t%.0f %%\n',min(best_SR-aut_SR)*100)
fprintf('\t\tMax increment:\t\t%.0f %%\n',max(best_SR-aut_SR)*100)
fprintf('\t\tStDev increment:\t%.1f %%\n\n',std(best_SR-aut_SR)*100)

fprintf('\tATheNA-S_best vs ATheNA-SM\n')
fprintf('\t\tAvg increment:\t\t%.1f %%\n',mean(best_SR-man_SR)*100)
fprintf('\t\tMin increment:\t\t%.0f %%\n',min(best_SR-man_SR)*100)
fprintf('\t\tMax increment:\t\t%.0f %%\n',max(best_SR-man_SR)*100)
fprintf('\t\tStDev increment:\t%.1f %%\n\n',std(best_SR-man_SR)*100)

% Statistical tests
sig_level = 0.05;
p_value = zeros(4,1);
h_test = false(4,1);

    % ATheNA-S_avg vs ATheNA-SA
    [p_value(1), h_test(1)] = signrank(avg_SR,aut_SR,'alpha',sig_level,'tail','right');
    fprintf('The Wilcoxon signed rank test ');
    if h_test(1)
        fprintf('confirms ');
    else
        fprintf('does not confirm ');
    end
    fprintf('that ATheNA-S_avg has a higher SR median than ATheNA-SA with a p-value of %.2e.\n',p_value(1));

    % ATheNA-S_avg vs ATheNA-SM
    [p_value(2), h_test(2)] = signrank(avg_SR,man_SR,'alpha',sig_level,'tail','right');
    fprintf('The Wilcoxon signed rank test ');
    if h_test(2)
        fprintf('confirms ');
    else
        fprintf('does not confirm ');
    end
    fprintf('that ATheNA-S_avg has a higher SR median than ATheNA-SM with a p-value of %.2e.\n',p_value(2));

    % ATheNA-S_best vs ATheNA-SA
    [p_value(3), h_test(3)] = signrank(best_SR,aut_SR,'alpha',sig_level,'tail','right');
    fprintf('The Wilcoxon signed rank test ');
    if h_test(3)
        fprintf('confirms ');
    else
        fprintf('does not confirm ');
    end
    fprintf('that ATheNA-S_best has a higher SR median than ATheNA-SA with a p-value of %.2e.\n',p_value(3));

    % ATheNA-S_best vs ATheNA-SM
    [p_value(4), h_test(4)] = signrank(best_SR,man_SR,'alpha',sig_level,'tail','right');
    fprintf('The Wilcoxon signed rank test ');
    if h_test(4)
        fprintf('confirms ');
    else
        fprintf('does not confirm ');
    end
    fprintf('that ATheNA-S_best has a higher SR median than ATheNA-SM with a p-value of %.2e.\n',p_value(4));

