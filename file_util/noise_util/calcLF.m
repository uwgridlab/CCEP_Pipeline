function [yval, sval, yp, sp] = calcLF(epoched, tEpoch, onsets_samps, fs)
%CALCLF Summary of this function goes here
%   Detailed explanation goes here

    bl = tEpoch >= -0.4 & tEpoch <= -0.1;
    blvals = squeeze(median(epoched(bl, :, :)));
        
    onsets_t = onsets_samps/fs;
    
    yval = nan(size(epoched, 2), 1); sval = nan(size(epoched, 2), 1);
    yp = nan(size(epoched, 2), 1); sp = nan(size(epoched, 2), 1);

    for cc = 1:size(epoched, 2)
        if ~any(isnan(blvals(cc, :)))
            cc_blvals = blvals(cc, :);
            mdl = fitlm(onsets_t, cc_blvals);
            yval(cc) = mdl.Coefficients{"(Intercept)", "Estimate"};
            yp(cc) = mdl.Coefficients{"(Intercept)", "pValue"};
            sval(cc) = mdl.Coefficients{"x1", "Estimate"};
            sp(cc) = mdl.Coefficients{"x1", "pValue"};
        end
    end

end

