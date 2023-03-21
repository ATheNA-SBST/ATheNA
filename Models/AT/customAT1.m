function fitness = customAT1(t, u, y)
%% Try to falsify requirement AT1: []_[0,20] speed120

global Athena_param;
brakecontribution = max(u(8,1),u(9,1))/(Athena_param.InRange(2,2)-Athena_param.InRange(2,1));
throttlecontribution = ((min(u(1:3,1)))/((Athena_param.InRange(1,2)-Athena_param.InRange(1,1))));
fitness = brakecontribution - throttlecontribution;

end