%% ATheNA Setup Script and Fitness Function Tutorial
%% Overview
% This tutorial provides a detailed example on how to set up a script that
% runs an ATheNA test using the athena function, as well as how to create
% and configure a manual fitness function for use with ATheNA. The model
% and script used in this tutorial is packaged with the toolbox and is
% located in this folder.
%% Script and Model Description 
% The Simulink model pendulum_model_2015a is a single pendulum tied to a
% string that has a repeated torque applied to it via a motor. The length
% of the string (len), mass of the object (m), gravitational acceleration
% (g), and the pendulum's torsional damping (c) can all be modified. The
% requirement, which is that the pendulum does not exceed a rotation beyond
% pi/3 radians in either direction, is being falsified using ATheNA. The
% motor's angular acceleration serves as the input to the model, and the
% angular displacement of the pendulum is the output. This script sets all
% the simulation parameters for a falsification test, along with the test
% settings using an athenaoptions object before running the test with the
% athena function. The model parameter variables g, m, len, and c must be
% defined by the user.
%
% NOTE: The model is saved as a Simulink version 7.14 (R2012a) model. If
% this model is not supported by your MATLAB version, save the model as a
% version compatible with your device.
%
%% ATheNA Toolbox Configuration Check
% Ensure that the ATheNA toolbox is setup correctly with the S-TaLiRo
% toolbox and that all MEX files for S-TaLiRo are compiled. For more
% information on how to configure S-TaLiRo with ATheNA, refer to the
% getting started documenation, which is accessible through the Manage
% Add-Ons options for the ATheNA toolbox. Define Model Parameters Define
% all the model parameter variables. Note that this may not be necessary
% for all models.
%% Define Model Parameters
% Note that this may not be necessary for all models and ATheNA tests.
len = 0.25;     % Length of the pendulum [m]
g = 9.81;       % Gravity acceleration [m/s^2]
m = 4;          % Pendulum mass [kg]
c = 0.0125;     % Pendulum torsional damping [kg*m^2/s]
%% Define Falsification Algorithm Parameters
% Define all the parameters required for a falsification test. These are
% the same parameters required for an S-TaLiRo falsification test with the
% staliro function, except the staliro_options object is replaced by an
% athena_options object. Refer to the next section for more information on
% how to configure the athena_options object. Note that all atomic
% predicates must be normalized and the normalization bounds must be
% defined. This is to ensure that the automatic and manual fitness values
% can be combines properly. The parameters are then passed to the athena
% function.
%
% For more information on the parameter requirements and function outputs,
% refer to the help function documentation by entering 'help athena' into
% the MATLAB Command Window.
%
% For more information on normalizing atomic predicates and setting
% normalization bounds, refer to the Combining Manual and Automatic Fitness
% Values section of the Getting Started documentation. Alternatively, refer
% to the help function documentation for the athena_options.coeffRob
% property by entering 'help athena_options.coeffRob' into the MATLAB
% Command Window.

model = 'pendulum_model_2015a'; % Model name

% Initial conditions (if left empty, the ones from the model will be
% considered)
init_cond = [];

% Input range for u = T/m/len^2
Torq = [-0.5, 0.5];         % Input range for the motor torque [N*m]
input_range = Torq/m/len^2; % Input range for the motor angular acceleration [rad/s^2]

% Number of control points for the input
cp_array = 10;

% Requirement: the pendulum remains between theta_min and theta_max [0,
% 10000] ===> Check the requirement between 0 and 10000 ms (a/\b) ===>
% Satisfy both requirements a and b (a et b)
phi='[]_[0,10000] (a/\b)';

theta_max = pi/3;
preds(1).str = 'a';         % Atomic predicate name
preds(1).A = [1];           % Output must be lower than 'a'
preds(1).b = theta_max;     % 'a' is equal to theta_max

% Normalize the predicate
preds(1).Normalized = true;
preds(1).NormBounds = pi;   % Set the normalization bounds value

theta_min = -pi/3;
preds(2).str = 'b';         % Atomic predicate name
preds(2).A = [-1];          % Output must be higher than 'b'
preds(2).b = -theta_min;    % 'b' is equal to -theta_min

% Normalize the predicate
preds(2).Normalized = true;
preds(2).NormBounds = pi;   % Set the normalization bounds value

