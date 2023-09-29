function [processedSig, chck, templateArrayCell,startInds, endInds, maxAmps, ...
    maxLocation] = template_subtract(rawSig, txt, fs, pre, post, bracketRange, ...
    distanceMetricDbscan, stimChans, stimRecord, bads)

% This function will perform a template subtraction scheme for artifacts on
% a trial by trial, channel by channel basis. This function will build up
% a dictionary of artifacts, best match the template, and subtract the
% template from the trial.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% rawSig = samples x channels x trials
% txt = text window to print output
% fs = sampling rate (Hz)

% pre = the number of ms before which the stimulation pulse onset as
%   detected by a thresholding method should still be considered as artifact
% post = the number of ms after which the stimulation pulse onset as
%   detected by a thresholding method should still be considered as artifact
% bracketRange = the number of samples around the maximum voltage deflection 
%   to use for template clustering and subsequent matching (default -6:6)
% distanceMetricDbscan = 'corr' or 'eucl', specifies metric for matching
%   artifacts in dictionary

% stimChans = trials x 2 record of stimulation channel used
% stimRecord = trials x 1 record of onset of stim delivery in samples
% bads = logical array of trials x channels or a cell array of trials x 1
%   to indicate bad channels in each trial (likely the same throughout but
%   flexible to allow for removal of spikes/noisy trials beforehand)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% These variables are changeable in original script but hardcoded here
% useFixedEnd = false, type = dictionary, plotIt = false (obviating chanInt), 
% distanceMetricSigMatch = xcorr, useFixedEnd = false, fixedDistance = 4, 
% minDuration = 0.25, threshVoltageCut = threshDiffCut = 80,
% onsetThreshold = 5, fixInterval = false, normalize = preAverage, 
% amntPreAverage = 3, alignmentSimilarity = 0.9, doNotRealign = false,
% recoverExp = false, minPts = 2, minClustSize = 1, outlierThresh = 0.95,
% useProcrustes = true

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% make a vector of the good channels to process

numChans = size(rawSig,2);
goodCell = helpFunc.good_channel_extract(numChans, bads, stimChans);

%% get beginnings and ends of artifacts

[startInds,endInds] = analyFunc.get_artifact_indices(rawSig, txt, fs, ...
    pre, post, goodCell, stimRecord);

%% extract artifacts

[templateCell, maxAmps, lengthMax] = analyFunc.get_artifacts(rawSig ,goodCell,...
    startInds, endInds);

%% get templates all same length

[templateArrayCell, maxIdxArray] = ...
    analyFunc.template_equalize_length(templateCell,rawSig, txt, startInds, ...
    lengthMax);

%% align templates

[templateArrayCell, maxLocation] = analyFunc.template_align(templateArrayCell, ...
    maxIdxArray, txt);

%% build up dictionary

processedSig = analyFunc.template_dictionary(templateArrayCell, rawSig, txt, ...
    distanceMetricDbscan, startInds, endInds, maxLocation, bracketRange);

%% check removal quality

txt.Value = vertcat({'--- Checking removal quality ---'}, txt.Value); pause(0.01);
chck = analyFunc.assess_removal(processedSig, startInds, endInds);
txt.Value = vertcat({'--- Artifact removal complete! ---'}, txt.Value); pause(0.01);

end