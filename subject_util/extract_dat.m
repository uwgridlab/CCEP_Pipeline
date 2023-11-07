 function [amplitude, anode, cathode, data, fs, onsets_samps, pulse_width] = extract_dat(fname, montage)
%EXTRACT_DAT Summary of this function goes here
%   Detailed explanation goes here
    load(fname,'data')

    all_data = data; % full data struct - not needed
    [data, fs] = loadDataSynapse(all_data.streams, montage);
    stim_params = all_data.scalars.STMp.data; % all stim params - not needed
    
    onsets_ts = all_data.scalars.STMp.ts;
    onsets_samps = round(onsets_ts*fs)';
    
%     stim_struct = all_data.streams.STMr;
%     burst_limits = getStimIndicesOpenEx(stim_struct, true);
%     onsets_samps = burst_limits(:, 1);

    amplitude = stim_params(2, :)';
    anode = stim_params(12, :)';
    cathode = stim_params(6, :)';
    pulse_width = stim_params(4, :)';
    
    fname = split(fname, '.mat');
    fname = [fname{1} '_dat.mat'];

    save(fname, 'amplitude', 'anode', 'cathode', 'data', 'fs', 'onsets_samps', ...
        'pulse_width', '-v7.3');
end

