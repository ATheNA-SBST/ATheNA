function fitess(t, u, y)

%If at the end of the cycle the input flow rate changes rapidly between
%time points, and starts at an extreme (3.98 or 4.02) the fitness will be
%very low
fit = abs(u(20) - u(19)) + abs(u(19) - u(18)) + abs(u(18) - u(17)) + 10*abs(4-u(17));

return fit*-1