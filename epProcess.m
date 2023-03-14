basedir = '/Volumes/Data/Mayo/9f212f/Raw';
EPs = [];
allStim = cell(1, 4);
for filenum = 1:4

    load(fullfile(basedir, ['EP_Measure-' num2str(filenum) '.mat']))
    %%
    dataInt = ECO2.data(:, 24:39);
    type = 'dictionary';
    useFixedEnd = 0;
    % fixedDistance = 2;
    fixedDistance = 4; % in ms
    plotIt = 0;
    %pre = 0.4096; % in ms
    %post = 0.4096; % in ms
    pre = 0.8; % started with 1
    post = 0.5; % started with 0.2 - 1
    % 2.8, 1, 0.5 was 3/19/2018
    % these are the metrics used if the dictionary method is selected. The
    % options are 'eucl', 'cosine', 'corr', for either euclidean distance,
    % cosine similarity, or correlation for clustering and template matching.
    distanceMetricDbscan = 'eucl';
    distanceMetricSigMatch = 'corr';
    amntPreAverage = 3;
    normalize = 'preAverage';
    % normalize = 'firstSamp';
    onsetThreshold = 1.5;
    recoverExp = 0;
    threshVoltageCut = 75;
    threshDiffCut = 75;
    expThreshVoltageCut = 95;
    expThreshDiffCut = 95;
    bracketRange = [-3:3];
    chanInt = 28;
    minPts = 2;
    minClustSize = 3;
    outlierThresh = 0.95;
    fsData = ECO1.info.SamplingRateHz;
    fsSing = Sing.info.SamplingRateHz;
    stimChans = [11 12];
    minDuration = 0.5; % minimum duration of artifact in ms
    [processedSig,templateDictCell,templateTrial,startInds,endInds] = analyFunc.template_subtract(dataInt,'type',type,...
        'fs',fsData,'plotIt',plotIt,'pre',pre,'post',post,'stimChans',stimChans,...
        'useFixedEnd',useFixedEnd,'fixedDistance',fixedDistance,...,
        'distanceMetricDbscan',distanceMetricDbscan,'distanceMetricSigMatch',distanceMetricSigMatch,...
        'recoverExp',recoverExp,'normalize',normalize,'amntPreAverage',amntPreAverage,...
        'minDuration',minDuration,'bracketRange',bracketRange,'threshVoltageCut',threshVoltageCut,...
        'threshDiffCut',threshDiffCut,'expThreshVoltageCut',expThreshVoltageCut,...
        'expThreshDiffCut',expThreshDiffCut,'onsetThreshold',onsetThreshold,'chanInt',chanInt,...
        'minPts',minPts,'minClustSize',minClustSize,'outlierThresh',outlierThresh);
    %%
    [b, a] = butter(3, [57 63]/(fsData/2), 'stop');
    datafilt = filtfilt(b, a, processedSig);
    [b, a] = butter(3, [117 123]/(fsData/2), 'stop');
    datafilt = filtfilt(b, a, datafilt);
    [b, a] = butter(3, [177 183]/(fsData/2), 'stop');
    datafilt = filtfilt(b, a, datafilt);
    [b, a] = butter(3, 200/(fsData/2), 'low');
    datafilt = filtfilt(b, a, datafilt);
    [b, a] = butter(3, 0.5/(fsData/2), 'high');
    datafilt = filtfilt(b, a, datafilt);
    %%
    datafilt = downsample(datafilt, 6);
    fsData = fsData/6;
    %%
    [burst_limits, pulse_idx, trial_voltage] = getStimIndices(Sing);
    [data_epoched, epoch_indices, adj_by] = pullStimEpochs(datafilt, burst_limits, ...
        fsData, fsSing, 0.2, 0.4);
    EPs = cat(3, EPs, data_epoched);
%     tEpoch = -0.2:(1/fsData):(0.4 + (1/fsData));
%     plot(tEpoch, mean(data_epoched, 3));
    allStim{filenum} = Stim.data;
end
%%
tEpoch = -0.2:(1/fsData):(0.4 + (1/fsData));
save(fullfile(basedir, 'EPprocessed.mat'), 'EPs', 'allStim', 'fsData', 'tEpoch');
%%
meanEP = mean(EPs, 3);
medEP = median(EPs, 3);
win = [0, 0.03];
rtmnsq = squeeze(rms(EPs(tEpoch > win(1) & tEpoch < win(2), :, :)))';
save(fullfile(basedir, 'EPmagnitudes.mat'), 'meanEP', 'medEP', 'fsData', 'tEpoch', 'rtmnsq', 'win');