function fitness = customF16(t, u, y)
%% Try to falsify requirement F16: []_[0, 15] altitude > 0

global Athena_param;
rollContribution = (y(1,3)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
pitchContribution = (y(1,4)-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
fitness = ((1-rollContribution)+pitchContribution)/2;

end