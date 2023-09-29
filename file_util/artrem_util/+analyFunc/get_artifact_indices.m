function [startInds,endInds] = get_artifact_indices(rawSig, txt, fs, pre, ...
    post, goodCell, stimRecord)

% This function will extract the indices to begin and end each artifact
% selection period on a channel and trial basis. The channel with the
% largest artifact is used to select the approximate beginning of the
% artifacts across all other channels.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% rawSig = samples x channels x trials
% txt = text window to print output
% fs = sampling rate (Hz)

% pre = the number of ms before which the stimulation pulse onset as
%   detected by a thresholding method should still be considered as artifact
% post = the number of ms after which the stimulation pulse onset as
%   detected by a thresholding method should still be considered as artifact

% goodCell = trials x 1 cell array with good channels for each trial  in
%   each cell
% stimRecord = trials x 1, onset of stim delivery in samples


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETURNS:

% startInds = cell array of the start indices each artifact for each
%	channel and trial - startInds{trial}{channel}
% endsInds = cell array of the end indices of each artifact for each
%	channel and trial - endInds{trial}{channel}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adapted from software by D Caldwell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if goodCell is not provided, all channels are labeled as good for all
% trials
if isempty(goodCell)
    goodCell = repmat({1:size(rawSig, 2)}, size(stimRecord, 1), 1);
end

presamps = round(pre/1e3 * fs); % pre time in sec
postsamps = round(post/1e3 * fs); %
% hardcoded
threshVoltageCut = 80; threshDiffCut = 80;
minDuration = round(0.25/1e3 * fs);
defaultWinAverage = round(4/e3 * fs);
onsetThreshold = 5;

% choose how far before and after the stim onset time to search for
% artifacts - ensuring that there will never be multiple onset times in a
% given window
n = 2; div = true;
while div
    txt.Value = vertcat({sprintf('--- Window: 1/%d median stim interval ---', n)}, ...
        txt.Value); pause(0.01);
    stimInterval = round(median(diff(stimRecord))/n);
    div = stimInterval > min(diff(stimRecord));
    n = n + 1;
end

% take diff of signal to find onset of stimulation train
order = 3;
framelen = 7;
txt.Value = vertcat({'--- Smoothing data with Savitsky-Golay filter ---'}, txt.Value); pause(0.01);
% fprintf('-------Smoothing data with Savitsky-Golay Filter-------- \n')

rawSigFilt = rawSig;
for ind = 1:size(rawSigFilt,2)
	rawSigFilt(:,ind) = savitskyGolay.sgolayfilt_complete(rawSig(:,ind),order,framelen);
end

diffSig = diff(rawSigFilt);
diffSig = [diffSig(1, :); diffSig]; % equalize length by repeating first row
zSig = abs(zscore(diffSig)); % zscore the whole time series together (not trial-wise)

txt.Value = vertcat({'--- Done smoothing and differentiating ---'}, txt.Value); pause(0.01);
% fprintf(['-------Done smoothing and differentiating-------- \n'])
txt.Value = vertcat({'--- Getting artifact indices ---'}, txt.Value); pause(0.01);
% fprintf(['-------Getting artifact indices-------- \n'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pctl = @(v,p) interp1(linspace(0.5/length(v), 1-0.5/length(v), length(v))', ...
    sort(v), p*0.01, 'spline');

startInds = cell(1, size(stimRecord, 1));
endInds = cell(1, size(stimRecord, 1));

for trial = 1:size(stimRecord, 1)
    
    win = (stimRecord(trial) - stimInterval):(stimRecord(trial) + stimInterval); % samples
    
    locZSig = zSig(win, goodCell{trial}); % abs zscore differentiated signal
    [~, chanMax] = max(max(locZSig)); % find the good channel with the highest value for computations later
    
    % find indices where zscore crosses threshold
    inds = find(locZSig(:, chanMax) > onsetThreshold);
        
    diffBtInds = diff(inds)';
%     if ~any(abs(zscore(diffBtInds))) > onsetThreshold
%         indsOnset = 1;
%     else
        [~,indsOnset] = find(abs(zscore(diffBtInds))>onsetThreshold);
%     end
    
    startInds{trial} = cell(1, size(rawSig, 2));
    endInds{trial} = cell(1, size(rawSig, 2));
    
    for chan = goodCell{trial}
        
        if ~isempty(inds)
            % adjust indices to be for full time series
            startInds{trial}{chan} = [inds(1)-presamps; inds(indsOnset+1)-presamps]' + win(1) - 1;

                for idx = 1:length(startInds{trial}{chan})


                    win_idx = startInds{trial}{chan}(idx):startInds{trial}{chan}(idx)+defaultWinAverage; % get window that you know has the end of the stim pulse
                    signal = rawSigFilt(win_idx, chan);
                    diffSignal = diffSig(win_idx, chan);

                    absZSig = abs(zscore(signal));
                    absZDiffSig = abs(zscore(diffSignal));

                    threshSig = pctl(absZSig,threshVoltageCut); 
                    threshDiff = pctl(absZDiffSig,threshDiffCut); 

                    % look past minimum start time
                    last = presamps+minDuration+find(absZSig(presamps+minDuration:end)>threshSig,1,'last'); 
                    last2 = presamps+minDuration+find(absZDiffSig(presamps+minDuration:end)>threshDiff,1,'last')+1; 
                    ct = max(last, last2);

                    if isempty(ct)
                        ct = last;
                        if isempty(last)
                            ct = last2;
                            if isempty(last2)
                                ct = postsamps;
                            end
                        end
                    end

                    endInds{trial}{chan}(idx) = ct + startInds{trial}{chan}(idx) + postsamps;

                end
            end
        end
        
    end
    txt.Value = vertcat({sprintf('Finished getting artifacts - Trial %d', trial)}, ...
        txt.Value); pause(0.01);
%     fprintf(['-------Finished getting artifacts - Trial ' num2str(trial) '-------- \n'])
    
end

end