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
            resTemp = load("Results/RQ2-RQ3-RQ4/"+nameTemp,'SuccRate');
            succRate(ii,jj) = resTemp.SuccRate;
        end
    end
end

% Delete temporary variables
clear('*Temp')

%% Print Table 5

idx00 = find(pList == 0);

% Print Table 5
fprintf('Table 5: Percentage of failure-revaling runs for each assumption-requirement combination considering only the Manual Fitness Function.\n\n')
fprintf("RID\t|\tR\t\tR'\n")
fprintf([repmat('_',1,40),'\n'])
for ii = 1:length(reqList)
    stringTemp = string(succRate(ii,[idx00, idx00+length(pList)]));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(reqList(ii)+"\t|\t"+join(stringTemp,"\t|\t")+"\n")
end
fprintf(repmat(newline,1,2))

% Save Table 5
nameTemp = 'Tables_Figures/table_5.csv';
fileID = fopen(nameTemp,'w+');
fprintf(fileID,"RID,R,R'\n");
for ii = 1:length(reqList)
    stringTemp = string(succRate(ii,[idx00, idx00+length(pList)]));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(fileID,reqList(ii)+","+join(stringTemp,",")+"\n");
end
fclose(fileID);

% Delete temporary variables
clear('*Temp')

%% Print Table 6

% Table 6 is produced by the script 'printResultsRQ1.m'

%% Print Table 7

% Print Table 7
fprintf('Table 7: Percentage of failure-revaling runs for each value of p and assumption-requirement combination.\n\n')
fprintf(['\t|',repmat('\t',1,7),'R',repmat('\t',1,7),'|',repmat('\t',1,7),'R''\n'])
fprintf("p\t|\t"+join(string(pList),"\t\t")+"\t|\t"+join(string(pList),"\t\t")+"\n")
fprintf([repmat('_',1,235),'\n'])
for ii = 1:length(reqList)
    stringTemp = string(succRate(ii,:));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(reqList(ii)+"\t|\t"+join(stringTemp(1:length(pList)),"\t\t")+"\t|\t"+join(stringTemp(length(pList)+1:end),"\t\t")+"\n")
end
fprintf(repmat(newline,1,2))

% Save Table 7
nameTemp = 'Tables_Figures/table_7.csv';
fileID = fopen(nameTemp,'w+');
fprintf(fileID,"p,"+join(string(pList),",")+","+join(string(pList),",")+"\n");
for ii = 1:length(reqList)
    stringTemp = string(succRate(ii,:));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(fileID,reqList(ii)+","+join(stringTemp,",")+"\n");
end
fclose(fileID);

% Delete temporary variables
clear('*Temp')

%% Print Table 8

% Maximum, minimum and difference of SR for each requirement and input range
max_SR = [max(succRate(:,1:length(pList)),[],2), max(succRate(:,length(pList)+1:end),[],2)];
min_SR = [min(succRate(:,1:length(pList)),[],2), min(succRate(:,length(pList)+1:end),[],2)];
diff_SR = max_SR-min_SR;
resTemp = [max_SR(:,1), min_SR(:,1), diff_SR(:,1), ...
    max_SR(:,2), min_SR(:,2), diff_SR(:,2)];

% Print Table 8
fprintf('Table 8: Maximum, minimum, and variation percentage of failure-revealing runs for each value of p and assumption-requirement combination.\n\n')
fprintf(['\t|',repmat('\t',1,3),'R',repmat('\t',1,3),'|',repmat('\t',1,3),'R''\n'])
fprintf("\t|\t"+join(["max","min","diff"],"\t\t")+"\t|\t"+join(["max","min","diff"],"\t\t")+"\n")
fprintf([repmat('_',1,110),'\n'])
for ii = 1:length(reqList)
    stringTemp = string(resTemp(ii,:));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(reqList(ii)+"\t|\t"+join(stringTemp(1:3),"\t\t")+"\t|\t"+join(stringTemp(4:end),"\t\t")+"\n")
end
fprintf(repmat(newline,1,2))

% Save Table 8
nameTemp = 'Tables_Figures/table_8.csv';
fileID = fopen(nameTemp,'w+');
fprintf(fileID,","+"max,min,diff"+","+"max,min,diff"+"\n");
for ii = 1:length(reqList)
    stringTemp = string(resTemp(ii,:));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(fileID,reqList(ii)+","+join(stringTemp,",")+"\n");
end
fclose(fileID);

% Delete temporary variables
clear('*Temp')

%% Print Table 9

% Compute ATheNA-Manual (p=0), ATheNA-Automatic (p=1), ATheNA-half (p=0.5),
% ATheNA_best.
idx00 = find(pList == 0);
idx05 = find(pList == 0.5);
idx10 = find(pList == 1);

man_SR = [succRate(:,idx00),succRate(:,idx00+length(pList))];
aut_SR = [succRate(:,idx10),succRate(:,idx10+length(pList))];
avg_SR = [succRate(:,idx05),succRate(:,idx05+length(pList))];
best_SR = max_SR;
resTemp = [man_SR(:,1), aut_SR(:,1), avg_SR(:,1), best_SR(:,1), ...
    man_SR(:,2), aut_SR(:,2), avg_SR(:,2), best_SR(:,2)];

% Print Table 9
fprintf('Table 9: Percentage of failure-revealing runs for each tool and for each value of p and assumption-requirement combination.\n\n')
fprintf(['\t|',repmat('\t',1,4),'R',repmat('\t',1,5),'|',repmat('\t',1,4),'R''\n'])
fprintf("\t|\t"+join(["ATheNA-SM","ATheNA-SA","ATheNA-Savg","ATheNA-Sbest"],"\t")+"\t|\t"+join(["ATheNA-SM","ATheNA-SA","ATheNA-Savg","ATheNA-Sbest"],"\t")+"\n")
fprintf([repmat('_',1,155),'\n'])
for ii = 1:length(reqList)
    stringTemp = string(resTemp(ii,:));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(reqList(ii)+"\t|\t"+join(stringTemp(1:4),"\t\t")+"\t\t|\t"+join(stringTemp(5:end),"\t\t")+"\n")
end
fprintf(repmat(newline,1,2))

% Save Table 9
nameTemp = 'Tables_Figures/table_9.csv';
fileID = fopen(nameTemp,'w+');
fprintf(fileID,","+"ATheNA_SM,ATheNA_SA,ATheNA_Savg,ATheNA_Sbest"+","+"ATheNA_SM,ATheNA_SA,ATheNA_Savg,ATheNA_Sbest"+"\n");
for ii = 1:length(reqList)
    stringTemp = string(resTemp(ii,:));
    stringTemp(ismissing(stringTemp)) = "NaN";
    fprintf(fileID,reqList(ii)+","+join(stringTemp,",")+"\n");
end
fclose(fileID);

% Delete temporary variables
clear('*Temp')

%% Print Table 10

% Table 10 is produced by the script 'printResultsRQ4.m'
