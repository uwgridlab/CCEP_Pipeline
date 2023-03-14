function [ret, fn] = hasValidRawFile(filedir)
%HASVALIDDATAFILE Summary of this function goes here
%   Detailed explanation goes here

    d = dir(filedir);
    isdat = cellfun(@(x) contains(x, '.mat'), {d.name});
    isdat = find(isdat);
    if isempty(isdat)
        ret = false;
        fn = '';
    else
        isval = false(1, length(isdat));
        for ff = 1:length(isdat)
            v = who('-file', fullfile(d(isdat(ff)).folder, d(isdat(ff)).name));
            isval(ff) = isequal(v, {'data'});
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

