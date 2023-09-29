function [output] = base_eqn_call(t,w,x)
%BASE_EQN Summary of this function goes here

    if size(x, 1) <= 2 && size(x, 2) <= 2
        output = zeros(size(x));
    else
        if size(x, 1) == 1 && size(x, 2) > 1
            x = x';
        end
        output = (1/t)*atan((t*sin(2*pi*(1/w/2)*x(x <= w)))./(1 - t*(cos(2*pi*(1/w/2)*x(x <= w)))));
    end
    

end
