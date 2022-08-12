function fitness = customAT6ABC(t, u, y)
%% Try to falsify requirement AT6ABC: AT6A /\ AT6B /\ AT6C

global Athena_param;
global staliro_opt
global staliro_SimulationTime

% Integral mean
dt = mean(diff(t));
throttle_interp = feval(staliro_opt.interpolationtype{1},linspace(0,staliro_SimulationTime,7),u(1:7),t);
brake_interp = feval(staliro_opt.interpolationtype{2},linspace(0,staliro_SimulationTime,3),u(8:end),t);
throttleContribution = abs(sum(throttle_interp(t <= 30))*dt/30-45)/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
brakeContribution = (sum(brake_interp(t <= 30))*dt/30-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness = brakeContribution/2 + throttleContribution;

end