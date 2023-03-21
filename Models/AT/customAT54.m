function fitness = customAT54(t, u, y)
%% Try to falsify requirement AT5-4: []_[0, 30] ((!(gear = 4) /\ <>_[0.001,0.1] (gear = 4))-> <>_[0.001,0.1] []_[0.0,2.5] (gear = 4))

global Athena_param;
throttle_fit = max(abs(u(1:3)-[85;25;100]))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
brake_fit = max(abs(u(8:10)-[0;200;0]))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness = (throttle_fit+brake_fit)/2;

end