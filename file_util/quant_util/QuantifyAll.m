function [] = QuantifyAll(fn, nchan, tEpoch, EPmean, ...
    EPmedian, EPch, ModelEqn, chck, txt, Data)

    t10 = find(tEpoch >= 0.01, 1);
    EP_wins = nan(nchan, 5);
    EP_mean_amp = nan(nchan, 4); EP_mean_lat = EP_mean_amp; 
    EP_pktr = EP_mean_amp; EP_mean_RMS = EP_mean_amp;
    EP_median_amp = nan(nchan, 4); EP_median_lat = EP_median_amp; 
    EP_median_compmatch = EP_median_amp; EP_median_RMS = EP_median_amp;
    EP_trial_amp = nan(nchan, 4, size(Data, 3));
    EP_trial_lat = EP_trial_amp; EP_trial_RMS = EP_trial_amp; EP_trial_compmatch = EP_trial_amp;
    ct = 1;
    for ch = EPch
        txt.Value = vertcat({sprintf('Quantifying channel %d of %d', ...
            ct, length(EPch))}, txt.Value); pause(0.01);
        [EP_mean_amp(ch, :), EP_mean_lat(ch, :), EP_wins(ch, :), ~, EP_pktr(ch, :)] = ...
            components_from_models(tEpoch, EPmean(:, ch), ModelEqn{ch}, t10);
        EP_mean_RMS(ch, :) = rms_from_wins(EPmean(:, ch), EP_wins(ch, :));
        [EP_median_amp(ch, :), EP_median_lat(ch, :), EP_median_compmatch(ch, :)] = ...
            peaks_from_wins(EPmedian(:, ch), EP_wins(ch, :), EP_pktr(ch, :));
        EP_median_RMS(ch, :) = rms_from_wins(EPmedian(:, ch), EP_wins(ch, :));
        chck_loc = chck(:, ch); chck_loc(isnan(chck_loc)) = 0;
        chck_loc = logical(chck_loc);
        for trial = find(chck_loc')
            [EP_trial_amp(ch, :, trial), EP_trial_lat(ch, :, trial), EP_trial_compmatch(ch, :, trial)] = ...
                peaks_from_wins(Data(:, ch, trial), EP_wins(ch, :), EP_pktr(ch, :));
            EP_trial_RMS(ch, :,  trial) = rms_from_wins(Data(:, ch, trial), EP_wins(ch, :));
        end
        ct = ct + 1;
    end

    EP_mean = EPmean; EP_median = EPmedian; EP_tEpoch = tEpoch;
    
    txt.Value = vertcat({'SAVING...'}, txt.Value); pause(0.01);
    save(fn, 'EP_*');
    txt.Value = vertcat({'Save complete!'}, txt.Value); pause(0.01);
end

