function [data_out] = rereference(data, idx, badchans, rrmode)

% Function to either common average, or median rereference,
%   INPUTS:
%       data: either time x channels, or time x channels x trials
%       idx: montage
%       mode: what type of rereferencing is requested, options are:
%           'mean': subtracts the mean over all channels from each trial
%           'median': subtracts the median over all channels from each trial
%           'bipolar': subtract each electrode (i) from its neighbor (i +
%               1), replacing channel i with this difference (output will
%               have 1 less meaningful channel than input)
%       bad_channels: a list of bad channels (leaves "bad" channels
%           untouched for output), defaults to none

    data_out = nan(size(data));

    for ii = 1:length(idx)
        loc_idx = idx{ii};
        loc_badchans = ismember(loc_idx, badchans);
        loc_goodchans = ~loc_badchans;
        loc_data = data(:, loc_idx, :);

        switch(rrmode)
            case 'mean'
                avg = nanmean(loc_data(:,loc_goodchans,:), 2);
                avg = repmat(avg, 1, size(loc_data(:, loc_goodchans,:), 2));
                data_out(:, loc_idx(loc_goodchans), :) = loc_data(:, loc_goodchans, :) - avg;
            case 'median'
                med = nanmedian(loc_data(:,loc_goodchans,:), 2);
                med = repmat(med, 1, size(loc_data(:,  loc_goodchans, :), 2));
                data_out(:, loc_idx(loc_goodchans), :) = loc_data(:, loc_goodchans, :) - med;
            case 'bipolar' % do 1 vs 2, 2 vs 3, etc
                for jj = 1:size(loc_data, 2) - 1
                    if ~(loc_badchans(jj) || loc_badchans(jj + 1) || ...
                            all(all(isnan(squeeze(loc_data(:, jj, :))))) || ...
                            all(all(isnan(squeeze(loc_data(:, jj + 1, :))))))
                        chanOdd = loc_data(:, jj, :);
                        chanEven = loc_data(:, jj+1, :);
                        newChan = chanEven - chanOdd;
                        data_out(:, loc_idx(jj), :) = newChan;
                    end
                end
        end
    end
end

