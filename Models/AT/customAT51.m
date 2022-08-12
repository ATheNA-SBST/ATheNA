function fitness = customAT51(t, u, y)
%% Try to falsify requirement AT5-1: []_[0, 30] ((!(gear = 1) /\ <>_[0.001,0.1] (gear = 1))-> <>_[0.001,0.1] []_[0.0,2.5] (gear = 1))

global Athena_param;
fitness = 1-min(u(1:5))/Athena_param.InRange(1,2);
fitness = fitness+max(u(8:9))/Athena_param.InRange(2,2);

end