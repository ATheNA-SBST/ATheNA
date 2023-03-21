function fitness = customAT2(t, u, y)
%% Try to falsify requirement AT2: []_[0,10] rpm4750

global Athena_param;

% Piecewise robustness
if any(u(1:2) < 80)
    fitness = 1-sum(u(1:2))/(2*(Athena_param.InRange(1,2)-Athena_param.InRange(1,1)));
else
    fitness = -sum(u(1:2))/(2*(Athena_param.InRange(1,2)-Athena_param.InRange(1,1)))+sum(u(8:9))/(2*(Athena_param.InRange(2,2)-Athena_param.InRange(2,1)));
end

end