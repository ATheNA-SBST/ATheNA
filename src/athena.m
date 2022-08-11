% ATheNA-S
%
% AuTomatic and maNuAl fitness: Runs a test using Simulated Annealing
% optimization with both automatic fitness from S-Taliro and user-defined
% manual fitness. To learn more about creating the manual fitness function,
% type 'help createManualFitness'.
%
% Usage:
%
% [Results, History, Opt] =
% athena(model,init_cond,input_range,cp_array,phi,preds,TotSimTime,athena_opt)
%
% DESCRIPTION :
%
%   ATheNA-S performs temporal logic falsification for hybrid systems
%   models through a combination of automatically generated and manually
%   defined fitness functions. The input model can be in several forms,
%   such as a Simulink model or an m-function. The specification must be a
%   Signal Temporal Logic (STL) formula which is encoded using a Metric
%   Temporal Logic (MTL) formula. The manual fitness function must be
%   provided by the user as a m-function.
%
% INPUTS :
%
%   - model : can be of type:
%
%       * function handle : 
%         It represents a pointer to a function which will be numerically 
%         integrated using an ode solver (the default solver is ode45). 
%         The solver can be changed through the option
%                   athena_options.ode_solver
%         See documentation: <a href="matlab: doc athena_options.ode_solver">athena_options.ode_solver</a>
%
%       * Blackbox class object : 
%         The user provides a function which returns the system behavior 
%         based on given inputs and initial conditions. For example, this 
%         option can be used when the system simulator is external to 
%         Matlab. Please refer tp the staliro_blackbox help file.
%         See documentation: <a href="matlab: doc staliro_blackbox">staliro_blackbox</a>
%
%       * string : 
%         It should be the name of the Simulink model to be simulated.
%
%       * hautomaton :
%         A hybrid automaton of the class hautomaton.
%         See documentation: <a href="matlab: doc hautomaton">hautomaton</a>
%
%       * ss or dss :
%         A (descriptor) state-space model (see help file of ss or dss).
%         If the ss or dss models are discrete time models, then the 
%         sampling time should match the sampling time for the input 
%         signals (see athena_options.SampTime). If they are not the same,
%         then an error will be issued.
%         See documentation: <a href="matlab: doc ss">ss</a>, <a href="matlab: doc dss">dss</a>, <a href="matlab: doc athena_options.SampTime">athena_options.SampTime</a>
%
%       Examples: 
%
%           % Providing directly a function that depends on state and time
%           model = @(t,x) [x(1) - x(2) + 0.1*t; ...
%                   x(2) * cos(2*pi*x(2)) - x(1)*sin(2*pi*x(1)) + 0.1 * t];
%
%           % Just an empty Blackbox object
%           model = staliro_blackbox; 
%           
%           % For other blackbox examples see the demos in demos folder:
%           staliro_demo_sa_simpleODE_param.m
%           staliro_demo_autotrans_02.m
%           staliro_demo_autotrans_03.m
% 
%           % Simulink model under demos\SystemModelsAndData
%           model = 'SimpleODEwithInp'; 
%
%           % Hybrid automaton example (demo staliro_navbench_demo.m)
%           model = navbench_hautomaton(1,init,A);
%
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions (or more generally, constant parameters) and it should be a 
%       Matlab n x 2 array, where 
%			n is the size of the vector of initial conditions.
%		In the case of a Simulink model or a Blackbox model:
%			The array can be empty indicating no search over initial conditions 
%			or constant parameters. For Simulink models in particular, an empty 
%			array for initial conditions implies that the initial conditions in
%			the Simulink model will be used. 
%
%       Format: [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_n UpperBound_n];
%
%       Examples: 
%        % A set of initial conditions for a 3D system
%        init_cond = [3 6; 7 8; 9 12]; 
%        % An empty set in case the initial conditions in the model should be 
%        % used
%        init_cond = [];
%
%       Additional constraints on the initial condition search space can be defined 
%       using the staliro option <a href="matlab: doc athena_options.search_space_constrained">athena_options.search_space_constrained</a>. 
%       For example, you can define convex polyhedral search spaces.
%
%   - input_range : 
%       The constraints for the parameterization of the input signal space.
%       The following options are supported:
%
%          * an empty array : no input signals.
%              % Example when no input signals are present
%              input_range = [];
%
%          * a hyper-rectangle that holds the range of possible values for 
%            the input signals. This is a Matlab m x 2 array, where m is the  
%            number of inputs to the model. Format:
%               [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_m UpperBound_m];
%            Examples: 
%              % Example for two input signals (for example for a Simulink model 
%              % with two input ports)
%              input_range = [5.6 7.8; 8 12]; 
%
%          * a cell vector. This is a more advanced option. Each input signal is 
%            parameterized using a number of parameters. Each parameter can 
%            range within a specific interval. The cell vector contains the
%            ranges of the parameters for each input signal. That is,
%                { [p_11_min p_11_max; ...; p_1n1_min p_1n1_max];
%                                    ...
%                  [p_m1_min p_m1_max; ...; p_1nm_min p_1nm_max]}
%            where m is the number of input signals and n1 ... nm is the number
%                  of parameters (control points) for each input signal.
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%
%       Additional constraints on the input signal search space can be defined 
%       using the staliro option <a href="matlab: doc athena_options.search_space_constrained">athena_options.search_space_constrained</a>. 
%       For example, you can define convex polyhedral search spaces.
%
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%
%   - cp_array : contains the control points that parameterize each input 
%       signal. It should be a vector (1 x m array) and its length must be equal 
%       to the number of inputs to the system. Each element in the vector 
%       indicates how many control points each signal will have. 
%
%       Specific cases:
%
%       * If the signals generated using interpolation between the control  
%         points, e.g., piece-wise linear or splines (for more options see 
%         <a href="matlab: doc athena_options.interpolationtype">athena_options.interpolationtype</a>): 
%		  
%         Initially, the control points are equally distributed over 
%         the time duration of the simulation. The time coordinate of the 
%         control points will remain constant unless the option
%
%					<a href="matlab: doc athena_options.varying_cp_times">athena_options.varying_cp_times</a>
%
%         is set (see the athena_options help file for further instructions and 
%         restrictions). The time coordinate of the first and last control 
%         points always remains fixed.
%
%         Example: 
%           cp_array = [1];
%               indicates 1 control point for only 1 input signal to the model.
%               One control point can only be used with piecewise constant 
%               signals. If we assume that the total simulation time is 6 time 
%               units and the input range is [0 2], then the input signal will 
%               be:
%                  for all time t in [0,6] u(t) = const with const in [0,2] 						
%
%           cp_array = [4];
%               indicates 4 control points for only 1 input signal to the model.
%               If we assume that the total simulation time is 6 time units, 
%               then the initial distribution of the control points will be:
%                            0   2   4   6
%
%           cp_array = [10 14];
%               indicates 10 control points for the 1st input signal and 
%               14 for the second input.
%
%      * If the input_range is a cell vector, then the input range for each
%        control point variable is explicitly set. Therefore, we can
%        extract the number of control points from the number of
%        constraints. In this case, the cp_array should be set to emptyset.
%
%           cp_array = [];
%
%   - phi : The formula to falsify. It should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" (or see athena_options.taliro for other
%       supported options depending on the temporal logic robustness toolbox 
%       that you will be using).
%                               
%           Example: 
%               phi = '!<>_[3.5,4.0] b)'
%
%       Note 1: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%       Note 2: A cell vector of multiple requirements may be provided in
%       case the optimizer supports it.
%
%           Example:
%               phi = {'!<>_[3.5,4.0] b)', 'a U_[0,5] b'}
%
%   - preds : contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help dp_taliro" (or see 
%       athena_options.taliro for other supported options depending on the 
%       temporal logic robustness toolbox that you will be using).
%
%   - TotSimTime : total simulation time.
%
%   - athena_opt : athena options. athena_opt should be of type
%   "athena_options".
%       For instructions on how to change athena options, see the
%       athena_options help file for each desired property.
%
% OUTPUTS :
%   - Results: a cell array of size {athena_opt.athena_runs,1} with
%   structures containing the following fields:
%
%       * run: a structure array that contains the results of each run of 
%           the stochastic optimization algorithm. The structure has the
%           following fields:
%               bestRob : The automatic fitness value of the sample with
%               the best ATheNA fitness.
%               bestFit: The manual fitness value of the sample with the
%               best ATheNA fitness.
%               bestSample : The sample in the search space that generated 
%                   the trace with the best ATheNA fitness. 
%               nTests: number of tests performed (this is needed if 
%                   falsification rather than optimization is performed. See 
%					athena_options.falsification for more information).
%               bestCost: Best ATheNA fitness value found.
%               paramVal: Best parameter value. This is used only in 
%                   parameter mining or query problems, so this field is
%                   irrelevant.
%					Important: This value is ignored.
%               falsified: Indicates whether a falsification occurred. This
%                   is used if a stochastic optimization algorithm does not
%                   return the minimum robustness value found.
%               time: (default) The total running time of each run.
%                   If the the option TimeStatsCollect in athena_options 
%                   is set to 1 or true, then time is a structure with fields:
%                       totTime         : the total run time for each run
%                       simTime         : the total model simulation or SUT 
%                                         execution time
%                       ratioSimTime    : the ratio of simTime over total 
%                                         falsification time
%                       robTime         : the total robustness computation time
%                       ratioRobTime    : the ratio of robTime over total 
%                                         falsification time
%                       optimTime       : total time used by the optimizer
%
%       * optRobIndex: stores the index of the run that first causes a
%       falsification, or the nearest test iteration.
%
%       * RandState: it stores information about the state of the random
%         number generator when staliro starts. See athena_options for
%         further details. Documentation: <a href="matlab: doc athena_options.seed">athena_options.seed</a>
%
%   - History: a cell array of size {athena_opt.athena_runs,1} containing a
%   structure with vectors equal in length to the runs (experiments)
%		executed. It contains the following fields for each run:
%       * rob: all the automatic fitness values computed for each test (simulation)
%       * fitness: all the manual fitness values computed for each test
%       (simulation)
%       * samples: all the samples generated for each test (simulation)
%       * cost: all the ATheNA fitness values computed for each test (simulation).
%       If the staliro option TimeStatsCollect is set to 1 (or true), then 
%       the following fields are also included:
%       * simTimes: the model simulation or SUT execution time for each test 
%       * robTimes: the robustness computation time for each test
%
%   - Opt: a a cell array of size {athena_opt.athena_runs,1} with a copy of
%   the options given in the input, for each run.
%
% See also: athena_options, SimulateModel, staliro_blackbox, dp_taliro, dp_t_taliro
function [Results, History, Opt] = athena(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, athena_opt)
%% Check and load the correct settings
% SA_Taliro optimization algorithm check
assert(strcmp(athena_opt.optimization_solver, 'SA_Taliro'), 'ATheNA is only compatible with the "SA_Taliro" optimization algorithm. The chosen algorithm "%s" is incompatible and must be changed.', athena_opt.optimization_solver);
% runs == 1 else warn + fix
assert(athena_opt.runs > 0, 'S-TaLiRo needs to run 1 time to function. It is currently running %d times', athena_opt.runs);
if athena_opt.runs > 1
    warning('Warning: "athena_options.runs", which is the default number of runs parameter for S-TaLiRo, must be set to 1. To conduct multiple runs, make sure to change "athena_options.athena_runs" instead. The program will make the necessary fixes for this execution.');
    athena_opt.athena_runs = athena_opt.runs;
    athena_opt.runs = 1;
