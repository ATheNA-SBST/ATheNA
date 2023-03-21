function fitness(t,u,y)

%if throttle is larger than brake, this function yields a larger negative
%number whenever vehicle 1 and 2 are close together
if u(1) > u(8)
fit = -u(1) / (y(2) - y(1))

%if brake is larger than throttle, this function yields a larger negative 
% number whenver vehicle 1 and 2 are far apart  
else u(8) < u(1)
fit = -u(8) * (y(1) - y(2))

end

%If I had more time there would be a way to incorporate all time stamps

return fit 