%% ATheNA Setup Script and Fitness Function Tutorial
%% Overview
% This tutorial provides a detailed example on how to run ATheNA test using
% both the manual and automatic fitness functions. It shows how to define a
% customised manual fitness function tailored to the simulation scenario.
%
% The model used in this tutorial is derived from the one presented in the
% following paper:
% Xiaoqing Jin, Jyotirmoy V. Deshmukh, James Kapinski, Koichi Ueda, and Ken
% Butts. Powertrain control verification benchmark. In International
% Conference on Hybrid Systems: Computation and Control, pages 253–262.
% ACM, 2014.

%% Script and Model Description 
% The Simulink model AFC_model_2016a is a controller for the Air-to-Fuel
% ratio in an Internal Combustion engine. The user sets the engine speed
% and the throttle, and the controller must produce at all times an
% Air-to-Fuel ratio that matches the reference value.
% The requirement states that the Air-to-Fuel error must be below 0.007 at
% all times between 11s and 50s from the start of the simulation.
% 
% Athena is used to produce a failure-revealing test case, i.e. a set of
% input signals (engine speed and throttle) that produce a requirement
% violation.
% This script sets all the simulation parameters for the model,
% defines the test settings, and runs the Athena function.
%
% NOTE: The model is saved as a Simulink version 8.7 (R2016a) model. If
% this model is not supported by your MATLAB version, save the model as a
% version compatible with your device.

%% ATheNA Toolbox Configuration Check
% Ensure that the ATheNA toolbox is setup correctly with the S-TaLiRo
% toolbox and that all MEX files for S-TaLiRo are compiled. For more
% information on how to configure S-TaLiRo with ATheNA, refer to the
% README.md.
addpath(genpath('src'))
addpath(genpath('staliro'))
warning('off','Simulink:Logging:CannotLogStatesAsMatrix')

%% Define Requirement
% The requirement is defined by two variables: a char array that contains
% the Boolean expression with the temporal operators, and a struct array
% containing information on the Atomic predicates.
% For more information on the syntax of these two variables, please refer
% to the documentation in ./staliro/dp_taliro/dp_taliro.m.

% The requirement is defined by a char array. This array contains all the
% temporal and boolean operators needed to express the requirement. Each
% atomic predicate is replaced by a unique name.
% In this case the requirement states: At all times ([] is the Globally or
% Always temporal operator) between 11s and 50s, the atomic predicates
% 'upperlimit' and 'lowerlimit' must be true (/\ is the AND operator).
phi = '[]_[11,50](lowerthres /\ upperthres)';

% The atomic predicates must now be defined in a separate variable.
% The atomic predicates are expressed in the form:
%           A * outputs <= b
% For each atomic predicate, we must specify their name, the array A and
% the threshold value b. The order of the output signals is the same as the
% outports in the model.
% To increase peformances, it is advised to normalize all the atomic
% predicates, as this ensures that the value of the automatic fitness is
% always between -1 and 1. In this specific case, we use 0.015 as the
% normalization bounds, which is approximatively equal to the width of the
% acceptable range of u: [-0.007, 0.007].
preds(1).str = 'upperthres';   % u <= 0.007
preds(1).A = [1 0 0];
preds(1).b = 0.007;
preds(1).Normalized = 1;
preds(1).NormBounds = 0.015;

preds(2).str = 'lowerthres';   % u >= -0.007
preds(2).A = [-1 0 0];
preds(2).b = 0.007;
preds(2).Normalized = 1;
preds(2).NormBounds = 0.015;

%% Define input assumption
% Each input signal is defined by a tuple containing:
%   * Number of control points (i.e., number of interpolation nodes)
%   * Signal range
%   * Interpolation function
%
% The input signals are modeled by assigning a value inside the range to
% each control point and then interpolate the points with the appropriate
% function. The control points can be equally spaced in time or be assigned
% at specific time instants.
% In this specific case, we have two input signals: engine speed and
% throttle pedal.
% The engine speed is modeled as a constant signal ('const').
% The throttle pedal is modeled as a piecewise constant ('pconst') signal
% with 10 steps (one each 5s).

% Define the number of control points/interpolation nodes.
controlPoints = [1, 10];

% Define the range for each signal (each row contains the Lower and Upper
% bound respectively).
inputRange = [900  1100; 0 61.2];

% Define the interpolation function for each signal
interpFunc = {'const', 'pconst'};

%% Define other model information

% Define the Simulink model name
model = 'AFC_model_2016a';

% Define the initial conditions. This variable allow to assign a range for
% the initial conditions of the model (same format as inputRange). If left
% empty, the initial conditions defined in the model will be used.
initCond = [];

