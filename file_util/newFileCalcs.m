function [amplitude, anode, cathode, data, fs, onsets_samps, pulse_width, ...
    badchans, goodchans, pw_data, ypct, spct, dist] = ...
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
    fprintf('Fitting LF noise models...\n');
    [ypct, spct, yval, sval, yp, sp] = calcLF(data, onsets_samps, fs);
    fprintf('Computing high-frequency noise values...\n');
    [dist, timeseries] = calcHF(rs_data);
    save(fullfile(filedir, 'noise_vals.mat'), 'pw_data', 'ypct', 'spct', ...
        'yval', 'sval', 'yp', 'sp', 'dist', 'timeseries');
    
    acceptedBadTrial = false;
    acceptedNoiseTol = false;
    acceptedArtrem = false;
    acceptedFilter = false;
    acceptedCoeff = false;
    save(fullfile(filedir, 'progress_report.mat'), 'acceptedBadTrial', ...
        'acceptedNoiseTol', 'acceptedArtrem', 'acceptedFilter', 'acceptedCoeff');

end

