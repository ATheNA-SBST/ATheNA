function updateStaliroCode(dest_absolute)
warning off MATLAB:RMDIR:RemovedFromPath;
new_file_loc = which('updateStaliroCode.m');
[new_file_loc, ~] = fileparts(new_file_loc);
cd(strcat(dest_absolute));
if isfolder('demos')
    fprintf('ATTENTION: The ''%s'' folder will be DELETED from %s. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','demos',dest_absolute);
    rmdir('demos', 's');
end
if isfolder('benchmarks')
    fprintf('ATTENTION: The ''%s'' folder will be DELETED from %s. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','benchmarks',dest_absolute);
    rmdir('benchmarks', 's');
end
if isfile('staliro.m')
    fprintf('ATTENTION: The %s.m file in %s will be DELETED and the %s.m file in %s will be used instead. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','staliro',dest_absolute,'staliro',new_file_loc);
    delete('staliro.m');
end
fprintf('The %s%c%s.m file is now in use.\n',new_file_loc,filesep,'staliro');
cd(strcat(dest_absolute,filesep,'optimization'));
if isfile('SA_Taliro.m')
    fprintf('ATTENTION: The %s.m file in %s will be DELETED and the %s.m file in %s will be used instead. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n','SA_Taliro',dest_absolute,'SA_Taliro',new_file_loc);
    delete('SA_Taliro.m');
end
fprintf('The %s%c%s.m file is now in use.\n',new_file_loc,filesep,'SA_Taliro');
robustness_files = {'Compute_Robustness.m','Compute_Robustness_Right.m'};
for ii = 1:length(robustness_files)
cd(strcat(dest_absolute,filesep,'auxiliary'));
if isfile(robustness_files{ii})
    fprintf('ATTENTION: The %s file in %s will be DELETED and the %s file in %s will be used instead. View the MATLAB General Preferences to see if the folder will be deleted permanently.\n',robustness_files{ii},dest_absolute,robustness_files{ii},new_file_loc);
    delete(robustness_files{ii});
end
fprintf('The %s%c%s file is now in use.\n',new_file_loc,filesep,robustness_files{ii});
end
addpath(genpath(new_file_loc));
warning on MATLAB:RMDIR:RemovedFromPath;
end