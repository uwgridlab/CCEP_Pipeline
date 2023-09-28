function [data_out] = baselineSubtract(data, tEpoch, minval, maxval)

    t_use = tEpoch >= minval & tEpoch <= maxval;
    bl = data(t_use, :, :);
    bl_mn_loc = mean(bl);
    bl_std_comb = nan(1, size(data, 2));
    for ii = 1:size(data, 2)
        bl_loc = squeeze(bl(:, ii, :));
        bl_loc = bl_loc(:);
        if ~all(isnan(bl_loc))
            bl_std_comb(ii) = std(bl_loc);
        end
    end
    
    data_out = (data - bl_mn_loc)./bl_std_comb;

end

