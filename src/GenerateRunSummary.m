fals = false(athena_opt.athena_runs,1);
n_iter = zeros(size(fals));
best_Rob = zeros(size(fals));

for ii = 1:athena_opt.athena_runs

    % Number of runs
    n_iter(ii) = Results{ii}.run.nTests;

    % Lowest robustness
    best_Rob(ii) = Results{ii}.run.bestRob;

    % Falsified or not
    fals(ii) = (best_Rob(ii) <= 0);

end

% Compute quality parameters
SuccRate = sum(fals)/length(fals);

% Average and median number of runs (only for runs that were falsified)
Avg_iter = round(mean(n_iter(fals)));
Med_iter = round(median(n_iter(fals)));

% Average and median minimum robustness (only for runs that were not
% falsified)
Avg_rob = mean(best_Rob(~fals));
Med_rob = median(best_Rob(~fals));

% Print results
fprintf('\n\t\t\t*\t*\t*\n\n')
if isa(model,'function_handle')
    fprintf('Model:\t\t%s\n',func2str(model))
else
    fprintf('Model:\t\t%s\n',model)
end
fprintf('Requirement:\t %s\n\n',phi)

fprintf('\t\t%s\n','ATheNA-S')
fprintf('Success rate:\t\t%.0f%%\n',SuccRate*100)
fprintf('Average iterations:\t%i\n',Avg_iter)
fprintf('Median iterations:\t%i\n',Med_iter)
fprintf('Average robustness:\t%.3f\n',Avg_rob)
fprintf('Median robustness:\t%.3f\n\n',Med_rob)