function fitness = customWT2(t, u, y)
%% Try to falsify requirement WT2: []_[30,630] 21000 < M_gd < 47500

global Athena_param;
windContribution = min(diff(u(7:end))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1)));
fitness = (windContribution+1)/2;

end