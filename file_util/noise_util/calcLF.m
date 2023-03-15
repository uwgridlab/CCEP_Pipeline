function [ypct, spct, yval, sval, yp, sp] = calcLF(data, onsets_samps, fs)
%CALCLF Summary of this function goes here
%   Detailed explanation goes here

    onsets_t = onsets_samps/fs;
    
    badchans = find(any(isnan(data)));
    
    yval = nan(size(data, 2), 1); sval = nan(size(data, 2), 1);
    yp = nan(size(data, 2), 1); sp = nan(size(data, 2), 1);

    for cc = 1:size(data, 2)
        if ~ismember(cc, badchans)
            cc_blvals = nan(size(onsets_samps));
            for tt = 1:length(onsets_samps)
                cc_blvals(tt) = median(data((onsets_samps(tt) - round(0.4*fs)): ...
                    (onsets_samps(tt) - round(0.1*fs)), cc));
            end
            mdl = fitlm(onsets_t, cc_blvals);
            yval(cc) = mdl.Coefficients{"(Intercept)", "Estimate"};
            yp(cc) = mdl.Coefficients{"(Intercept)", "pValue"};
            sval(cc) = mdl.Coefficients{"x1", "Estimate"};
            sp(cc) = mdl.Coefficients{"x1", "pValue"};
        end
    end
    
    cutoff = fdr([yp; sp], .05);
    ypct = sum(yp(~isnan(yp)) <= cutoff)/sum(~isnan(yp));
    spct = sum(sp(~isnan(sp)) <= cutoff)/sum(~isnan(sp));

end

