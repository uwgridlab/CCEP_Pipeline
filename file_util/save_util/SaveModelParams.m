function [] = SaveModelParams(fn, eqns, cmin, cmax, cstart, ncomp, pol, EPchans)
% if model_param file already exists, confirm overwrite
    if isfile(fn)
        cont = app.CallDialogBox('This will overwrite a previous model parameter file');
    else
        cont = true;
    end
% save model_param file
    if cont
        save(fn, 'eqns', 'cmin', 'cmax', 'cstart', 'ncomp', 'pol', 'EPchans');
    end
end