end
% Start time
tstart = tic;
Results = cell(athena_opt.athena_runs,1);
History = cell(size(Results));
Opt = cell(size(Results));
% Save the basic values to the file before running
if ~isempty(athena_opt.SaveFile)
    save(athena_opt.SaveFile, "Results", "Opt", "History", "cp_array", "model", "input_range", "init_cond", "TotSimTime", "phi", "preds");
end

% Run ATheNA-S algorithm
for ii=1:athena_opt.athena_runs
    % Print the current run number
    fprintf('ATHENA RUN NUMBER %d / %d', ii, athena_opt.athena_runs);
    % If Nfig >= 0, call GenerateOutputWindow
    if athena_opt.Nfig >= 0
        GenerateOutputWindow(athena_opt, cp_array, preds, ii);
    end
    [results, history, opt] = staliro(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, athena_opt);
    Results{ii} = results;
    History{ii} = history;
    Opt{ii} = opt;
    if ~isempty(athena_opt.SaveFile) && athena_opt.IntermediateSave
        save(athena_opt.SaveFile, "Results", "Opt", "History", '-append');
    end
end

% If RunSummary
if athena_opt.RunSummary
    GenerateRunSummary;
end
timeElaps = toc(tstart);
fprintf('The calculation required %i seconds.\n\n',round(timeElaps))

if ~isempty(athena_opt.SaveFile)
    save(athena_opt.SaveFile)
    fprintf('\nData saved in %s\n\n',athena_opt.SaveFile)
end
if athena_opt.NotifyEnd
    beep on
    beep
    pause(0.5)
    beep
    pause(0.5)
    beep
end
fprintf('--------------END ATHENA--------------\n');
end