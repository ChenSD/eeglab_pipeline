clear, clc, close all;
% set directory

baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'spherical_rv15');
outputDir = fullfile(baseDir, 'interp_rv15_2');
chanlocsDir = '~/mood_empathy_chanlocs.mat';

%% -----------------------------------------------------------
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));
load(chanlocsDir);
chanlocs = mood_empathy_chanlocs;

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

for i = 1:nFile

    outName = fullfile(outputDir, strcat(ID{i}, '_interp_rv15.set'));
    if exist(outName, 'file'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading data
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    % remove artfactual ICs
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    % interpolating channels
    EEG = eeg_interp(EEG, chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, outName);
    EEG = []; ALLEEG = [];

end

