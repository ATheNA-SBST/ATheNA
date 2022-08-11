function [fitness, otherData] = AthenaManFit(inputModel, input, auxData)
%% Compute the manual fitness for a set of inputs and outputs.
%
%   [fitness, otherData] = AthenaManFit(inputModel, input, auxData)
%
% This function compute the manual fitness for a given model and input
% values. The name of the function used to define the manual fitness
% function is specified in 'staliro_opt.fitnessFcn'.
%
% Input:
%       - inputModel: function handle or name of the Simulink model.
%       - input: array containing the initial conditions and value of the
%       input signals in the control points.
%       - auxData: struct file containing the time array and complete input
%       and output signals of the system. If it is not provided, the
%       function will compute them from the values contained in 'input';
%       otherwise, it will use the one contained in this function.
%
% Output:
%       - fitness: value of the manual fitness function for the given sets
%       of input and output signals.
%       - otherData: struct variable containing the time required to run a
%       full simulation of the system.

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
global staliro_opt;

% Check if parameter estimation has to be performed
if staliro_opt.parameterEstimation > 0
    fitness = NaN;
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
if staliro_opt.useInterpInput || staliro_opt.Nfig > 0
    u = ComputeInputSignals(t, U, staliro_opt.interpolationtype, temp_ControlPoints, staliro_InputBounds, staliro_SimulationTime, staliro_opt.varying_cp_times);
end
%% Final fitness function

if ~staliro_opt.useInterpInput
    fitness = feval(staliro_opt.fitnessFcn, t, U, y);
else
    fitness = feval(staliro_opt.fitnessFcn, t, u, y);
end

%% Plot the generated input and output

if staliro_opt.Nfig > 0
    % Plot input
    figure(staliro_opt.Nfig)
    cp_cumsum = [0, temp_ControlPoints];
    cp_array = diff(cp_cumsum);
    
    for ii = 1:length(temp_ControlPoints)
        n = linspace(t(1),t(end),cp_array(ii));
        subplot(length(temp_ControlPoints),1,ii)
        hold on
        grid on
        plot(t,u(:,ii))
        plot(n,U(cp_cumsum(ii)+1:cp_cumsum(ii+1)),'Marker','*','LineStyle','none')
        xlim([t(1),t(end)])
        ylim(staliro_InputBounds(ii,:))
        drawnow
    end
    
    % Plot output
    figure(staliro_opt.Nfig+1)
    for ii = 1:size(y,2)
        subplot(size(y,2),1,ii)
        hold on
        grid on
        plot(t,y(:,ii))
        xlim([t(1),t(end)])
        drawnow
    end

end

end