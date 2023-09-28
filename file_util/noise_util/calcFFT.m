function [fft_vals, F] = calcFFT(rs_data,fs)

    if mod(length(rs_data), 2) ~= 0
        rs_data = rs_data(1:end-1, :);
    end
    
    L = length(rs_data); F = (fs*(0:(L/2))/L)';
    fft_vals = fft(zscore(rs_data));
    fft_vals = abs(fft_vals/L);
    fft_vals = fft_vals(1:(L/2)+1, :); 
    fft_vals(2:end, :) = 2*fft_vals(2:end, :);
    
    F_use = F <= 2000;
    F = F(F_use); fft_vals = fft_vals(F_use, :);

end

