function [ampsum, amprms] = calcHF(fft_vals, F)
%CALCHF Summary of this function goes here
%   Detailed explanation goes here

    F_use = F >= 250 & F <= 2000;
    ampsum = sum(fft_vals(F_use, :));
    amprms = rms(fft_vals(F_use, :));

end

