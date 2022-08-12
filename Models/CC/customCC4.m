function fitness = customCC4(t, u, y)
%% Try to falsify requirement CC4: []_[0,65] (<>_[0,30] ([]_[0,5] y5-y4 > 8))
fitness = min(y(:,5)-y(:,4))/40;

end