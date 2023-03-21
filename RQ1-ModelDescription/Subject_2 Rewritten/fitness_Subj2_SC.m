function fitness = fitness_Subj2_SC(t,u,y)
%% SC
%at time 0 minimize steam mass flow rate by setting to 3.98
%at time 33 maximize steam mass flow rate at 4.02
%prioritize test runs with a high hot water temperature (output 1)

global Athena_param;

fitness_array(1) = (u(1,1)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
idx_2 = find(abs(t-33) == min(abs(t-33)),1);
fitness_array(2) = (Athena_param.InRange(1,2)-u(idx_2,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness_array(3) = (Athena_param.OutRange(1,2)-mean(y(:,1)))/(Athena_param.OutRange(1,2)-Athena_param.OutRange(1,1));

fitness = mean(fitness_array);

end