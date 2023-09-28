function [amplitude, anode, cathode, data, fs, onsets_samps, pulse_width, ...
    badchans, goodchans, pw_data, yp, sp, ampsum, amprms, fft_vals] = ...
    newFileCalcs(filedir, filename)
%NEWFILECALCS Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Loading file...\n');
    load(fullfile(filedir, filename), 'amplitude', 'anode', 'cathode', ...
        'data', 'fs', 'onsets_samps', 'pulse_width');
    
    rs_data = extractRest(data, onsets_samps, fs);
    save(fullfile(filedir, 'rs_data.mat'), 'rs_data', '-v7.3');
    
    fprintf('Computing power spectra...\n');
    pw_data = calcPWelch(rs_data, fs);
    
    fprintf('Computing FFT...\n');
    [fft_vals, F] = calcFFT(rs_data, fs);
    
    fprintf('Epoching raw data...\n');
    [epoched, tEpoch] = epochData(data, onsets_samps, .5, 1, fs);
    
    fprintf('Fitting LF noise models...\n');
    [yval, sval, yp, sp] = calcLF(epoched, tEpoch, onsets_samps, fs);
    
    fprintf('Computing high-frequency noise values...\n');
    [ampsum, amprms] = calcHF(fft_vals, F);
    
    fprintf('Detecting bad channels...\n');
    [badchans, goodchans] = calcBadChans(rs_data, fft_vals, F);
    save(fullfile(filedir, 'badchans.mat'), 'badchans', 'goodchans');

    
    save(fullfile(filedir, 'noise_vals.mat'), 'pw_data', ...
        'yval', 'sval', 'yp', 'sp', 'ampsum', 'amprms', 'fft_vals', 'F');
    
    startup_calc = true;
    badchans_acc = false;
    noisetol_acc = false;
    artrem_calc = false;
    artrem_acc = false;
    process_calc = false;
    fitmodels_calc = false;
    fitmodels_acc = false;
    quant_calc = false;
    save(fullfile(filedir, 'progress_report.mat'), 'startup_calc', 'badchans_acc', ...
        'noisetol_acc', 'artrem_calc', 'artrem_acc', 'process_calc', ...
        'fitmodels_calc', 'fitmodels_acc', 'quant_calc');

end

