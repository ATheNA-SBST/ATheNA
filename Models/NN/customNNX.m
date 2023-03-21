function fitness = customNNX(t, u, y)
%% Try to falsify requirement NNX: <>_[0,1] (Pos>3.2) /\ <>_[1,1.5] ([]_[0,0.5] (1.75<Pos<2.25)) /\ []_[2,3] (1.825<Pos<2.175)

global Athena_param;
fitness = 1-(min(u(1:2))-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));

end