function [rs_data] = extractRest(data_in, onsets_samps, fs)
%EXTRACTREST Summary of this function goes here
%   Detailed explanation goes here

    first_stim = onsets_samps(1);
    if first_stim < fs*12
        warning('Less than 10s resting state available')
    elseif first_stim < fs
        error('No valid resting state available')
    else
        fprintf('Extracting %0.1f secs resting state...\n', (first_stim - 2*fs)/fs);
    end
    
    rng = round(fs):round(first_stim - fs);
    rs_data = data_in(rng, :);

end

