function [badchans, goodchans] = autoBadChans(rs_data)
%AUTOBADCHANS Summary of this function goes here
%   Detailed explanation goes here

    nanchan = any(isnan(rs_data));
    zsc = (rs_data - mean(rs_data))./std(rs_data);
    zchan = any(zsc >= 10);
    
    badchans = find(nanchan | zchan);
    goodchans = find(~nanchan & ~zchan);

end

