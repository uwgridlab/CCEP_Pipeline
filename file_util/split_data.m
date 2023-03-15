function [] = split_data(data,montage,probe_names,basedir,anode,cathode,amplitude,fs,onsets_samps,pulse_width)

    data_all = data;
    anode_all = anode;
    cathode_all = cathode;
        
    for mm = 1:length(montage)
        
        idx = montage{mm};
        data = data_all(:, idx);
        
        anode = repmat(length(idx) + 1, size(anode_all));
        cathode = repmat(length(idx) + 2, size(cathode_all));
        
        if any(ismember(idx, anode_all)) || any(ismember(idx, cathode_all))
            a_idx = anode_all == idx;
            c_idx = cathode_all == idx;
            for ii = 1:length(idx)
                anode(a_idx(:, ii)) = ii;
                cathode(c_idx(:, ii)) = ii;
            end
        end
        
        save([basedir probe_names{mm} '-4.mat'], 'data', 'anode', 'cathode', ...
            'amplitude', 'fs', 'onsets_samps', 'pulse_width', '-v7.3');
        
    end

end

