function [pw_data] = calcPWelch(rs_data, fs)
%CALCPWELCH Summary of this function goes here
%   Detailed explanation goes here

    pw_data = nan(2000, size(rs_data, 2));
    goodchans = find(~any(isnan(rs_data)));
    
    pw_data(:, goodchans) = pwelch(rs_data(:, goodchans), round(10*fs), round(2*fs), 1:2000, fs);
    pw_data = 10*log10(pw_data);

end

