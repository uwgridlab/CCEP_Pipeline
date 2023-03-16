function [timeseries] = calcHF(epoched, tEpoch)
%CALCHF Summary of this function goes here
%   Detailed explanation goes here

    bl = tEpoch >= -0.4 & tEpoch <= -0.1;
    blvals = squeeze(median(abs(diff(epoched(bl, :, :)))));
    blvals = blvals./squeeze(std(epoched(bl, :, :)));

%     goodchans = find(~any(isnan(rs_data)));
%     
%     timeseries = nan(size(rs_data, 1) - 1, size(rs_data, 2));
%     timeseries(:, goodchans) = diff(rs_data(:, goodchans))./std(rs_data(:, goodchans));

end

