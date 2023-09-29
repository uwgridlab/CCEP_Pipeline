function [ret] = CallDialogBox(msg)
    c = dialogbox(msg);
    waitfor(c, 'cont'); ret = c.cont; delete(c);
end

