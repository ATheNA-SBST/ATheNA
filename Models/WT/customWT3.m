function fitness = customWT3(t, u, y)
%% Try to falsify requirement WT3: []_[30,630] speed < 14.3

global Athena_param;
windContribution = max(diff(u(7:end))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1)));
fitness = -(windContribution-1)/2;

end