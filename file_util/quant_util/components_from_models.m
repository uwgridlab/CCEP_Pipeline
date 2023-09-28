function [pks, lats, wins, wins_alt, pktr] = components_from_models(tEpoch, sig, mdl, t10)
%COMPONENTS_FROM_MODELS pulls out the components identified by a model
%   INPUTS
%   tEpoch: trial time in s
%   sig: signal, corresponding to tEpoch (usually mean over trials)
%   mdl: best model chosen for data
%   t10: index of 10ms (set in model fitting process ? determines time to
%   be excluded)
%   OUTPUTS
%   pks: peak amplitudes of all components (4x1 array, if less than 4
%       components are identified, those values are NaN)
%   lats: latency (in samples) of all components (4x1 array, if less than 4
%       components are identified, those values are NaN)
%   wins: windows (in samples) of all components (5x1 array containing
%       n_components + 1 real values for L and R window boundaries of each
%       component, then NaN values if fewer than 4 components identified)
%   wins_alt: a different way of finding windows, just ignore
%   pktr: -1 if the component is a trough, 1 if it is a peak (4x1 array, 
%       if less than 4 components are identified, those values are NaN)
	
    coef = coeffvalues(mdl);
    n_comp = round(length(coef)/3);
    w = coef(3:3:end);
    a = coef(1:3:end);
    pol = a > 0;
    t10_val = tEpoch(t10);
    pks = nan(4, 1); lats = nan(4, 1);
    wins = nan(5, 1); pktr = nan(4, 1);
    
    for cc = 1:n_comp
        w1 = t10_val + sum(w(1:cc-1));
        w2 = t10_val + sum(w(1:cc));
        if w2 >= tEpoch(end)
            w2 = tEpoch(end - 1);
        end
        if w1 >= tEpoch(end)
            n_comp = n_comp - 1;
        else
            wins(cc) = find(tEpoch > w1, 1);
            loc_win = tEpoch >= w1 & tEpoch < w2;
            w1_idx = find(loc_win, 1);
            loc = sig(loc_win);
            if ~pol(cc)
                loc = loc*-1;
            end
            [loc_pks, loc_idx, ~, loc_prom] = findpeaks(loc);
            if ~pol(cc)
                loc_pks = loc_pks*-1;
                pktr(cc) = -1;
            else
                pktr(cc) = 1;
            end
            [~, ii] = max(loc_prom);
            pks(cc) = loc_pks(ii); lats(cc) = loc_idx(ii) + w1_idx;
        end
    end
    
    f = find(tEpoch > w2, 1);
    if ~isempty(f)
        wins(cc + 1) = f;
    else
        wins(cc + 1) = length(tEpoch);
    end
    
    
    wins_alt = nan(5, 1);
    zero_x = sig;
    zero_x(sig <= 0) = -1;
    zero_x(sig > 0) = 1;
    zero_x_diff = abs(diff(zero_x));
    x_idx = find(zero_x_diff == 2);
    for cc = 1:n_comp
        idx_diff = lats(cc) - x_idx;
        pos = find(idx_diff > 0);
        neg = find(idx_diff < 0);
        if cc == 1
            if isempty(pos)
               wins_alt(1) = find(tEpoch > .01, 1);
            else
                wins_alt(1) = x_idx(pos(end));
            end
        end
        neg = x_idx(neg);
        t002 = round(1/median(diff(tEpoch))*.002);
        neg(neg < lats(cc) + t002) = [];
        if isempty(neg)
            if cc == n_comp
                wins_alt(cc + 1) = lats(cc) + floor((length(tEpoch) - lats(cc))/2);
            else
                wins_alt(cc + 1) = lats(cc) + floor((lats(cc + 1) - lats(cc))/2);
            end
        else
            if cc < n_comp && neg(1) >= lats(cc + 1)
                wins_alt(cc + 1) = floor((lats(cc + 1) - lats(cc))/2) + lats(cc);
            else
                
                wins_alt(cc + 1) = neg(1);
            end
        end
    end
    
end

