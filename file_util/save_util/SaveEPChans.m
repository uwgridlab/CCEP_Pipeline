function [] = SaveEPChans(fn, EPchans)
    if isfile(fn)
        cont = CallDialogBox('This will overwrite a previous model parameter file');
    else
        cont = true;
    end
% save model_param file
    if cont
        save(fn, 'EPchans');
    end
end

