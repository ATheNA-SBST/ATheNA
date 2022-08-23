function updateStaliroCode(dest_absolute)
new_file_loc = which('updateStaliroCode.m');
[new_file_loc, ~] = fileparts(new_file_loc);
cd(strcat(dest_absolute));
if isfolder('demos')
    fprintf('ATTENTION: The ''%s'' folder will be removed PERMANENTLY from %s.\n','demos',dest_absolute);
    rmdir('demos', 's');
end
if isfolder('benchmarks')
    fprintf('ATTENTION: The ''%s'' folder will be removed PERMANENTLY from %s.\n','benchmarks',dest_absolute);
    rmdir('benchmarks', 's');
end
if isfile('staliro.m')
    delete('staliro.m');
end
cd(new_file_loc);
copyfile(strcat(new_file_loc,filesep,'staliro.m'), strcat(dest_absolute));
fprintf('Successfully replaced staliro.m in %s.\n',dest_absolute);
cd(strcat(dest_absolute,filesep,'optimization'));
if isfile('SA_Taliro.m')
    delete('SA_Taliro.m');
end
cd(new_file_loc);
copyfile(strcat(new_file_loc,filesep,'SA_Taliro.m'), strcat(dest_absolute,filesep,'optimization'));
fprintf('Successfully replaced SA_Taliro.m in %s%coptimization.\n',dest_absolute,filesep);
robustness_files = {'Compute_Robustness.m','Compute_Robustness_Right.m'};
for ii = 1:length(robustness_files)
cd(strcat(dest_absolute,filesep,'auxiliary'));
if isfile(robustness_files{ii})
    delete(robustness_files{ii});
end
cd(new_file_loc);
copyfile(strcat(new_file_loc,filesep,robustness_files{ii}), strcat(dest_absolute,filesep,'auxiliary'));
fprintf('Successfully replaced %s in %s%cauxiliary.\n', robustness_files{ii},dest_absolute,filesep);
end
end