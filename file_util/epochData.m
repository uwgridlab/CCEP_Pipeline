function [epoched,tEpoch] = epochData(data, onsets_samps, pre, post, fs)
    s_on = onsets_samps - floor(pre*fs);
    s_off = onsets_samps + floor(post*fs);
    epoched = zeros(s_off(1) - s_on(1) + 1, size(data, 2), length(onsets_samps));
    for ep = 1:length(onsets_samps)
        epoched(:, :, ep) = data(s_on(ep):s_off(ep), :);
    end
    tEpoch = ((1:size(epoched, 1))/fs) - pre;
end