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

%% Compute results for RQ2

% Number of experiments with the same result (regardless of p).
n_equal = sum(all(succRate(:,1) == succRate(:,1:length(pList)),2));
n_equal = n_equal + sum(all(succRate(:,length(pList)+1) == succRate(:,length(pList)+1:end) & ~isnan(succRate(:,length(pList)+1:end)),2));
n_diff = n_exp-n_equal;
fprintf('For %i out of %i experiments (%.1f %%), the value assigned to the parameter p does not influence the percentage of failure-revealing runs.\n',n_equal,n_exp,n_equal/n_exp*100)
fprintf('For %i out of %i experiments (%.1f %%), the value assigned to the parameter p influences the percentage of failure-revealing runs.\n\n',n_exp-n_equal,n_exp,(1-n_equal/n_exp)*100)

% Number of experiments with the best result dependig on the tool.
idx_man = find(pList == 0);
idx_aut = find(pList == 1);
idx_mix = find(0 < pList & pList < 1);

man_SR = [succRate(:,idx_man),succRate(:,idx_man+length(pList))];
aut_SR = [succRate(:,idx_aut),succRate(:,idx_aut+length(pList))];
mix_SR = [max(succRate(:,idx_mix),[],2),max(succRate(:,idx_mix+length(pList)),[],2)];

n_man = sum(man_SR > aut_SR & man_SR > mix_SR & ~isnan(man_SR),'all');
n_aut = sum(aut_SR > man_SR & aut_SR > mix_SR & ~isnan(aut_SR),'all');
n_mix = sum(mix_SR > man_SR & mix_SR > aut_SR & ~isnan(mix_SR),'all');

fprintf('For %i out of %i experiments (%.1f %%), p = 0 (only manual fitness function) produces more failure-revealing runs than the other values of p.\n',n_man,n_diff,n_man/n_diff*100)
fprintf('For %i out of %i experiments (%.1f %%), p = 1 (only automatic fitness function) produces more failure-revealing runs than the other values of p.\n',n_aut,n_diff,n_aut/n_diff*100)
fprintf('For %i out of %i experiments (%.1f %%), 0 < p < 1 (both fitness functions) produces more failure-revealing runs than p = 0 and p = 1.\n',n_mix,n_diff,n_mix/n_diff*100)
fprintf('For %i out of %i experiments (%.1f %%), at least two of the strategies produces the same number of failure-revealing runs.\n\n',n_diff-(n_man+n_aut+n_mix),n_diff,(1-(n_man+n_aut+n_mix)/n_diff)*100)

% Min variation, max variation, average variation, std of variation
max_SR = [max(succRate(:,1:length(pList)),[],2), max(succRate(:,length(pList)+1:end),[],2)];
min_SR = [min(succRate(:,1:length(pList)),[],2), min(succRate(:,length(pList)+1:end),[],2)];
diff_SR = max_SR-min_SR;
diff_SR = reshape(diff_SR,[],1);
diff_SR = diff_SR(~isnan(diff_SR) & diff_SR ~= 0);

fprintf('The minimum variation in the percentage of failure-revealing runs across the requirement-assumption combinations we considered is %.0f %%.\n',min(diff_SR)*100)
fprintf('The maximum variation in the percentage of failure-revealing runs across the requirement-assumption combinations we considered is %.0f %%.\n',max(diff_SR)*100)
fprintf('The average variation in the percentage of failure-revealing runs across the requirement-assumption combinations we considered is %.1f %%.\n',mean(diff_SR)*100)
fprintf('The standard deviation of the variations in the percentage of failure-revealing runs across the requirement-assumption combinations we considered is %.1f %%.\n\n',std(diff_SR)*100)

