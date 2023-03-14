function [ret, fn] = hasValidMontage(subjdir)
%HASVALIDMONTAGE Summary of this function goes here
%   Detailed explanation goes here

    d = dir(subjdir);
    cont_mont = cellfun(@(x) contains(x, 'Montage'), {d.name});
    cont_mont = find(cont_mont);
    
    if isempty(cont_mont)
        ret = false;
        fn = '';
    else
        isval = false(1, length(cont_mont));
        for ff = 1:length(cont_mont)
            v = who('-file', fullfile(d(cont_mont(ff)).folder, d(cont_mont(ff)).name));
            isval(ff) = any(ismember(v, 'probes')) && any(ismember(v, 'chans')) ...
                && any(ismember(v, 'idx'));
        end
        if sum(isval) == 0
            ret = false;
            fn = '';
        else
            ret = true;
            fn = d(cont_mont(isval(1))).name;
            if length(isval) > 1
                warning('Multiple montages found, using %s', fn);
            end
        end
    end

end

