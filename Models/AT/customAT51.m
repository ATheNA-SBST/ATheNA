function fitness = customAT51(t, u, y)
%% Try to falsify requirement AT5-1: []_[0, 30] ((!(gear = 1) /\ <>_[0.001,0.1] (gear = 1))-> <>_[0.001,0.1] []_[0.0,2.5] (gear = 1))

global Athena_param;
% throttle_fit = max(abs(u(1:3)-[37;0;50]))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
throttle_fit = max(abs(u(1:3)-[35;0;50]))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
brake_fit = 1-(mean(u(8:9))-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness = (throttle_fit+brake_fit)/2;

end