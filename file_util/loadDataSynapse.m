function [data, fs] = loadDataSynapse(dataStruct, montage)

    % given a data structure and montage, pull the data associated with
    % montage channels from ECO# fields
    
    % Synapse data is stored in a single structure, with subfields for ECOG
    % in the substructure "streams"
    % data in each ECO field is stored as channels x time points
    
    ff = fieldnames(dataStruct);
    ecoStruct = cellfun(@(x) ~isempty(x), regexp(ff, 'ECO'));
    
    % pull data from all fields named ECO# IN ORDER
    structOrd = sort(ff(ecoStruct));
    data = [];
    for ii = 1:length(structOrd)
        d = dataStruct.(structOrd{ii}).data;
        if size(d, 2) > size(data, 2)
            data = padarray(data, [0 size(d, 2) - size(data, 2)], 0, 'post');
            warning('Zero padding to equalize data structure length');
        elseif size(d, 2) < size(data, 2)
            d = padarray(d, [0, size(data, 2) - size(d, 2)], 0, 'post');
            warning('Zero padding to equalize data structure length');
        end
        data = [data; d]; % vertcat for synapse
    end
    
    % get sampling rate from one of the ECO structures
    fs = dataStruct.(ff{find(ecoStruct, 1)}).fs;

    % extract only montage channels
    data_mont = data([montage{:}], :)';
    
    % add placeholder for skipped channels
    data = nan(length(data_mont), max([montage{:}]));
    data(:, [montage{:}]) = data_mont;
end

