function [pks] = peaks_from_lats(data, lats)
% given the latency, returns the amplitudes

    lats = lats(~isnan(lats));
    pks = nan(4, 1);
    pks(1:length(lats)) = data(lats);

end

