function [output] = sum_eqn_call(varargin)

    x = varargin{end};
    n = nargin - 1;
    if n == 3
        sig = varargin{1}*base_eqn_call(varargin{2}, varargin{3}, x);
    elseif n == 6
        sig = [varargin{1}*base_eqn_call(varargin{2}, varargin{3}, x);...
            varargin{4}*base_eqn_call(varargin{5}, varargin{6}, x)];
    elseif n == 9
        sig = [varargin{1}*base_eqn_call(varargin{2}, varargin{3}, x);...
            varargin{4}*base_eqn_call(varargin{5}, varargin{6}, x);...
        	varargin{7}*base_eqn_call(varargin{8}, varargin{9}, x)];
    elseif n == 12
        sig = [varargin{1}*base_eqn_call(varargin{2}, varargin{3}, x);...
            varargin{4}*base_eqn_call(varargin{5}, varargin{6}, x);...
        	varargin{7}*base_eqn_call(varargin{8}, varargin{9}, x);...
            varargin{10}*base_eqn_call(varargin{11}, varargin{12}, x)];
    else
        error('must have 3, 6, 9, or 12 inputs')
    end

    
    
    comp_len = length(sig);
    
    if comp_len <= length(x)
        output = [sig; zeros(length(x) - comp_len, 1)];
    else
        output = sig(1:length(x));
    end

end