% Total simulation time
TotSimTime = 10;               % Total simulation time [s]
%% Define ATheNA Run Options
% Define the run options using an athena_options object, which inherits
% from the staliro_options class. For more information on the class
% properties of athena_options, refer to and navigate the help function
% documentation by entering 'help athena_options' into the MATLAB Command
% Window.

athena_opt = athena_options; % Initialize the options object

% Set the interpolation type for each input port (inherited staliro_options
% property)
athena_opt.interpolationtype = {'pchip'};

% Accept zero robustness as falsification? [Y/N] (inherited staliro_options
% property)
athena_opt.fals_at_zero = 0;

% Set parameters for optimization algorithm (inherited staliro_options
% property)
athena_opt.optim_params.n_tests = 70;

% Set the coefficient of robustness for combining the automatic and manual
% fitnesses into the ATheNA fitness.
athena_opt.coeffRob = 0.67;

% Provide the manual fitness function. The function must exist in the path.
% For more information on how to create a manual fitness function, refer to
% the help function documentation by entering 'help createManualFitness'
% into the MATLAB Command Window. Refer to the documentation for the
% athena_options.fitnessFcn property through the athena_options help
% function for examples on how to assign values for the fitness function.
athena_opt.fitnessFcn = @pendulumFitness;

% Determines whether interpolated input should be given to the manual
% fitness function. By default, this property is set to true.
athena_opt.useInterpInput = true;

% Sets the figure number to use for plot outputs, if Nfig is >= 1. If Nfig
% is 0, then a waitbar is shown instead, and if Nfig is negative, then no
% windowed output is produced. Figures are cleared after each run.
athena_opt.Nfig = 1;

% Sets the number of runs to conduct. Minimum 1.
athena_opt.athena_runs = 3;

% Change the label interpreter used for plot labels. Check property
% documentation for athena_options.LabelInterpreter for more information on
% the default value and supported options. Default value is 'tex'.
athena_opt.LabelInterpreter = 'latex';

% Create labels for the input plots as a 1 x n string cell array, where n
% is the number of input ports. The ith label is used for the ith input
% port. The string labels must formatted according to the interpreter used
% by the athena_options.LabelInterpreter property.
athena_opt.InputLabels = {"$Motor~Angular~Acceleration~[\frac{rad}{s^{2}}]$"};

% Create labels for the output plots as a 1 x n string cell array, where n
% is the number of output ports. The ith label is used for the ith output
% port. The string labels must formatted according to the interpreter used
% by the athena_options.LabelInterpreter property.
athena_opt.OutputLabels = {"$Pendulum~Displacement~[rad]$"};

% Creates a summary of the runs to display at the end of all runs. If a
% save file name is provided and this property is set to true, then the
% data created in the summary is also saved in the file.
athena_opt.RunSummary = true;
%% Running the Test
% Call the athena function to begin the falsification test. The function
% output can then be used for analysis.
[res, his, options] = athena(model,init_cond,input_range,cp_array,phi,preds,TotSimTime,athena_opt);
%% ATheNA Manual Fitness Function Tutorial
% The following function calculates the manual fitness value for the
% falsification of the pendulum_model_2016a, and is used in the ATheNA test
% above. Note that the global variables invoked by the function may not be
% necessary in all fitness functions, but the function must take 3 input
% arguments, even if they are not used. For more information on creating
% and assigning manual fitness functions, refer to the Getting Started
% documentation or use the help function documentation by entering 'help
% createManualFitness' into the MATLAB Command Window.

function fitness = pendulumFitness(t,u,y)
%PENDULUMFITNESS Calculates the manual fitness function for ATheNA.
%   This function generates the manual fitness by suggesting the maximum
%   torque in the positive direction if the angle is >= 0 rad, or the
%   maximum torque in the opposite direction if the angle is < 0 rad,
%   relative to rest position of the pendulum.

global staliro_InputBounds;

if mean(y) >= 0
    min_torque = (min(u) - staliro_InputBounds(1)) / (staliro_InputBounds(2) - staliro_InputBounds(1));
    fitness = 1 - min_torque;
else
    max_torque = (max(u) - staliro_InputBounds(1)) / (staliro_InputBounds(2) - staliro_InputBounds(1));
    fitness = max_torque;
end
end
