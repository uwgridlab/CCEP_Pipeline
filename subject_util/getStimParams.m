function [stimpair,t] = getStimParams(subjdir, ret,fn)
%GETSTIMPARAMS Summary of this function goes here
%   Detailed explanation goes here
    stimpair = cell(size(ret)); t = zeros(size(ret));
    for ff = 1:length(ret)
        load(fullfile(subjdir, ret{ff}, fn{ff}), 'anode', 'cathode')
        stimpair{ff} = unique([cathode anode], 'rows');
        t(ff) = length(cathode);
    end
end

