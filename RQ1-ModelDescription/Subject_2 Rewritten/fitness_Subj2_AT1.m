function fitness = fitness_Subj2_AT1(t,u,y)
%% AT
%at time 0, set brake to 0 and throttle to 110
%center scale the vehicle speed output
%prioritize high vehicle speed
global Athena_param;

fitness_array(1) = (Athena_param.InRange(1,2)-u(t == 0, 1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness_array(2) = (u(t == 0, 2)-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness_array(3) = (Athena_param.OutRange(1,2)-mean(y(:, 1)))/(Athena_param.OutRange(1,2)-Athena_param.OutRange(1,1));

fitness = mean(fitness_array);

end