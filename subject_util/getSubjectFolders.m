function [ret, fn] = getSubjectFolders(subjdir)
%GETSUBJECTFOLDERS Summary of this function goes here
%   Detailed explanation goes here

    d = dir(subjdir);
    d = {d([d.isdir]).name};
    d = d(3:end);
    ret = false(size(d)); fn = cell(size(d));
    for dd = 1:length(d)
        [ret(dd), fn{dd}] = hasValidDataFile(fullfile(subjdir, d{dd})); 
    end
    fn = fn(ret);
    ret = d(ret);
    if any(cellfun(@length, fn) > 1)
        error('Only one _dat file allowed per folder')
    else
        fn = cellfun(@(x) x{1}, fn, 'UniformOutput', false);
    end

end

