function fitness = customSC(t, u, y)
%% Try to falsify requirement SC: []_[30,35] 87 <= pressure <= 87.5

global Athena_param;

% Maximize odd nodes and minimize even nodes
fitness1 = 1 - (min(u(17:2:end))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness1 = fitness1+(max(u(18:2:end))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));

% Maximize even nodes and minimize odd nodes
fitness2 = 1 - (min(u(18:2:end))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
fitness2 = fitness2+(max(u(17:2:end))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));

% Choose the best option
fitness = min([fitness1, fitness2])/2;

end