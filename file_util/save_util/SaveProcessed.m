function [] = SaveProcessed(fn, data, tEpoch, amplitude, anode, cathode, ...
    fs, onsets_samps, hp, lp, n60, n120, n180, bl, rr)
% if processed data file already exists under the specified name, confirm overwrite
    if isfile(fn)
        cont = CallDialogBox('This will overwrite a previous filtered data file.');
    else
        cont = true;
    end
% save processed data under specified file name
    if cont
        proc_params.HP = hp; proc_params.LP = lp;  proc_params.N = [n60 n120 n180];
        proc_params.BL = bl; proc_params.RR = rr;
        save(fn, 'data', 'tEpoch', 'amplitude', 'anode', 'cathode', 'fs', ...
            'onsets_samps', 'proc_params', '-v7.3')
    end
end