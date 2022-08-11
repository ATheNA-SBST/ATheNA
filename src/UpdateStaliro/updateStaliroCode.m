function updateStaliroCode(dest_absolute)
new_file_loc = which('updateStaliroCode.m');
[new_file_loc, ~] = fileparts(new_file_loc);
cd(strcat(dest_absolute));
if exist('staliro.m', 'file')
    delete('staliro.m');
end
cd(new_file_loc);
copyfile(strcat(new_file_loc,filesep,'staliro.m'), strcat(dest_absolute));
fprintf('Successfully replaced staliro.m in %s.\n',dest_absolute);
cd(strcat(dest_absolute,filesep,'optimization'));
if exist('SA_Taliro.m', 'file')
    delete('SA_Taliro.m');
end
cd(new_file_loc);
copyfile(strcat(new_file_loc,filesep,'SA_Taliro.m'), strcat(dest_absolute,filesep,'optimization'));
fprintf('Successfully replaced SA_Taliro.m in %s%coptimization.\n',dest_absolute,filesep);
robustness_files = {'Compute_Robustness.m','Compute_Robustness_Right.m'};
for ii = 1:length(robustness_files)
cd(strcat(dest_absolute,filesep,'auxiliary'));
if exist(robustness_files{ii}, 'file')
    delete(robustness_files{ii});
end
cd(new_file_loc);
copyfile(strcat(new_file_loc,filesep,robustness_files{ii}), strcat(dest_absolute,filesep,'auxiliary'));
fprintf('Successfully replaced %s in %s%cauxiliary.\n', robustness_files{ii},dest_absolute,filesep);
end
end