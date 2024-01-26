% This function removes unnecessary elements from the S-Taliro installation
% (benchmarks and demos folders) and remove functions that have been
% modified by Athena.
function updateStaliroCode(dest_staliro)
    % Deactivate warning for directory deletion (if necessary)
    warnState = warning('query','MATLAB:RMDIR:RemovedFromPath');
    if strcmp(warnState.state,'on')
        warning off MATLAB:RMDIR:RemovedFromPath;
    end

    % Get location of this function
    this_location = which('updateStaliroCode');
    this_location = fileparts(this_location);

    % Change directory to the S-Taliro one
    cd(dest_staliro);

    % Remove the ./staliro/benchmarks folder
    if isfolder('benchmarks')
        fprintf("ATTENTION: The '%s' folder will be DELETED from %s. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n",'benchmarks',dest_staliro);
        rmdir('benchmarks', 's');
    end

    % Remove the ./staliro/demos folder
    if isfolder('demos')
        fprintf("ATTENTION: The '%s' folder will be DELETED from %s. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n",'demos',dest_staliro);
        rmdir('demos', 's');
    end
    
    % Remove the ./staliro/staliro.m function
    if isfile('staliro.m')
        fprintf("ATTENTION: The '%s.m' file in %s will be DELETED and the %s.m file in %s will be used instead. View the MATLAB General Preferences to see if the file will be deleted permanently.\n",'staliro',dest_staliro,'staliro',this_location);
        delete('staliro.m');
    end
    fprintf('The %s%c%s.m file is now in use.\n',this_location,filesep,'staliro');

    % Remove the ./staliro/optimization/SA_Taliro.m function
    if isfile(strcat('optimization',filesep,'SA_Taliro.m'))
        fprintf('ATTENTION: The %s.m file in %s will be DELETED and the %s.m file in %s will be used instead. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','SA_Taliro',strcat(dest_staliro,filesep,'optimization'),'SA_Taliro',this_location);
        delete(strcat('optimization',filesep,'SA_Taliro.m'));
    end
    fprintf('The %s%c%s.m file is now in use.\n',this_location,filesep,'SA_Taliro');

    % Remove the ./staliro/auxiliary/Compute_Robustness.m function
    if isfile(strcat('auxiliary',filesep,'Compute_Robustness.m'))
        fprintf('ATTENTION: The %s.m file in %s will be DELETED and the %s.m file in %s will be used instead. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','Compute_Robustness',strcat(dest_staliro,filesep,'auxiliary'),'Compute_Robustness',this_location);
        delete(strcat('auxiliary',filesep,'Compute_Robustness.m'));
    end
    fprintf('The %s%c%s.m file is now in use.\n',this_location,filesep,'Compute_Robustness');

    % Remove the ./staliro/auxiliary/Compute_Robustness_Right.m function
    if isfile(strcat('auxiliary',filesep,'Compute_Robustness_Right.m'))
        fprintf('ATTENTION: The %s.m file in %s will be DELETED and the %s.m file in %s will be used instead. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','Compute_Robustness_Right',strcat(dest_staliro,filesep,'auxiliary'),'Compute_Robustness_Right',this_location);
        delete(strcat('auxiliary',filesep,'Compute_Robustness_Right.m'));
    end
    fprintf('The %s%c%s.m file is now in use.\n',this_location,filesep,'Compute_Robustness_Right');

    % Compile the S-Taliro files
    try
        setup_staliro;
    catch
        warning(sprintf("There was an error during the Mex compilation of S-Taliro functions.\n" + ...
            "Check the link below to make sure you have installed a compatible compiler and rerun 'configureAthena':\n" + ...
            "\thttps://www.mathworks.com/support/requirements/supported-compilers.html\n\n"))
    end

    % Reactivate warning for directory deletion (if necessary)
    if strcmp(warnState.state,'on')
        warning on MATLAB:RMDIR:RemovedFromPath;
    end
end