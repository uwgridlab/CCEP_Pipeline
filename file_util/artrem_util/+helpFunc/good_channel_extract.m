function [goodCell] = good_channel_extract(numChans, bads, stimChans)

% This function builds a good channel cell array to be used by other
% functions during artifact removal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARGUMENTS: 

% numChans = the number of channels recorded from, including stimulation
%   channels and bad channels
% bads = logical array of trials x channels or a cell array of trials x 1
%   to indicate bad channels in each trial (likely the same throughout but
%   flexible to allow for removal of spikes/noisy trials beforehand)
% stimChans = 2 x trials record of stimulation channel used

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETURNS:

% goodCell = trials x 1 cell array with good channels for each trial  in
%   each cell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adapted from software by D Caldwell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numTrials = size(stimChans, 1);

if isempty(bads)
    bads = false(numTrials, numChannels);
elseif size(stimChans, 1) ~= size(bads, 1)
    error(['stimChans should be trials x 2 (annode cathode),' ... 
        'bads should be a logical array of trials x channels' ... 
        'or a cell array of trials x 1']);
end


% make logical good channels matrix to index
goods = true(numTrials, numChans);
goodCell = cell(numTrials, 1);

% set the goods matrix to be zero where bad channels are
for trl = 1:numTrials
    goods(trl, stimChans(trl, :)) = false;
    if isempty(bads)

    elseif iscell(bads)
        goods(trl, bads{trl}) = false;
    elseif islogical(bads)
        goods(trl, bads(trl, :)) = false;
    else
        warning(['Unrecognized data type for bads (must be a logical array' ... 
            'of trials x channels or a cell array of trials x 1']);
    end
    goodCell{trl} = find(goods(trl, :));
end

end

