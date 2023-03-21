function fitness = customAFC33(t, u, y)
%% Try to falsify requirement AFC33: []_[11,50] (|mu|<gamma)

global Athena_param;
rpmContribution = (u(1)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness = rpmContribution;

end