function [rs_data, rs_idx] = extractRest(data, onsets_samps, monA, fs, txt)
%EXTRACTREST Summary of this function goes here
%   Detailed explanation goes here

    % point 1: 15s into recording
    p1 = round(fs*15);
    % point 2: 1s before impedance check start
    p2 = find(monA, 1);
    % if p2 is within 10ms of first stim, there's no impedance check
    if (p2 >= onsets_samps(1) - round(fs*.01)) && (p2 <= onsets_samps(1) + round(fs*.01))
        p2 = []; p3 = [];
    % p3: 2s after impedance check end
    else
        p2 = p2 - round(fs);
        f = find(monA);
        p3 = find((f - onsets_samps(1)) < -round(fs*.01), 1, 'last');
        p3 = f(p3) + round(2*fs);
    end
    % p4: 1s pre stim
    p4 = onsets_samps(1) - round(fs);
    % p5: 2s post stim
    p5 = onsets_samps(end) + round(fs*2);
    % p6: 5s before end of recording
    p6 = length(data) - round(fs*5);
    
    % find longest interval
    p_all = [p1 p2 p3 p4 p5 p6];
    diff_p = diff(p_all);
    diff_p(diff_p < 0) = 0;
    diff_p(2:2:end) = 0; % exclude intervals during stimulation
    [~, p_idx] = max(diff_p);
    
    % rs_idx set to interval between points
    rs_idx = p_all(p_idx):p_all(p_idx + 1);

    if length(rs_idx) < fs
        error('No valid resting state available')
    elseif length(rs_idx) < fs*10
        warning('Less than 10s resting state available')
    elseif length(rs_idx) > fs*120
        txt.Value = vertcat(sprintf('Extracting 120 secs resting state from %0.1f secs total...', ...
            length(rs_idx)/fs), txt.Value);
        md = round(length(rs_idx)/2);
        sec = round(fs*60);
        rs_idx = rs_idx((md - sec):(md + sec));
    else
        txt.Value = vertcat(sprintf('Extracting %0.1f secs resting state...', ...
            length(rs_idx)/fs), txt.Value); pause(0.001);
    end
    
    rs_data = data(rs_idx, :);

end

