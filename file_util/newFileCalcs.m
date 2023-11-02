function [amplitude, anode, cathode, data, fs, onsets_samps, rs_idx, pulse_width, ...
    badchans, goodchans, pw_data, yp, sp, ampsum, amprms, fft_vals] = ...
    newFileCalcs(filedir, filename, montagefile, txt)
%NEWFILECALCS Summary of this function goes here
%   Detailed explanation goes here

    txt.Value = vertcat({'Loading file...'}, txt.Value); pause(0.001);
    load(fullfile(filedir, filename), 'amplitude', 'anode', 'cathode', ...
        'data', 'fs', 'onsets_samps', 'pulse_width', 'monA');
    load(montagefile, 'idx');
    
    [rs_data, rs_idx] = extractRest(data, onsets_samps, monA, fs, txt);
    save(fullfile(filedir, 'rs_data.mat'), 'rs_data', 'rs_idx', '-v7.3');
    
    txt.Value = vertcat({'Computing power spectra...'}, txt.Value); pause(0.001);
    pw_data = calcPWelch(rs_data, fs);
    
    txt.Value = vertcat({'Computing FFT...'}, txt.Value); pause(0.001);
    [fft_vals, F] = calcFFT(rs_data, fs);
    
    txt.Value = vertcat({'Epoching raw data...'}, txt.Value); pause(0.001);
    [epoched, tEpoch] = epochData(data, onsets_samps, .5, 1, fs);
    
    txt.Value = vertcat({'Fitting LF noise models...'}, txt.Value); pause(0.001);
    [yval, sval, yp, sp] = calcLF(epoched, tEpoch, onsets_samps, fs);
    
    txt.Value = vertcat({'Computing high-frequency noise values...'}, ...
        txt.Value);
    [ampsum, amprms] = calcHF(fft_vals, F);
    
    txt.Value = vertcat({'Detecting bad channels...'}, txt.Value); pause(0.001);
    [badchans, goodchans] = calcBadChans(rs_data, idx);
    save(fullfile(filedir, 'badchans.mat'), 'badchans', 'goodchans');
    
    txt.Value = vertcat({'Saving noise values...'}, txt.Value); pause(0.001);
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