% Define the simulation time (in seconds).
simTime = 50;

% The Simulink model relies on the following parameters defined in Matlab.
assignin('base','simTime',simTime)
assignin('base','en_speed',1000)
assignin('base','measureTime',1)
assignin('base','spec_num',1)
assignin('base','fuel_inj_tol',1)
assignin('base','MAF_sensor_tol',1)
assignin('base','AF_sensor_tol',1)
assignin('base','sim_time',50)
assignin('base','fault_time',60)

%% Define ATheNA Options
% Athena is controlled by an athena_options object. This variable allows
% the user to specify all the relevant information for the algorithm, such
% as how many interations to test before stopping or whether an automatic
% fitness equal to 0 represents a failure-revealing test case or not.
% For more information on the class properties of athena_options, please
% refer to the documentation in ./src/athena_options.m or
% ./staliro/staliro_options.m.

% Initialize the options object
athenaOpt = athena_options;

% Set the interpolation function for each input signal.
athenaOpt.interpolationtype = interpFunc;

% Accept zero robustness as falsification? 1 is Yes, 0 is No
athenaOpt.fals_at_zero = 0;

% Set maximum number of tests to conduct for each run.
athenaOpt.optim_params.n_tests = 50;

% Set the coefficient of robustness for combining the automatic and manual
% fitnesses into the ATheNA fitness.
athenaOpt.coeffRob = 0.5;

% Provide the manual fitness function. The function must exist in the path.
% For more information on how to create a manual fitness function, refer to
% the help function documentation by entering 'help createManualFitness'
% into the MATLAB Command Window. Refer to the documentation for the
% athena_options.fitnessFcn property through the athena_options help
% function for examples on how to assign values for the fitness function.
athenaOpt.fitnessFcn = @fitnessAFC;

% Determines whether interpolated input should be given to the manual
% fitness function. By default, this property is set to true.
athenaOpt.useInterpInput = true;

% Sets the figure number to use for plot outputs, if Nfig is >= 1. If Nfig
% is 0, then a waitbar is produced instead showing the progress over the
% total number of runs. If Nfig is negative, then no windowed output is
% produced. Figures are cleared after each run.
athenaOpt.Nfig = 1;

% Sets the number of runs to conduct. Minimum 1.
athenaOpt.athena_runs = 1;

% Change the label interpreter used for plot labels. Check property
% documentation for athena_options.LabelInterpreter for more information on
% the default value and supported options. Default value is 'tex'.
athenaOpt.LabelInterpreter = 'latex';

% Create labels for the input plots as a 1 x n string cell array, where n
% is the number of input ports. The ith label is used for the ith input
% port. The string labels must formatted according to the interpreter used
% by the athena_options.LabelInterpreter property.
athenaOpt.InputLabels = {'$Engine~Speed~[rpm]$','$Throttle~angle~[deg]$'};

% Create labels for the output plots as a 1 x n string cell array, where n
% is the number of output ports. The ith label is used for the ith output
% port. The string labels must formatted according to the interpreter used
% by the athena_options.LabelInterpreter property.
athenaOpt.OutputLabels = {'$AtoF~Error~[/]$','$Controller~Mode~[/]$','$Throttle~angle~[deg]$'};

% Creates a summary of the runs to display at the end of all runs. If a
% save file name is provided and this property is set to true, then the
% data created in the summary is also saved in the file.
athenaOpt.RunSummary = true;

%% Running the Test
% Call the athena function to begin the falsification test. The function
% output can then be used for analysis.
[res, his, options] = athena(model,initCond,inputRange,controlPoints,phi,preds,simTime,athenaOpt);

%% ATheNA Manual Fitness Function Tutorial
% The following function calculates the manual fitness value for the
% falsification of the AFC_model_2016a, and is used in the ATheNA test
% above. The function must take 3 input arguments (time t, input signals u
% and output signals y), even if they are not used, and return a single
% scalar value. It is possible to use global variables to provide extra
% information to the function.
% For more information on creating and assigning manual fitness functions,
% refer to the documentation in ./src/fitness/createManualFitness.m or
% enter 'help createManualFitness' into the MATLAB Command Window.

function fitness = fitnessAFC(t, u, y)
    % fitnessAFC: Calculates the manual fitness function for ATheNA.
    %   This function generates the manual fitness by prioritizing test
    %   cases with low throttle values between 10s and 50s. The value is
    %   scaled with the throttle range to produce a value between 0 and 1.
    
    global staliro_InputBounds;
    fitness = (min(u(t > 10,2))-staliro_InputBounds(2,1))/(staliro_InputBounds(2,2)-staliro_InputBounds(2,1));

end

