function [] = SaveFilterOpts(fn, HP, LP, NF, N)
% if filter options file already exists, confirm overwrite
    if isfile(fn)
        cont = app.CallDialogBox('This will overwrite a previous filter options file.');
    else
        cont = true;
    end
% save options in filter_opts
    if cont
        save(fn, 'HP', 'N', 'LP', 'NF');
    end
end

