%% pipeline codes for analysing eeg data of iris' pain empathy experiment

%%%%%% parameters initialization

% prepare directory
baseDir = 'E:\Thelma\zhu';
inputDir = 'E:\Thelma\zhu\merge';
outputDir = fullfile(baseDir, 'pre');

% preprocessing parameters
DS			= 250; % downsampling
HP 			= 1; 
MODEL  	= 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
UNUSED	= {'VEO', 'HEOR'}; % labels of channels you do not use
CHANTHRESH = 0.5; % parameter for reject bad channels

% epoching parameters
REF			= {'TP9', 'TP10'};
ONREF 	= 'FCz';
CHANGE 	= true; % change event name
EPOCHTIME = [-1, 2]; % epoch time range
FROM 		= {'S  3', 'S  6', 'S  7'}; % original marks of stimulus
TO			= {'self_name', ...
           'same_surname', ...
           'different_surname'}; % change original marks to more readable names
STIM 		= FROM;
RESP 		= {'S  7', 'S  8', 'S  9'};		% marks of responses 

%%%%%% check directory
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% channel location files
switch MODEL
	case 'MNI'
		locFile = 'standard_1005.elc';
	case 'Spherical'
		locFile = 'standard-10-5-cap385.elp';
end
locDir = dirname(which(locFile));

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
lix_matpool(4);

%%%%%% start for loop
parfor i = 1:nFile
    %%%%%% prepare output filename
    name = strcat(ID{i}, '_pre.set');
    outName = fullfile(outputDir, name);

    %%%%%% check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    
    %%%%%% load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);

    %%%%%% add channel locations
    EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
    EEG = eeg_checkset(EEG);
    nchan = size(EEG.data, 1);
    EEG = pop_chanedit(EEG, 'append', nchan, ...
                       'changefield',{nchan+1, 'labels', ONREF}, ...
                       'lookup', locDir, ...
                       'setref',{['1:',int2str(nchan+1)], ONREF}); % add online reference
    EEG = eeg_checkset(EEG);
    outStruct = chanLocCreate(ONREF, nchan+1)
    EEG = pop_reref(EEG, [], 'refloc', outStruct); % retain online reference data back
    EEG = eeg_checkset(EEG);
    EEG = pop_chanedit(EEG, 'lookup', locDir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
    EEG = eeg_checkset(EEG);
    chanlocs = pop_chancenter(EEG.chanlocs, []);
    EEG.chanlocs = chanlocs;
    EEG = eeg_checkset(EEG);

    %%%%%% remove nonbrain channels
    chanLabels = {EEG.chanlocs.labels};
    idx = lix_elecfind(chanLabels, UNUSED);
    EEG = pop_select(EEG,'nochannel', idx);
    EEG = eeg_checkset(EEG);
    

    %%%%%% downsampling
    EEG = pop_resample(EEG, DS);
    EEG = eeg_checkset(EEG);

    %%%%%% high pass filtering: 1 Hz for better ica results, but not proper for erp study
    EEG = pop_eegfiltnew(EEG, HP, []); 
    EEG = eeg_checkset(EEG);
    
    %%%%%% re-reference
    chanLabels = {EEG.chanlocs.labels};
    if strcmpi(REF, 'average')
        EEG = pop_reref(EEG, []);
    elseif iscellstr(REF)
        indRef = lix_elecfind(chanLabels, REF);
        EEG = pop_reref(EEG, indRef);
    end
    EEG = eeg_checkset(EEG);

    %%%%%% remove bad channels
    arg_flatline = 5; % default is 5
    arg_highpass = 'off';
    arg_channel = CHANTHRESH; % default is 0.85
    arg_noisy = [];
    arg_burst = 'off';
    arg_window = 'off';
    EEGclean = clean_rawdata(EEG, ...
                             arg_flatline, ...
                             arg_highpass, ...
                             arg_channel, ...
                             arg_noisy, ...
                             arg_burst, ...
                             arg_window);
    chanLabels = {EEG.chanlocs.labels};
    if isfield(EEGclean.etc, 'clean_channel_mask')
        EEG.etc.badChanLabelsASR = chanLabels(~EEGclean.etc.clean_channel_mask);
        EEG.etc.badChanLabelsASR
        EEG = pop_select(EEG, 'nochannel', find(~EEGclean.etc.clean_channel_mask));
    else
        EEG.etc.badChanLabelsASR = {[]};
    end
    EEG = eeg_checkset(EEG);
    EEGclean = [];
    
    %%%%%% change events
    EEG = readable_event(EEG, RESP, STIM, CHANGE, FROM, TO);
    
    %%%%%% epoch
    if CHANGE
	    	MARKS = unique(TO);
    else
	    	MARKS = unique(FROM);
    end
    EEG = pop_epoch(EEG, MARKS, EPOCHTIME);
    EEG = eeg_checkset(EEG);

    %%%%%% save dataset
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = [];

end

