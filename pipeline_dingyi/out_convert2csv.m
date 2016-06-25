%% converting matlab file into csv format
baseDir = '~/data/dingyi/';
inDir = fullfile(baseDir, 'output');
outDir = fullfile(baseDir, 'csv');
if ~exist(outDir, 'dir'); mkdir(outDir); end

load(fullfile(inDir, 'Pow.mat'));
load(fullfile(inDir, 'samEn.mat'));
load(fullfile(baseDir, 'chanlocs.mat'));

tagSubjs = Pow.subj;
tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;

%% relative power
chans = {chanlocs.labels};
for iChan = 1:numel(chans);
    chan = chans(iChan);
    chanStr = cellstrcat(chan, '-');
    fnRelPow = fullfile(outDir, sprintf('powRelative_%s.csv', chanStr));

    tagSubjs = Pow.subj;
    tagBands = Pow.tagBands(1:5);
    tagStates = Pow.tagStates;
    indChan = ismember({chanlocs.labels}, chan);

    relpow = squeeze(mean(Pow.Rel(:, 1:5, indChan, :), 3));
    relpow = relpow(:);
    states = repmat(tagStates', [numel(tagBands)*numel(tagSubjs), 1]);
    bands = repmat(tagBands, [numel(tagStates), numel(tagSubjs)]);
    bands = bands(:);
    subjs = repmat(tagSubjs, [numel(tagStates)*numel(tagBands),1]);
    subjs = subjs(:);

    relativePower.subjs = subjs;
    relativePower.states = states;
    relativePower.bands = bands;
    relativePower.relpow = relpow;

    struct2csv(relativePower, fnRelPow);
end
%% PowerRatio
chans = {chanlocs.labels};
for iChan = 1:numel(chans)
    chan = chans(iChan);
    chanStr = cellstrcat(chan, '-');
    fnPowRatio = fullfile(outDir, sprintf('powRatio_%s.csv', chanStr));

    indChan = ismember({chanlocs.labels}, chan);

    DA = squeeze(mean(Pow.DA(:, indChan, :), 2));
    DTAT = squeeze(mean(Pow.DTAT(:, indChan, :), 2));
    DTAB = squeeze(mean(Pow.DTAB(:, indChan, :), 2));
    samEn = squeeze(mean(sampleEn.data(:, indChan, :), 2));
    DA = DA(:);
    DTAT = DTAT(:);
    DTAB = DTAB(:);
    samEn = samEn(:);
    states = repmat(tagStates', [numel(tagSubjs), 1]);
    subjs = repmat(tagSubjs, [numel(tagStates), 1]);
    subjs = subjs(:);

    powerRatio.subjs = subjs;
    powerRatio.states = states;
    powerRatio.DA = DA;
    powerRatio.DTAT = DTAT;
    powerRatio.DTAB = DTAB;
    powerRatio.samEn = samEn;

    struct2csv(powerRatio, fnPowRatio);
end
