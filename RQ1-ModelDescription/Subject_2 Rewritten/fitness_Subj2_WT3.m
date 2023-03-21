function fitness = fitness_Subj2_WT3(t,u,y)
%% WT
%center scale all measured outputs 
%at time 0,60,120,200 set the wind speed to 8
%at time 31,80,130,240 set the wind speed to 16
%prioritize runs with high torque
global Athena_param;
find_time = @(x) find(abs(t-x) == min(abs(t-x)),1);

fitness_array(1) = mean(u([find_time(0), find_time(60), find_time(120), find_time(200)],1)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness_array(2) = mean(Athena_param.InRange(1,2)-u([find_time(31), find_time(80), find_time(130), find_time(240)],1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness_array(3) = mean(Athena_param.OutRange(3,2)-y(:,3))/(Athena_param.OutRange(3,2)-Athena_param.OutRange(3,1));

fitness = mean(fitness_array);

end
