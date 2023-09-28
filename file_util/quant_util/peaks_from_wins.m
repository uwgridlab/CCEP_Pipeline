function [amps, lats, compmatch] = peaks_from_wins(data, wins, pktr)
% PEAKS_FROM_WINS identifies the most prominent peak within each window
%   INPUTS
%   data: single trial data vector
%   wins: windows in samples (5x1 vector with NaNs if fewer than 4
%       components are identified)
%   pktr: -1 if trough, 1 if peak (4x1 vector with NaNs if fewer than 4
%       components are identified)
%   OUTPUTS
%   amps: amplitude of most prominent peak/trough within each window
%   lats: latency of most prominent peak/trough within each window
%   compmatch: false if there is no peak or trough that matches the
%       polarity identified in pktr, true otherwise

    n_comp = sum(~isnan(pktr));
    
    amps = nan(4, 1); lats = nan(4, 1); compmatch = nan(4, 1);
    
    % LOOP THROUGH COMPONENTS
    for cc = 1:n_comp
        % determine if there is a peak or trough within window
        cc_data = data(wins(cc):wins(cc + 1) - 1);
        % limit to polarity of mean
        cc_data = cc_data*pktr(cc);
        % findpeaks
        [~, cc_lats, ~, cc_prom] = findpeaks(cc_data);
        if ~isempty(cc_lats)
            [~, cc_idx] = max(cc_prom);
            lats(cc) = cc_lats(cc_idx) + wins(cc) - 1;
            amps(cc) = data(lats(cc));
            compmatch(cc) = 1;
        else
            compmatch(cc) = 0;
        end
        % max
%         if max(cc_data) < 0
%             compmatch(cc) = 0;
%         else
%             compmatch(cc) = 1;
%             [amps(cc), lats(cc)] = max(cc_data);
%             lats(cc) = lats(cc) + wins(cc) - 1;
%         end
    end

end

