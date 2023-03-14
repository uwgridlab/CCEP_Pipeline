%% CCEP_setup should be run once after cloning the CCEP_Pipeline repo

% ensure that CCEP_Pipeline repo has been added to Matlab path
basedir_app = fileparts(which('CCEP_setup.m'));
if isempty(basedir_app)
    error('Make sure that CCEP_Pipeline has been added to your Matlab path');
end

% identify and save data directory
datadir = uigetdir('Select/create the base directory for storing raw and processed CCEP data');
save(fullfile(basedir_app, 'datadir.mat'), 'datadir');

% indicate completion
disp('CCEP_Pipeline has been successfully set up. Type CCEP into your workspace to get started.')