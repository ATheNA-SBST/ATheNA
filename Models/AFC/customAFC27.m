function fitness = customAFC27(t, u, y)
%% Try to falsify requirement AFC27: []_[11,50] ((rise \/ fall)->([]_[1,5] |mu|<beta))

global Athena_param;

idx_min = find(u == min(u(5:end-1)),1);
minContribution = (min(u(5:end-1))-Athena_param.InRange(2,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
stepContribution = min([u(idx_min-1)-u(idx_min), u(idx_min+1)-u(idx_min)])/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
rpmContribution = (u(1)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));

if min([u(idx_min-1),u(idx_min+1)]) < 40
    fitness = (1-stepContribution)+minContribution+2;
else
    fitness = minContribution;
end

end