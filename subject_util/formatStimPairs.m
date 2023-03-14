function [stimpair_f] = formatStimPairs(stimpair)
%FORMATSTIMPAIRS Summary of this function goes here
%   Detailed explanation goes here
    stimpair_f = num2cell(stimpair, 2);
    stimpair_f = cellfun(@(x) sprintf('%d+, %d-', x(1), x(2)), ...
        stimpair_f, 'UniformOutput', false);
    stimpair_f_sub = cellfun(@(x) sprintf('%s; ', x), stimpair_f(1:end-1), ...
        'UniformOutput', false);
    stimpair_f = [stimpair_f_sub{:} stimpair_f{end}];
end

