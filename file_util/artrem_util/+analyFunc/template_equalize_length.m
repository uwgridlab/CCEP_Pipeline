function [templateArrayCell, maxIdxArray] = ...
    template_equalize_length(templateCell, rawSig, txt, startInds, lengthMax)
 
% This function pads artifacts over all channels to make them the same
% length as the longest artifact on that channel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% templateCell = 1 x channels cell array with nested cells for each trial
%   and each artifact per trial (if relevant) ?
%   templateCell{chan}{trial}{stim}
% rawSig = samples x channels x trials
% txt = text window to print output
% startInds = cell array of the start indices each artifact for each
%	channel and trial - startInds{trial}{channel}
% lengthMax = 1 x channels array with the length of the longest artifact
%   for each channel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETURNS:

% templateArrayCell = 1 x chans cell array with an array of templates for
%   the channel in each cell (samps x trials)
% maxIdxArray = 1 x chans cell array with array of the sample with the
%   maximum amplitude for each trial in that channel (1 x trials)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adapted from software by D Caldwell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

template = repmat({cell(1, length(startInds))}, 1, size(rawSig, 2));
maxIdx = repmat({cell(1, length(startInds))}, 1, size(rawSig, 2));

for chan = 1:size(rawSig, 2)
    
    lengthMaxChan = lengthMax(chan);
    
    for trial = 1:length(startInds)
        artifactsMat = nan(lengthMaxChan, length(startInds{trial}{chan}));
            for sts = 1:length(startInds{trial}{chan})
                artifactsTrial = templateCell{chan}{trial}{sts};
                if length(artifactsTrial) < lengthMaxChan
                    amntPad = lengthMaxChan - length(artifactsTrial);
                    artifactsMat(:, sts) = padarray(artifactsTrial, amntPad, 0, 'post');
                else
                    artifactsMat(:, sts) = artifactsTrial;
                end
            end
        template{chan}{trial} = artifactsMat;
        % find the index of the overall maximum
        [~, maxIdx{chan}{trial}] = max(abs(artifactsMat), [], 1);

    end
    
end


templateArrayCell = cellfun(@(x) [x{:}], template, 'UniformOutput', false);
maxIdxArray = cellfun(@(x) [x{:}], maxIdx, 'UniformOutput', false);

txt.Value = vertcat({'--- Finished equalizing artifact length ---'}, txt.Value);

end