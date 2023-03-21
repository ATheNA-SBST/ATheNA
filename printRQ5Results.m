clearvars
clearvars -global
clc
close all

addpath('Models/MV')
addpath('Models/HEV')
addpath(genpath('Athena/staliro'))

%% A.1 - Load sample for Hybrid Electric Vehicle (HEV)
SettingHEV;
Result_Temp = load('Results/RQ5/Athena_HEV_origRange_p_50_06-May-2022.mat','resultsathens');
Result_Temp = Result_Temp.resultsathens;
Result_Sample = Result_Temp.run.bestSample;

% Write number of iterations and time required to falsify.
fprintf('The chosen run does ')
if ~Result_Temp.run.falsified
    fprintf('not ')
end
fprintf('finds a failure in the Hybrid Electric Vehicle model.\n')
fprintf('ATheNA run for %i iterations or %.0f seconds (~ %.1f min).\n\n',Result_Temp.run.nTests, Result_Temp.run.time, Result_Temp.run.time/60)

% Delete temporary variables
clear('*Temp')

%% A.2 - Build input signal for HEV

t = (0:staliro_opt.SampTime:staliro_SimulationTime)';
input_signal = zeros(length(t),length(cp_array));
cp_array_Temp = [0, cp_array];

for ii = 1:length(cp_array)
    TU = linspace(0,staliro_SimulationTime,cp_array(ii));
    U_temp = feval(staliro_opt.interpolationtype{ii},TU,Result_Sample(cp_array_Temp(ii)+1:cp_array_Temp(ii+1)),t);
    input_signal(:,ii) = U_temp;
end

% Plot input signal
figure(1)
clf
for ii = 1:length(cp_array)
    subplot(length(cp_array),1,ii)
    hold on
    grid on
    plot(t,input_signal(:,ii),'k','LineWidth',2)
    if ii == 1
        TU = linspace(0,staliro_SimulationTime,cp_array(ii));
        plot(TU, Result_Sample,'k*','MarkerSize',10)
    end
    xlim([0 30])
    ylim(input_data.range(ii,:))
    xlabel('$Time~[s]$','FontSize',16,'Interpreter','latex')
    ylabel(input_data.name{ii},'FontSize',16,'Interpreter','latex')
end
set(gcf,'Units','normalized','Position',[0.1,0.1,0.22,0.165])
saveas(gcf,'Tables_Figures/InputHEV.eps','eps')

% Delete temporary variables
clear('*Temp')

%% A.3 - Compute output signal for HEV

simopt = simget('HEV_SeriesParallel');
[T, ~, YT] = sim(model,[0 staliro_SimulationTime],simopt,[t input_signal]);

%% A.4 - Plot output signal for MV

figure(2)
clf
for ii = 1:size(YT,2)
    subplot(size(YT,2),1,ii)
    hold on
    grid on
    plot(T,YT(:,ii),'k','LineWidth',2)
    xlim([0 30])
    ylim(output_data.range(ii,:))
    xlabel('$Time~[s]$','FontSize',16,'Interpreter','latex')
    ylabel(output_data.name{ii},'FontSize',16,'Interpreter','latex')
end
set(gcf,'Units','normalized','Position',[0.5,0.1,0.22,0.165])
saveas(gcf,'Tables_Figures/OutputHEV.eps','eps')

% Close project
global projID;
save_system(model);
close_system(model);
close(projID);

% Delete temporary variables
clear('*Temp')

%% B.1 - Load sample for Mechanical Ventilator (MV)

SettingMV;
Result_Temp = load('Results/RQ5/Athena_MV1_origRange_p_50_06-Mar-2023.mat','Results');
Result_Temp = Result_Temp.Results;
Result_Temp = Result_Temp{1};
Result_Sample = Result_Temp.run.bestSample;

% Write number of iterations and time required to falsify.
fprintf('The chosen run does ')
if ~Result_Temp.run.falsified
    fprintf('not ')
end
fprintf('finds a failure in the Mechanical Ventilator model.\n')
fprintf('ATheNA run for %i iterations or %.0f seconds (~ %.1f min).\n',Result_Temp.run.nTests, Result_Temp.run.time, Result_Temp.run.time/60)

%% B.2 - Build input signal for MV

t = (0:staliro_opt.SampTime:staliro_SimulationTime)';
input_signal = zeros(length(t),length(cp_array));

input_signal(t < staliro_SimulationTime/2,1) = Result_Sample(1);
input_signal(t >= staliro_SimulationTime/2,1) = Result_Sample(2);
input_signal(:,2) = Result_Sample(3);
input_signal(:,3) = Result_Sample(4);

% Plot input signal
figure(3)
clf
for ii = 1:length(cp_array)
    subplot(length(cp_array),1,ii)
    hold on
    grid on
    plot(t,input_signal(:,ii),'k','LineWidth',2)
    if ii == 1
        plot([0, staliro_SimulationTime/2], [Result_Sample(1), Result_Sample(2)],'k*','MarkerSize',10)
    end
    xlim([0 staliro_SimulationTime])
    ylim(input_data.range(ii,:))
    xlabel('$Time~[s]$','FontSize',16,'Interpreter','latex')
    ylabel(input_data.name{ii},'FontSize',16,'Interpreter','latex')
end
set(gcf,'Units','normalized','Position',[0.1,0.1,0.3,0.5])
saveas(gcf,'Tables_Figures/InputMV.eps','eps')

%% B.3 - Compute output signal for MV

[T, ~, YT, ~, ~, ~] = feval(model,[],staliro_SimulationTime,t,input_signal);

% Display maximum pressure
maxP = max(YT(:,1));
time_maxP = T(YT(:,1) == maxP);
fprintf('The Mechanical Ventilator reaches the maximum pressure of %.1f cmH2O at time %.1f s.\n\n',maxP,time_maxP);

%% B.4 - Plot outpu signal for MV

figure(4)
clf
for ii = 1:size(YT,2)
    subplot(size(YT,2),1,ii)
    hold on
    grid on
    plot(T,YT(:,ii),'k','LineWidth',2)
    xlim([0 staliro_SimulationTime])
    ylim(output_data.range(ii,:))
    xlabel('$Time~[s]$','FontSize',16,'Interpreter','latex')
    ylabel(output_data.name{ii},'FontSize',16,'Interpreter','latex')
end
set(gcf,'Units','normalized','Position',[0.5,0.1,0.3,0.5])
saveas(gcf,'Tables_Figures/OutputMV.eps','eps')
