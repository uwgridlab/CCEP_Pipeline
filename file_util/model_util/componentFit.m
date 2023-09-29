function [data_out, n_out, pol_out, f_out, rval_out] = componentFit(sig, tEpoch, varargin)
%COMPONENT_FIT
%   sig: average signal, centered around 0 (baseline subtracted)
%   tEpoch: epoch timing with stimulation onset at tEpoch = 0
%   f_loc: model fits
%   gof_loc: goodness of model fits

    p = inputParser;
    addRequired(p, 'sig', @isnumeric);
    addRequired(p, 'tEpoch', @isnumeric);
    
    addParameter(p, 'cmin', [0.015 0.015 0.05  0.05], @isnumeric);
    addParameter(p, 'cmax', [0.5 0.5 0.5 0.5], @isnumeric);
    addParameter(p, 'cstr', [0.05 0.05 0.5 0.5], @isnumeric);
    addParameter(p, 'numc', [], @isnumeric);
    addParameter(p, 'pol', [], @islogical);
    
    p.parse(sig, tEpoch, varargin{:});
    sig = p.Results.sig; tEpoch = p.Results.tEpoch;
    cmin = p.Results.cmin; cmax = p.Results.cmax; cstr = p.Results.cstr;
    numc = p.Results.numc; pol = p.Results.pol;

    f_loc = cell(1, 8); gof_loc = cell(1, 8);

    % exclude 10ms
    t10 = tEpoch > 0.01;
    t10 = find(t10, 1);
    xxx = tEpoch(t10:end)' - tEpoch(t10);
    sig = sig(t10:end);

    % set up equations to fit
    sum_eqn_4 = @(a1,t1,w1,a2,t2,w2,a3,t3,w3,a4,t4,w4,x) ...
        sum_eqn_call(a1,t1,w1,a2,t2,w2,a3,t3,w3,a4,t4,w4,x);
    sum_eqn_3 = @(a1,t1,w1,a2,t2,w2,a3,t3,w3,x) sum_eqn_call(a1,t1,w1,a2,t2,w2,a3,t3,w3,x);
    sum_eqn_2 = @(a1,t1,w1,a2,t2,w2,x) sum_eqn_call(a1,t1,w1,a2,t2,w2,x);
    sum_eqn_1 = @(a1,t1,w1,x) sum_eqn_call(a1,t1,w1,x);

    % compile all min, max, start points for component fitting
    mmin = min(sig); mmax = max(sig);
    if mmax < 0.1
        mmax = 0.1;
    end
    if mmin > -0.1
        mmin = -0.1;
    end
    lwr_negpos =   [ mmin -0.9  cmin(1)  0.1  -0.9  cmin(2)  mmin -0.9  cmin(3)  0.1  -0.9  cmin(4)];
    upr_negpos =   [-0.1   0.9  cmax(1)  mmax  0.9  cmax(2) -0.1   0.9  cmax(3)  mmax  0.9  cmax(4)];
    start_negpos = [ 1     0.01 cstr(1) -1     0.01 cstr(2)  1     0.01 cstr(3) -1     0.01 cstr(4)];
    lwr_posneg =   [ 0.1  -0.9  cmin(1)  mmin -0.9  cmin(2)  0.1  -0.9  cmin(3)  mmin -0.9  cmin(4)];
    upr_posneg =   [ mmax  0.9  cmax(1) -0.1   0.9  cmax(2)  mmax  0.9  cmax(3) -0.1   0.9  cmax(4)];
    start_posneg = [ 1     0.01 cstr(1) -1     0.01 cstr(2)  1     0.01 cstr(3) -1     0.01 cstr(4)];

    if ~isempty(numc) && ~isempty(pol)
        if pol
            idx_use = 2*(4 - numc + 1);
        else
            idx_use = 2*(4 - numc) + 1;
        end
    else
        idx_use = 1:8;
    end
    
    if ismember(1, idx_use)
        [f_loc{1},gof_loc{1}] = fit(xxx, sig, sum_eqn_4, 'lower', ...
            lwr_negpos, 'upper', upr_negpos, 'start', start_negpos);
    end
    if ismember(2, idx_use)
    [f_loc{2},gof_loc{2}] = fit(xxx, sig, sum_eqn_4, 'lower', ....
        lwr_posneg, 'upper', upr_posneg, 'start', start_posneg);
    end
    if ismember(3, idx_use)
    [f_loc{3},gof_loc{3}] = fit(xxx, sig, sum_eqn_3, 'lower', ...
        lwr_negpos(1:9), 'upper', upr_negpos(1:9), 'start', start_negpos(1:9));
    end
    if ismember(4, idx_use)
    [f_loc{4},gof_loc{4}] = fit(xxx, sig, sum_eqn_3, 'lower', ....
        lwr_posneg(1:9), 'upper', upr_posneg(1:9), 'start', start_posneg(1:9));
    end
    if ismember(5, idx_use)
    [f_loc{5},gof_loc{5}] = fit(xxx, sig, sum_eqn_2, 'lower', ...
        lwr_negpos(1:6), 'upper', upr_negpos(1:6), 'start', start_negpos(1:6));
    end
    if ismember(6, idx_use)
    [f_loc{6},gof_loc{6}] = fit(xxx, sig, sum_eqn_2, 'lower', ....
        lwr_posneg(1:6), 'upper', upr_posneg(1:6), 'start', start_posneg(1:6));
    end
    if ismember(7, idx_use)
    [f_loc{7},gof_loc{7}] = fit(xxx, sig, sum_eqn_1, 'lower', ...
        lwr_negpos(1:3), 'upper', upr_negpos(1:3), 'start', start_negpos(1:3));
    end
    if ismember(8, idx_use)
    [f_loc{8},gof_loc{8}] = fit(xxx, sig, sum_eqn_1, 'lower', ....
        lwr_posneg(1:3), 'upper', upr_posneg(1:3), 'start', start_posneg(1:3));
    end

    if length(idx_use) == 1
        rval_out = gof_loc{idx_use}.rsquare;
        f_out = f_loc{idx_use};
        idx = idx_use;
    else
        rvals = cellfun(@(x) x.rsquare, gof_loc);
        [rval_out, idx] = max(rvals);
        f_out = f_loc{idx};
    end    
    
    if idx <= 2
        data_out = sum_eqn_4(f_out.a1, f_out.t1, f_out.w1, ...
            f_out.a2, f_out.t2, f_out.w2, f_out.a3, f_out.t3, f_out.w3, ...
            f_out.a4, f_out.t4, f_out.w4, xxx);
        n_out = 4;
    elseif idx <= 4
        data_out = sum_eqn_3(f_out.a1, f_out.t1, f_out.w1, ...
            f_out.a2, f_out.t2, f_out.w2, f_out.a3, f_out.t3, f_out.w3, xxx);
        n_out = 3;
    elseif idx <= 6
        data_out = sum_eqn_2(f_out.a1, f_out.t1, f_out.w1, ...
            f_out.a2, f_out.t2, f_out.w2, xxx);
        n_out = 2;
    else
        data_out = sum_eqn_1(f_out.a1, f_out.t1, f_out.w1, xxx);
        n_out = 1;
    end
    
    pol_out = mod(idx, 2) == 0;

end

