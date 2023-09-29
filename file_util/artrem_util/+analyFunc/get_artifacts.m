function [templateCell, maxAmps, lengthMax] = get_artifacts(rawSig, goodCell, ...
    startInds, endInds)

% This function extracts artifacts from each channel and trial to use in
% dictionary building

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% rawSig = samples x channels x trials
% goodCell = trials x 1 cell array with good channels for each trial  in
%   each cell
% startInds = cell array of the start indices each artifact for each
%	channel and trial - startInds{trial}{channel}
% endsInds = cell array of the end indices of each artifact for each
%	channel and trial - endInds{trial}{channel}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETURNS:

% templateCell = 1 x channels cell array with nested cells for each trial
%   and each artifact per trial (if relevant) ?
%   templateCell{chan}{trial}{stim}
% maxAmps = 1 x channels arry with maximum amplitude over all artifacts for
%   each channel
% lengthMax = 1 x channels array with the length of the longest artifact
%   for each channel


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adapted from software by D Caldwell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if goodCell is not provided, all channels are labeled as good for all
% trials
if isempty(goodCell)
    goodCell = repmat({1:size(rawSig, 2)}, size(stimRecord, 1), 1);
end
% hardcoded:
amntPreAverage = 3;

nTrials = length(startInds); nChans = size(rawSig, 2);

lengthMaxVecTrial = zeros(nTrials, nChans);
maxLocationTrials = nan(nTrials, nChans);
maxTrials = nan(nTrials, nChans);
templateCell = repmat({cell(1, nTrials)}, 1, nChans);

for trial = 1:nTrials % loop through trials
    
    lengthMaxChan = zeros(1, nChans);

    for chan = goodCell{trial} % loop through good channels for this trial
        
        locMax = zeros(1, length(startInds{trial}{chan}));
        avgSignal = cell(1, length(startInds{trial}{chan}));
        for sts = 1:length(startInds{trial}{chan}) % loop through individual stimulation epochs
            win = startInds{trial}{chan}(sts):endInds{trial}{chan}(sts);
            locMax(sts) = length(win);
            
            rawSigTemp = rawSig(win, chan);
            
            avgSignal{sts} = rawSigTemp - mean(rawSigTemp(1:amntPreAverage));% take off average of first x samples
                        
        end
        
        if isempty(locMax)
            lengthMaxChan(chan) = 0;
            maxLocationTrials(trial, chan) = 0;
            maxTrials(trial, chan) = 0;
        else
            lengthMaxChan(chan) = max(locMax);
            templateCell{chan}{trial} = avgSignal;

            [maxLoc, idxLoc] = cellfun(@max, avgSignal);
            maxLocationTrials(trial, chan) = median(idxLoc);
            maxTrials(trial, chan) = median(maxLoc);
        end
        
    end
    lengthMaxVecTrial(trial,:) = lengthMaxChan;
    
end

% find max amplitude, artifact length for each channel
maxAmps = nanmax(maxTrials);
lengthMax = max(lengthMaxVecTrial,[],1);

end