function [ret, fn, ret_inc, fn_inc] = getSubjectFolders(subjdir)
%GETSUBJECTFOLDERS Summary of this function goes here
%   Detailed explanation goes here

    d = dir(subjdir);
    d = {d([d.isdir]).name};
    d = d(3:end);
    ret = false(size(d)); fn = cell(size(d));
    ret_inc = false(size(d)); fn_inc = cell(size(d));
    for dd = 1:length(d)
        [ret(dd), fn{dd}] = hasValidDataFile(fullfile(subjdir, d{dd})); 
        if ~ret(dd)
            [ret_inc(dd), fn_inc{dd}] = hasValidRawFile(fullfile(subjdir, d{dd}));
        end
    end
    fn = fn(ret);
    ret = d(ret);
    fn_inc = fn_inc(ret_inc);
    ret_inc = d(ret_inc);
    if any(cellfun(@length, fn) > 1)
        warning('More than one _dat file detected in a folder for subject path %s, delete and refresh to prevent ambiguity', subjdir)
    else
        fn = cellfun(@(x) x{1}, fn, 'UniformOutput', false);
    end

end

