function fitness = fitness_Subj2_AFC29(t,u,y)
%% AFC
%center scale the error output
%(Note by me: Remove this/Redacted)at time 0,20, maximize engine speed to 1100 RPM
%at time 0,20 maximize throttle to 61.2
%at time 10,35 minimize both engine speed and throttle to 900RPM and 0
%respectively

global Athena_param;

fitness_array(1) = mean(abs(y(:,1))/(Athena_param.OutRange(1,2)-Athena_param.OutRange(1,1)));
fitness_array(2) = mean((Athena_param.InRange(2,2)-u(abs(t-0) == min(abs(t-0)) | ...
    abs(t-20) == min(abs(t-20)),2))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1)));
fitness_array(3) = mean((u(abs(t-10) == min(abs(t-10)) | abs(t-35) == min(abs(t-35)),2) ...
    -Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1)));
fitness_array(4) = (mean(u(:,1))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));

fitness = mean(fitness_array);

end