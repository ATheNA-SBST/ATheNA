classdef athena_options < staliro_options
    % Class definition for the ATheNA options, which inherit the properties
    % of staliro_options. Note that the optimization solver must be
    % SA_Taliro.
    %
    % opt = athena_options;
    %
    % The above function call sets the default values for the class properties.
    % For a detailed description of each property open the <a href="matlab: doc athena_options">athena_options help file</a>.
    %
    % To change the default values to user-specified values use the default
    % object already created to specify the properties.
    %
    % E.g.: to change the coefficient of robustness
    % opt.coeffRob = 0.4;
    %
    % NOTE: For more information on properties, click on them.

    properties
        % Sets the y-labels for the input plot window.
        %
        % Default value: InputLabels = '' 
        % If the default value is used and plot output is selected, then
        % the inputs will be labelled as 'Input i', where i is an integer
        % representing the index of each input port. If non-default labels
        % are selected for plot labels, create a cell array with the
        % intended y-label for each input port. The length of the cell
        % array must match the number of input ports in this case. Labels
        % can be formatted in tex, latex, or literal text depending on the
        % interpreter used.
        InputLabels = '';

        % Sets the y-labels for the output plot window.
        %
        % Default value: OutputLabels = ''
        % If the default value is used and plot output is selected, then
        % the outputs will be labelled as 'Output i', where i is an integer
        % representing the index of each output port. If non-default labels
        % are selected for plot labels, create a cell array with the
        % intended y-label for each output port. The length of the cell
        % array must match the number of output ports in this case. Labels
        % can be formatted in tex, latex, or literal text depending on the
        % interpreter used.
        OutputLabels = '';

        % Defines the manual fitness function to use.
        %
        % Default value: fitnessFcn = 'defaultFitness'
        % If the default value is used, then a manual fitness value of 1 is 
        % automatically generated. If another function is used to calculate
        % the manual fitness value, enter the name of the function as a 
        % string if the function is in a different file, or a function 
        % handle if the function is internal. For example, if a function 
        % named myManFit is used, set: 
        % opt.fitnessFcn = 'myManFit';
        % if the function is a main function, or
        % opt.fitnessFcn = @myManFit;
        % if the function is a nested or local function, where 'opt' can 
        % be replaced by the name of the athena_options object used.
        % For more help on creating manual fitness functions, type 
        % 'help createManualFitness'.
        fitnessFcn = 'defaultFitness';

        % Defines the coefficient of robustness for combining manual and
        % automatic fitness values.
        %
        % Default value: coeffRob = 0.5
        % The value of coeffRob has a range of [0, 1], where 1 indicates
        % use automatic fitness only (staliro robustness value), and 0
        % indicates use manual fitness only (the calculated manual fitness
        % value from athena_options.fitnessFcn). 
        % Ensure that all atomic predicates are normalized and that their
        % bounds are set for efficient combination of the values. The bound
        % of an atomic predicate is the highest magnitude robustness value
        % that is possible for that predicate, or a reasonable
        % approximation of that value. Formally, if the robustness
        % interval for some predicate is found to be within [a, b], then
        % the bound would be max(|a|,|b|). If the robustness interval is
        % unkown, then the magnitude of the difference of the input range
        % can be used. Formally, if the input range is [c, d], then the
        % bound would be |d - c|.
        % Note: The atomic predicates are stored in the "preds" struct that
        % is passed into the athena function
        % To normalize an atomic predicate at index i of a predicates
        % struct preds:
        % preds(i).Normalized = true;
        % To set the normalization bounds of an atomic predicate at index i
        % of a predicates struct preds to some value k:
        % preds(i).NormBounds = k;
        % See also: athena_options.fitnessFcn
        coeffRob = 0.5;

        % Determines whether an output window should be generated by ATheNA.
        %
        % Default value: Nfig = -1
        % The value of Nfig is an integer >= -1, where -1 indicates no
        % output should be generated, 0 indicates a progress bar should be
        % shown with the current run number, and integers >= 1 indicate the
        % figure number for plot outputs, with figure(Nfig) being the
        % figure for input plots, and figure(Nfig+1) being the figure for
        % output plots.
        Nfig = -1;

        % Indicates how many runs should be completed for the search.
        %
        % Default value: athena_runs = 1
        % The value of athena_runs must be an integer >= 1. If multiple
        % runs need to be executed, CHANGE THIS VALUE. DO NOT CHANGE THE
        % STALIRO runs VALUE (opt.runs). That value MUST remain 1. To
        % change the number of iterations for each athena_runs, change
        % opt.optim_params.n_tests (the same property as Staliro).
        athena_runs = 1;

        % Determines whether or not interpolated input should be used for
        % the manual fitness function.
        %
        % Default value: useInterpInput = true
        % If this value is set to false, then only the input control points
        % will be sent to the manual fitness function.
        useInterpInput = true;

        % Sets the label interpreter to use for plot y-labels.
        %
        % Default value: LabelInterpreter = 'tex'
        % This value can be set to 'tex', 'none', or 'latex'. Only relevant
        % if Nfig >= 1.
        LabelInterpreter = 'tex';

        % Determines whether or not to save the values for ATheNA after
        % each run.
        %
        % Default value: IntermediateSave = false
        % Only relevant if a filename for saving is provided.
        IntermediateSave = false;

        % Sets the filename for the file where the ATheNA data should be
        % saved.
        %
        % Default value: SaveFile = ''
        % If no filename is provided, then the data will not be saved.
        % Otherwise, the data will be saved using save(opt.SaveFile), where
        % SaveFile is the name of the file to save in. It is saved in the
        % current working directory.
        SaveFile = '';

        % Determines whether or not to beep to signal the end of all ATheNA
        % runs.
        %
        % Default value: NotifyEnd = false
        % Set to true only if a beep sequence should be played at the end
        % of all athena_runs.
        NotifyEnd = false;

        % Determines whether or not to print a summary of the test at the
        % end of all athena_runs in the command window.
        %
        % Default value: RunSummary = false
        % Set this value to true only if a summary should be printed at the
        % end of testing in the command window, with the average and median
        % iterations and robustness, as well as the success rate, where the
        % success rate is determined by how many athena_runs generated a
        % falsifying result.
        RunSummary = false;
    end
    methods

        function obj = set.InputLabels(obj,InputLabels)
            obj.InputLabels=InputLabels;
        end

        function obj = set.OutputLabels(obj,OutputLabels)
            obj.OutputLabels=OutputLabels;
        end

        function obj = set.fitnessFcn(obj,fitnessFcn)
            if isempty(fitnessFcn)
                warning("The given fitness function name was empty and invalid. The value of fitnessFcn will be reset to 'defaultFitness'.");
                fitnessFcn = 'defaultFitness';
            end
            obj.fitnessFcn=fitnessFcn;
        end

        function obj = set.coeffRob(obj,coeffRob)
            if coeffRob < 0 || coeffRob > 1
                warning('The coefficient of robustness must be a value in the range [0, 1]. The value will be rounded to the nearest possible value.');
                coeffRob = min(max(ceoffRob, 0), 1);
            end
            obj.coeffRob=coeffRob;
        end
        function obj = set.Nfig(obj,Nfig)
            if Nfig > 0 && Nfig ~= round(Nfig)
                warning('Nfig was not set to an integer value. The value is being rounded up to the nearest integer.');
                obj.Nfig=ceil(Nfig);
            else
                obj.Nfig=Nfig;
            end
        end
        function obj = set.athena_runs(obj,athena_runs)
            if athena_runs < 1
                warning('The value for athena_runs must be at least 1. The value will now be set to 1.');
                obj.athena_runs=1;
            elseif athena_runs ~= round(athena_runs)
                warning('The value for athena_runs must be an integer; athena_runs is being rounded to the nearest integer.');
                obj.athena_runs=round(athena_runs);
            else
                obj.athena_runs=athena_runs;
            end
        end
        function obj = set.useInterpInput(obj,useInterpInput)
            obj.useInterpInput=useInterpInput;
        end
        function obj = set.LabelInterpreter(obj,LabelInterpreter)
            obj.LabelInterpreter=LabelInterpreter;
        end
        function obj = set.IntermediateSave(obj,IntermediateSave)
            obj.IntermediateSave=IntermediateSave;
        end
        function obj = set.SaveFile(obj,SaveFile)
            obj.SaveFile=SaveFile;
        end
        function obj = set.NotifyEnd(obj,NotifyEnd)
            obj.NotifyEnd=NotifyEnd;
        end
        function obj = set.RunSummary(obj,RunSummary)
            obj.RunSummary=RunSummary;
        end
    end
end