function fitness = fitness_Subj1_WT3(t,u,y)
%Simply, high winds and large blade angles will break the system, so find a
%point that optimizes that product
global Athena_param;

u_rescaled = (u-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
angle_rescaled = (y(:,6)-Athena_param.OutRange(6,1))/(Athena_param.OutRange(6,2)-Athena_param.OutRange(6,1));

fitness = mean(-u_rescaled.*angle_rescaled);

    % Interpolate u to have the same number of elements of y.
    % Assume average.
end