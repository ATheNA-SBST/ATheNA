function fitness = customWT4(t, u, y)
%% Try to falsify requirement WT4: []_[30,630] <>_[0,5] |theta-theta_ref| <= 1.6

global Athena_param;
windContribution = mean(abs(diff(u(7:end))))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness = 1-windContribution;

end