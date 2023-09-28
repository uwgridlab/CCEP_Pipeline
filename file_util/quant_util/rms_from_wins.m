function [rms_out] = rms_from_wins(data, wins)
% given data and windows, returns the RMS in each window
% returns a 4x1 array containing RMS values for each window and NaNs if
% fewer than 4 windows are identified

    rms_out = nan(1, 4);
    for ii = 1:sum(~isnan(wins)) - 1
        loc = data(wins(ii):wins(ii + 1));
        rms_out(ii) = rms(loc);
    end

end

