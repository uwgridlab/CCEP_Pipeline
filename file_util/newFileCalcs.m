function [amplitude, anode, cathode, data, fs, onsets_samps, pulse_width, ...
    badchans, goodchans, pw_data, yp, sp] = ...
    newFileCalcs(filedir, filename)
%NEWFILECALCS Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Loading file...\n');
    load(fullfile(filedir, filename), 'amplitude', 'anode', 'cathode', ...
        'data', 'fs', 'onsets_samps', 'pulse_width');
    
    rs_data = extractRest(data, onsets_samps, fs);
    save(fullfile(filedir, 'rs_data.mat'), 'rs_data', '-v7.3');
    
    fprintf('Detecting bad channels...\n');
    [badchans, goodchans] = autoBadChans(rs_data);
    save(fullfile(filedir, 'badchans.mat'), 'badchans', 'goodchans');
    
    fprintf('Computing power spectra...\n');
    pw_data = calcPWelch(rs_data, fs);
    
    fprintf('Epoching raw data for noise calculations...\n');
    [epoched, tEpoch] = epochData(data, onsets_samps, .5, 1, fs);
    
    fprintf('Fitting LF noise models...\n');
    [yval, sval, yp, sp] = calcLF(epoched, tEpoch, onsets_samps, fs);
    
    % not sure what HF metric should be, temporarily removing
%     fprintf('Computing high-frequency noise values...\n');
%     timeseries = calcHF(rs_data);
    
    save(fullfile(filedir, 'noise_vals.mat'), 'pw_data', ...
        'yval', 'sval', 'yp', 'sp');
    
    acceptedBadTrial = false;
    acceptedNoiseTol = false;
    acceptedArtrem = false;
    acceptedFilter = false;
    acceptedCoeff = false;
    save(fullfile(filedir, 'progress_report.mat'), 'acceptedBadTrial', ...
        'acceptedNoiseTol', 'acceptedArtrem', 'acceptedFilter', 'acceptedCoeff');

end

