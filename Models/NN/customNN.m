function fitness = customNN(t, u, y)
%% Try to falsify requirement NN: []_[1,37] (!(y<=0) -> <>_[0,2] []_[0,1] y<=0)

global Athena_param;
fitness = (u(2)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));

end