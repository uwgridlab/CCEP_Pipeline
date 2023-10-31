function [] = SaveBadchans(fn, badchans, goodchans)
% if badchans file already exists, confirm overwrite
    if isfile(fn)
        cont = CallDialogBox('This will overwrite a previous badchans file.');
    else
        cont = true;
    end
% save bad_chans 
    if cont
        save(fn, 'badchans', 'goodchans');
    end
    
end