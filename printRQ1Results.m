clearvars
clearvars -global
close all
clc

addpath(genpath('Athena/staliro'))

%% Find all data files

fileList = dir('Results/RQ1');
fileName = {fileList.name}';

% Remove files that do not start with 'Athena'
nameTemp = strfind(fileName,'Athena');
boolTemp = cell(size(nameTemp));
boolTemp(:) = {1};
boolMask = cellfun(@isequal,nameTemp,boolTemp);

fileList = fileList(boolMask);
fileName = fileName(boolMask);

% Create table containing file references
fileTable = table('Size',[length(fileList),4],'VariableTypes',{'string','double','string','string'}, ...
    'VariableNames',{'Requirement','Subject','Date','File_name'});

for ii = 1:length(fileName)

    % Drop the format '.mat'
    fileTemp = erase(fileName{ii},'.mat');

    % Split name into single information
    fileInfo = split(fileTemp,'_');

    % Save information in table
    fileTable.Subject(ii) = str2double(erase(fileInfo(2),"Subj"));
    fileTable.Requirement(ii) = string(fileInfo(3));
    fileTable.Date(ii) = string(fileInfo(4));
    fileTable.File_name(ii) = string(fileName(ii));
end

% Obtain list of requirement
reqList = unique(fileTable.Requirement);
if length(reqList) == 6
    orderTemp = [2,1,4,6,3,5]';
    reqList = reqList(orderTemp);
else
    reqList = sort(reqList);
end

% Obtain list of test subjects
subList = unique(fileTable.Subject);

% Delete temporary variables
clear('*Temp')

%% Read all data files

% Initialize matrices
fals = false(length(reqList),length(subList));
nIter = NaN(length(reqList),length(subList));
time = load('Results/RQ1/writing_time.mat');
time = time.time;

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
    
    % Loop over all the subjects
    for jj = 1:length(subList)

        nameTemp = reqTable.File_name(strcmpi(reqTable.Requirement,reqTemp) & reqTable.Subject == jj);
        
        % Check that the file name is acceptable and load the corresponding
        % results.
        if length(nameTemp) > 1
            error('There are multiple files on the same experiment:\n\tRequirement:\t%s\n\tInput range:\t%s\n\tRobustness Coefficient:\t%.2f\n',reqTemp,rangeTemp,pTemp)
        elseif isempty(nameTemp)
            warning('There is no file on this experiment:\n\tRequirement:\t%s\n\tInput range:\t%s\n\tRobustness Coefficient:\t%.2f\n',reqTemp,rangeTemp,pTemp)
            continue
        else
            resTemp = load("Results/RQ1/"+nameTemp,'Results');
            resTemp = resTemp.Results{1}.run;
            fals(ii,jj) = resTemp.bestRob <= 0;
            if ~isnan(resTemp.nTests) && fals(ii,jj)
                nIter(ii,jj) = resTemp.nTests;
            else
                nIter(ii,jj) = NaN;
            end
        end
    end
end

% Delete temporary variables
clear('*Temp')

%% Print Table 6

fprintf('Table 6: Result of the experiments on Manual Fitness functions defined by test subject 1 and 2.\n\n')

fprintf(['\t|',repmat('\t',1,3),'Subject 1',repmat('\t',1,3),'|',repmat('\t',1,3),'Subject 2\n'])
fprintf('RID\t|\tTime [min]\tFailure [Y/N]\tIterations\t|\tTime [min]\tFailure [Y/N]\tIterations\n');
fprintf([repmat('_',1,120),'\n'])

for ii = 1:length(reqList)
    fprintf('%s\t',reqList(ii))
    idx_time = find(strcmp(reqList(ii),[time.Req]));

    for jj = 1:length(subList)
        
        fprintf('|\t%.1f\t\t',time(idx_time).Subj(jj))
        if fals(ii,jj)
            fprintf('\tY\t')
        else
            fprintf('\tN\t')
        end
        fprintf('\t%i\t',nIter(ii,jj))
    end

    fprintf('\n')
end
fprintf('\n\n')

% Compute average time
fprintf('On average, a student required %.1f minutes to define a Manual fitness function.\n\n',mean([time.Subj]))
