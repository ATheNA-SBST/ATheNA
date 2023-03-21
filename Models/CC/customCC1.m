function fitness = customCC1(t, u, y)
%% Try to falsify requirement CC1: []_[0,100] (y5-y4 < 40)

global Athena_param;
throttleContribution = (min(u(1:7))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
brakeContribution = (max(u(8:end))-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness = (1 - throttleContribution) + brakeContribution/2;

end