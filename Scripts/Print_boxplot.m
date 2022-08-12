clearvars
close all
clc

%% Get file names containing Athena
FileName = dir('Results');
FileName = {FileName.name};
idx = contains(FileName,'Athena','IgnoreCase',false);
FileName = FileName(idx);

%% Load file
n_runs = 50;                                    % Number of runs with each algorithm per file
Data = cell(length(FileName),1);                % Raw data from files
Res_STa = cell(n_runs*length(FileName),1);      % Results with S-Taliro
Res_AThM = cell(n_runs*length(FileName),1);     % Results with ATheNA-SM
Res_ATh = cell(n_runs*length(FileName),1);      % Results with ATheNA-S

for ii = 1:length(FileName)
    Data{ii} = load(['Results/',FileName{ii}],'Results');

    Res_STa(n_runs*(ii-1)+1:n_runs*ii) = Data{ii}.Results(1:n_runs);
    Res_AThM(n_runs*(ii-1)+1:n_runs*ii) = Data{ii}.Results(n_runs+1:2*n_runs);
    Res_ATh(n_runs*(ii-1)+1:n_runs*ii) = Data{ii}.Results(2*n_runs+1:3*n_runs);
end

%% Get number of iterations
N_iter_STa = zeros(size(Res_STa));
N_iter_AThM = zeros(size(Res_AThM));
N_iter_ATh = zeros(size(Res_ATh));

Fals_STa = false(size(Res_STa));
Fals_AThM = false(size(Res_AThM));
Fals_ATh = false(size(Res_ATh));

for ii = 1:length(Res_STa)
    N_iter_STa(ii) = Res_STa{ii}.run.nTests;
    N_iter_AThM(ii) = Res_AThM{ii}.run.nTests;
    N_iter_ATh(ii) = Res_ATh{ii}.run.nTests;

    Fals_STa(ii) = Res_STa{ii}.run.bestRob<=0;
    Fals_AThM(ii) = Res_AThM{ii}.run.bestRob<=0;
    Fals_ATh(ii) = Res_ATh{ii}.run.bestRob<=0;
end

% Remove all the runs that reached the maximum number of iterations
N_iter_STa = N_iter_STa(Fals_STa);
N_iter_AThM = N_iter_AThM(Fals_AThM);
N_iter_ATh = N_iter_ATh(Fals_ATh);

%% Plot boxplot

% Group vector
Group = [zeros(size(N_iter_STa)); ones(size(N_iter_AThM)); 2*ones(size(N_iter_ATh))];
N_iter = [N_iter_STa; N_iter_AThM; N_iter_ATh];
Avg_iter = [mean(N_iter_STa), mean(N_iter_AThM), mean(N_iter_ATh)];

figure(1)
hold on
grid on
boxplot(N_iter,Group,'labels',{'$S-Taliro$','$ATheNA-SM$','$ATheNA-S$'})
plot(Avg_iter,'gd')
set(gca,'FontSize',24,'TickLabelInterpreter','latex')
ylabel('$\#~Iterations$','Interpreter','latex','FontSize',24)
xlim([0.5,3.5])
ylim([-10, 310])
saveas(gcf,'BoxPlot.eps','eps')