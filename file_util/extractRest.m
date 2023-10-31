function [rs_data, rs_idx] = extractRest(data, onsets_samps, fs)
%EXTRACTREST Summary of this function goes here
%   Detailed explanation goes here

%     data_artrem = data;
%     
%     for ii = 1%:size(onsets_samps)
%         
%         idx = [-10 100] + onsets_samps(ii);
%         d = data_artrem([-1 1] + idx(1), :);
%         d = mean(d);
%         data_artrem(idx, :) = d;
%         
%     end

    post_stim = length(data) - onsets_samps(end) - fs*2;
    pre_stim = onsets_samps(1) - fs*16;
    if pre_stim >= post_stim
        rs_idx = round(fs*15):(onsets_samps(1) - round(fs));
    else
        rs_idx = (onsets_samps(end) + round(fs*2)):length(data);
    end
    if length(rs_idx) < fs*10
        warning('Less than 10s resting state available')
    elseif length(rs_idx) < fs
        error('No valid resting state available')
    else
        fprintf('Extracting %0.1f secs resting state...\n', length(rs_idx)/fs);
    end
    
    rs_data = data(rs_idx, :);

end

