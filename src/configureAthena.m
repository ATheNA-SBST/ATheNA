% Configuring ATheNA
%
% ATheNA needs to modify some files in the staliro folder when the staliro
% is first used to ensure all methods work as intended. This process needs
% to be completed once per new staliro file.
%
% Usages:
%
% configureAthena(staliro_file_loc)
% configureAthena()
%
% DESCRIPTION :
%
%   The program can either modify the required files if given an absolute
%   path to the location of the staliro folder, or if the intended staliro
%   folder target is added to the path. If multiple staliro folders are
%   added to the path, provide the absolute path to the folder intended for
%   use with ATheNA as an argument. It is recommended that all staliro 
%   folders that are not intended for use with the ATheNA toolbox be 
%   removed from the MATLAB path. This function returns no outputs, except 
%   prints when a file has been replaced.
%
% INPUTS :
%
%   - staliro_file_loc : The absolute path to the target staliro folder.
%
%       Examples: 
%        % Windows path
%        staliro_file_loc = 'C:\Users\user\Documents\staliro'; 
%        % MacOS path
%        staliro_file_loc = '/Users/user/staliro';
%        % Linux path
%        staliro_file_loc = '/home/user/staliro';
function configureAthena(staliro_file_loc)
if nargin == 0
    staliro_file_loc = which('staliro_options.m');
    [staliro_file_loc,~] = fileparts(staliro_file_loc);
end
cur_dir = pwd;
addpath(genpath('UpdateStaliro'))
updateStaliroCode(staliro_file_loc);
cd(cur_dir);
rmpath(genpath('UpdateStaliro'))
end