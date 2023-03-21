function fitness = customMV1(t, u, y)
%% Try to falsify requirement MV1: []_[0,30] (press <= 30 /\ 0 <= vol <= 6)

global Athena_param;

% Maximize initial breathing pressure
breath_fit = 1-(u(1)-Athena_param.InRange(1,2))/(Athena_param.InRange(1,1)-Athena_param.InRange(1,2));

% Minimize final breathing pressure
breath_fit = breath_fit+(u(2)-0)/(Athena_param.InRange(1,1)-Athena_param.InRange(1,2));

% Increase body temperature
body_fit = 1-(u(3)-Athena_param.InRange(2,2))/(Athena_param.InRange(2,1)-Athena_param.InRange(2,2));

fitness = (breath_fit+body_fit)/3*2-1;

end