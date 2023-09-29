function [] = SaveModelData(fn, t, models_fit, r2)
% if model_data file already exists, confirm overwrite
    if isfile(fn)
        cont = CallDialogBox('This will overwrite a previous model data file.');
    else
        cont = true;
    end
% save model_data file
    if cont
        save(fn, 't', 'models_fit', 'r2');
% update progress report
        
    end
end