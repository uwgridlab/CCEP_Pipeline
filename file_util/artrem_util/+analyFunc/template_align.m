function [templateArrayCell, maxLocation] = template_align(templateArrayCell, ...
    maxIdxArray, txt)

% This function cross-correlates across artifacts to align maxima across
% trials for each channel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% templateArrayCell = 1 x chans cell array with an array of templates for
%   the channel in each cell (samps x trials)
% maxIdxArray = 1 x chans cell array with array of the sample with the
%   maximum amplitude for each trial in that channel (1 x trials)
% txt = text window to print output

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETURNS:

% templateArrayCell = 1 x chans cell array with an array of templates for
%   the channel in each cell (samps x trials), now aligned to max
% maxLocation = 1 x chans array with the index of the maximum across trials
%   for each channel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adapted from software by D Caldwell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % hardcoded:
    alignmentSimilarity = 0.9;
    
    maxLocation = zeros(1, size(templateArrayCell, 2));
    for chan = 1:length(templateArrayCell)
        
        template = templateArrayCell{chan};
        idx = maxIdxArray{chan};
        ctr = floor(median(idx));
        len = size(template, 1);
        newLen = len + max(ctr - idx) + max(idx - ctr);
        newCtr = ctr + max(idx - ctr);
        templateAligned = nan(newLen, size(template, 2));
        
        % align to max
        for trial = 1:size(template, 2)
            frontPad = newCtr - idx(trial);
            endPad = newLen - (len + frontPad);
            templateTrial = padarray(template(:, trial), frontPad, 0, 'pre');
            templateTrial = padarray(templateTrial, endPad, 0, 'post');
            templateAligned(:, trial) = templateTrial;
        end
        
        % align by cross-correlation
        [templateAligned, newCtr] = analyFunc.xcorr_align(templateAligned, 5, newCtr, alignmentSimilarity);
        
        templateArrayCell{chan} = templateAligned;
        if isempty(newCtr)
            newCtr = nan;
        end
        maxLocation(chan) = newCtr;
    end
    
    txt.Value = vertcat({'--- Finished equalizing artifact length ---'}, txt.Value); pause(0.01);

end

