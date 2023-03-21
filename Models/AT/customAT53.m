function fitness = customAT53(t, u, y)
%% Try to falsify requirement AT5-3: []_[0, 30] ((!(gear = 3) /\ <>_[0.001,0.1] (gear = 3))-> <>_[0.001,0.1] []_[0.0,2.5] (gear = 3))

global Athena_param;
% throttle_fit = max(abs(u(1:3)-[100;15;0]))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
throttle_fit = max(abs(u(1:3)-[100;20;0]))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
brake_fit = max(abs(u(8:9)-Athena_param.InRange(2,1)))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness = (throttle_fit+brake_fit)/2;

end