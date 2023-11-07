function [] = SaveArtremData(fn, data_artrem, prepost)
% if artrem_data file already exists, confirm overwrite
    if isfile(fn)
        cont = CallDialogBox('This will overwrite a previous artrem data file.');
    else
        cont = true;
    end
% save artrem_data file
    if cont
        save(fn, 'data_artrem', 'prepost', '-v7.3');
    end
end