function [dist, timeseries] = calcHF(rs_data)
%CALCHF Summary of this function goes here
%   Detailed explanation goes here

    goodchans = find(~any(isnan(rs_data)));
    
    timeseries = nan(size(rs_data, 1) - 1, size(rs_data, 2));
    timeseries(:, goodchans) = diff(rs_data(:, goodchans))./std(rs_data(:, goodchans));
    dist = timeseries(:); dist(isnan(dist)) = [];

end

