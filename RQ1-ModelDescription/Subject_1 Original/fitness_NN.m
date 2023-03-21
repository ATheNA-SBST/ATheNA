%This function tries to maximize the position error at the middle control
%point, then multiplies this by the difference between the 2nd and 3rd, and
%1st and 2nd points, with larger differences being optimal. Lastly, it
%multiplies by the absolute difference of these points with 2, with more
%extreme positions being favoured
fitness = abs(y(1,20)) * ((u(2)-u(1)) + u(3)-u(2)) * abs(u(1) - 2) * abs(u(3) - 2);
    % y(t==20,1) == y(1,20)
