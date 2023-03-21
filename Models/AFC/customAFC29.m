function fitness = customAFC29(t, u, y)
%% Try to falsify requirement AFC27: []_[11,50] (|mu|<gamma)

global Athena_param;
fitness = (min(u(4:end))-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));

end