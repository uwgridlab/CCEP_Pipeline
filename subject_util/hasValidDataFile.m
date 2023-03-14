function [ret, fn] = hasValidDataFile(filedir)
%HASVALIDDATAFILE Summary of this function goes here
%   Detailed explanation goes here

    d = dir(filedir);
    isdat = cellfun(@(x) contains(x, '_dat.mat'), {d.name});
    isdat = find(isdat);
    if isempty(isdat)
        ret = false;
        fn = '';
    else
        isval = false(1, length(isdat));
        for ff = 1:length(isdat)
            v = who('-file', fullfile(d(isdat(ff)).folder, d(isdat(ff)).name));
            isval(ff) = any(ismember(v, 'amplitude')) && ...
                any(ismember(v, 'anode')) && any(ismember(v, 'cathode')) &&...
                any(ismember(v, 'data')) && any(ismember(v, 'fs')) &&...
                any(ismember(v, 'onsets_samps')) && any(ismember(v, 'pulse_width'));
        end
        if sum(isval) == 0
            ret = false;
            fn = '';
        else
            ret = true;
            fn = {d(isdat(isval)).name};
        end
    end

end

