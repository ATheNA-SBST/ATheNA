function fitness = fitness_Subj2_NN(t,u,y)
%% NN
%%center scale the positioning error
%at all even times (even integer time instants), minimize the range to 1
%at all odd times (odd integer time instants), maximize the range to 3 

global Athena_param;

fitness_array(1) = (mean(y(:,1))-Athena_param.OutRange(1,1))/(Athena_param.OutRange(1,2)-Athena_param.OutRange(1,1));
fitness_array(2:3) = 0;

for ii = 0:ceil(t(end))
    idx = find(abs(t-ii) == min(abs(t-ii)),1);
    if mod(ii,2) == 1
        % Odd time: maximize position
        fitness_array(3) = fitness_array(3)+(Athena_param.InRange(1,2)-u(idx))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
    else
        % Even time: minimize position
        fitness_array(2) = fitness_array(2)+(u(idx)-Athena_param.InRange(1,1))/(Athena_param.InRange(1,2)-Athena_param.InRange(1,1));
    end
end
fitness_array(2) = fitness_array(2)/ceil(t(end))/2;
fitness_array(3) = fitness_array(3)/ceil(t(end))/2;

fitness = mean(fitness_array);

end