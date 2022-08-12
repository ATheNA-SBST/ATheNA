function fitness = customAT53(t, u, y)
%% Try to falsify requirement AT5-3: []_[0, 30] ((!(gear = 3) /\ <>_[0.001,0.1] (gear = 3))-> <>_[0.001,0.1] []_[0.0,2.5] (gear = 3))

global Athena_param;
fitness = -min(u(1:7))/Athena_param.InRange(1,2);
fitness = fitness+max(u(8:end))/Athena_param.InRange(2,2);

end