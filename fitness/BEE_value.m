function [fitness, ind, cur_par, rob, otherData] = BEE_value(inputModel, input, auxData)

%% Temporary function for roBustnEss tEsting

%% Load S-Taliro parameters
% Read-only staliro parameters
global staliro_SimulationTime;
global staliro_InputBounds;
global temp_ControlPoints;
global staliro_dimX;
global staliro_opt;

otherData = struct('timeStats',[]);
otherData.timeStats = struct('simTimes',[],'robTimes',[]);

% Read-only fitness parameters
global BEE_param;

% Set ind to 1 if no problem was detected
ind = 1;

% Check if parameter estimation has to be performed
cur_par = [];
if staliro_opt.parameterEstimation > 0
    fitness = NaN;
    rob = NaN;
    warning('This feature has not been implemented yet. Fitness set to NaN')
    return
end

if nargin == 3
    % Use the input and output computed by Compute_Robustness_Right.m
    t = auxData.t;
    U = auxData.U;
    y = auxData.y;

else
    %% Extract input of the system
    % The input vector is formed by the initial conditions of the states and
    % the value of the system input in the control point:
    % input = [x0, u]
    x0 = input(1:staliro_dimX);
    U = input(staliro_dimX+1:end);

    %% Evaluate output of the system
    % Symulate system response to a given input
    if staliro_opt.TimeStatsCollect
        ctime_sim = tic;
    end
    
    [hs, rc] = systemsimulator(inputModel, x0, U, staliro_SimulationTime, staliro_InputBounds, temp_ControlPoints);
    
    if staliro_opt.TimeStatsCollect
        otherData.timeStats.simTimes = toc(ctime_sim);
    end
    
    % Check if simulation was run correctly
    Rcmap = rcmap.instance();
    if rc == Rcmap.int('RC_SIMULATION_FAILED')
        fitness = NaN;
        rob = NaN;
        warning('Simulation failed - results are unreliable, robustness set to NaN');
        return
    end
    
    % Define output from simulation results
    % t = number of timesteps x 1
    t = hs.T;
    
    % y = number of timesteps x number of output signals
    XT = hs.XT;
    YT = hs.YT;
    if ~isempty(YT)
        y = hs.YT;
    elseif ~isempty(XT)
        y = hs.XT;
    else
        err_msg = sprintf('S-Taliro: The selected specification space (spec_space) is not supported or the signal space is empty.\n If you are using a "white box" m-function as a model, then you must set the "spec_space" to "X".');
        error(err_msg);
    end
end

%% Interpolate the input, so that it is evaluated at the same timestamps as the output
% u = number of timesteps x number of input signals
u = ComputeInputSignals(t, U, staliro_opt.interpolationtype, temp_ControlPoints, staliro_InputBounds, staliro_SimulationTime, staliro_opt.varying_cp_times);

%% Final fitness function

if contains(lower(BEE_param.fitnessFcn), 'custom', 'IgnoreCase',true)
    fitness = feval(BEE_param.fitnessFcn, t, U, y);
else
    fitness = feval(BEE_param.fitnessFcn, t, u, y);
end

% Variables for parameters estimation (to be implemented)
rob = fitness;

%% Plot the generated input and output

if BEE_param.Nfig > 0
    % Plot input
    figure(BEE_param.Nfig)
    clf
    cp_cumsum = [0, temp_ControlPoints];
    cp_array = diff(cp_cumsum);
    
    for ii = 1:length(temp_ControlPoints)
        n = linspace(t(1),t(end),cp_array(ii));
        subplot(length(temp_ControlPoints),1,ii)
        hold on
        grid on
        plot(t,u(:,ii))
        plot(n,U(cp_cumsum(ii)+1:cp_cumsum(ii+1)),'Marker','*','LineStyle','none')
        drawnow
    end
    
    % Plot output
    figure(BEE_param.Nfig+1)
    clf
    for ii = 1:size(y,2)
        subplot(size(y,2),1,ii)
        hold on
        grid on
        plot(t,y(:,ii))
        drawnow
    end
end

end