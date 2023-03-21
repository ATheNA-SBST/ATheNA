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

%% Compute Success Rate (SR) and number of iterations for each requirement
% SR = Percentage of runs that find a failure-revealing test case.

% Initialize the Success-Rate matrix as a matrix of NaN's.
succRate = NaN(length(reqList),length(pList)*2);

% Initialize the number of iterations matrix as a matrix of NaN's.
    % It is assumed that all experiments have been run with the same number
    % of runs.
n_runs = load("Results/RQ2-RQ3-RQ4/"+fileTable.File_name(1),'n_runs');
n_runs = n_runs.n_runs;
nIter = zeros(length(reqList),length(pList)*2,n_runs);

% Initialize the matrix of falsified runs as false.
fals = false(length(reqList),length(pList)*2,n_runs);

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
            resTemp = load("Results/RQ2-RQ3-RQ4/"+nameTemp,'SuccRate','n_iter','Results');
            succRate(ii,jj) = resTemp.SuccRate;
            nIter_Temp = resTemp.n_iter;
            falsTemp = [resTemp.Results{:}];
            falsTemp = [falsTemp.run];
            falsTemp = [falsTemp.bestRob] <= 0;
            nIter_Temp(~falsTemp) = NaN;

            nIter(ii,jj,:) = nIter_Temp;
            fals(ii,jj,:) = falsTemp;
        end
    end
end

% Delete temporary variables
clear('*Temp')

%% Compute number of iterations for case pBest

% Treat SR and nIter for different input ranges as indipendent cases.
succRate = [succRate(:,1:length(pList)); succRate(:,length(pList)+1:end)];
nIter = [nIter(:,1:length(pList),:); nIter(:,length(pList)+1:end,:)];
fals = [fals(:,1:length(pList),:); fals(:,length(pList)+1:end,:)];

% Remove experiments not done (with SR = NaN for each value of p).
idx_Temp = all(~isnan(succRate),2);
succRate = succRate(idx_Temp,:);
nIter = nIter(idx_Temp,:,:);
fals = fals(idx_Temp,:,:);

% Compute pBest and the corresponding iterations
nIter_best = NaN(size(nIter,1),1,n_runs);
fals_best = false(size(fals,1),1,n_runs);
for ii = 1:size(succRate,1)
    idx_best = find(succRate(ii,:) == max(succRate(ii,:)));

    if length(idx_best) == 1
        nIter_best(ii,1,:) = nIter(ii,idx_best,:);
        fals_best(ii,1,:) = fals(ii,idx_best,:);
    else
        % If multiple samples have the same SR as pBest, we do the average
        % of the iteration numbers.
            % The nIter and fals matrix must be transposed to be reshaped
            % correctly.
        nIterTemp = squeeze(nIter(ii,idx_best,:))';
        nIterTemp = nIterTemp(squeeze(fals(ii,idx_best,:))');
        nIterTemp = reshape(nIterTemp,[],length(idx_best));
        nIterTemp = round(mean(nIterTemp,2));
        nIter_best(ii,1,:) = [nIterTemp; NaN*ones(n_runs-length(nIterTemp),1)];
        fals_best(ii,1,:) = [true(length(nIterTemp),1); false(n_runs-length(nIterTemp),1)];
    end
end

% Check that nIter_best has been constructed correctly
if sum(~isnan(nIter_best),'all') ~= sum(max(succRate,[],2),'all')*n_runs
    error('The number of runs for p = pBest is incorrect (check number of iterations matrix).')
end

if sum(fals_best,'all') ~= sum(max(succRate,[],2),'all')*n_runs
    error('The number of runs for p = pBest is incorrect (check falsification matrix).')
end

% Append case pBest to the other cases
pList = [pList; NaN];
succRate = [succRate, max(succRate,[],2)];
nIter(:,8,:) = nIter_best;
fals(:,8,:) = fals_best;

% Delete temporary variables
clear('*Temp')

%% Plot the boxplot

% Filter runs without falsification
N_iter_flat = [];
Group = [];
Avg_iter = zeros(1,length(pList));
label_p = cell(1,length(pList));

for ii = 1:length(pList)
    N_iter_Temp = squeeze(nIter(:,ii,:));
    N_iter_Temp = N_iter_Temp(~isnan(N_iter_Temp));
    N_iter_flat = [N_iter_flat; N_iter_Temp];
    Group = [Group; (ii-1)*ones(length(N_iter_Temp),1)];
    Avg_iter(ii) = mean(N_iter_Temp);

    if ~isnan(pList(ii))
        label_p{ii} = sprintf('$p=%.2f$',pList(ii));
    else
        label_p{ii} = '$p=p_{best}$';
    end
end

% Plot the boxplot
figure(1)
clf
hold on
grid on
boxplot(N_iter_flat,Group,'labels',label_p)
plot(Avg_iter,'d','MarkerSize',10,'Color',[0.6, 0.6, 0.6])
set(gca,'FontSize',24,'TickLabelInterpreter','latex')
ylabel('$\#~Iterations$','Interpreter','latex','FontSize',24)
xlim([0.5,8.5])
ylim([-10, 310])
set(gcf,'Units','normalized','Position',[0.2,0.2,0.6,0.4])
% set(findobj(gca,'type','line'),'linew',1)
saveas(gcf,'Tables_Figures/Boxplot.eps','eps')

% Delete temporary variables
clear('*Temp')