function fitness = fitness_Subj2_CCX(t,u,y)
%% CCX
%scale the output distance
%at times (10,20,30,40) maximize throttle and minimize brakes
%at times (15,25,35,45) maximize brakes and minimize throttle
global Athena_param;

fitness_array(1) = mean((Athena_param.InRange(1,2)-u(abs(t-10) == min(abs(t-10)) | abs(t-20) == min(abs(t-20)) | abs(t-30) == min(abs(t-30)) | abs(t-40) == min(abs(t-40)),1))/ ...
    (Athena_param.InRange(1,2)-Athena_param.InRange(1,1)));
fitness_array(2) = mean((u(abs(t-10) == min(abs(t-10)) | abs(t-20) == min(abs(t-20)) | abs(t-30) == min(abs(t-30)) | abs(t-40) == min(abs(t-40)),2)-Athena_param.InRange(2,1))/ ...
    (Athena_param.InRange(2,2)-Athena_param.InRange(2,1)));

fitness_array(3) = mean((u(abs(t-15) == min(abs(t-15)) | abs(t-25) == min(abs(t-25)) | abs(t-35) == min(abs(t-35)) | abs(t-45) == min(abs(t-45)),1)-Athena_param.InRange(1,1))/ ...
    (Athena_param.InRange(1,2)-Athena_param.InRange(1,1)));
fitness_array(4) = mean((Athena_param.InRange(2,2)-u(abs(t-15) == min(abs(t-15)) | abs(t-25) == min(abs(t-25)) | abs(t-35) == min(abs(t-35)) | abs(t-45) == min(abs(t-45)),2))/ ...
    (Athena_param.InRange(2,2)-Athena_param.InRange(2,1)));

fitness = mean(fitness_array);

end
