function [badchans, goodchans] = calcBadChans(rs_data, fft_vals, F)
%AUTOBADCHANS Summary of this function goes here
%   Detailed explanation goes here

    nanchan = any(isnan(rs_data));
    
    rs_diff = diff(rs_data);
    zsc = (rs_diff - mean(rs_diff))./std(rs_diff);
    zchan = sum(zsc >= 10) >= 10;
    
    F_use = F >= 59 & F <= 61;
    amp60 = max(fft_vals(F_use, :));
    ampchan = amp60 >= 0.8;
    
    badchans = find(nanchan | zchan | ampchan);
    goodchans = find(~nanchan & ~zchan & ~ampchan);

end
