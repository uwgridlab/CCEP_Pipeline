function [] = SaveArtremParams(fn, artrem_table, BR, DM, PP, accepted_ch, ...
    templateArrayCell, startInds, endInds, maxLocation)
% if artrem_param file already exists, confirm overwrite
    if isfile(fn)
        cont = CallDialogBox('This will overwrite a previous artrem parameter file.');
    else
        cont = true;
    end
% save artrem_param file
    if cont
        save(fn, 'artrem_table', 'accepted_ch', 'BR', 'DM', 'PP', ...
            'templateArrayCell', 'startInds', 'endInds', 'maxLocation');
    end
end