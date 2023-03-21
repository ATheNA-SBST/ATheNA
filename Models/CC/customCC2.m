function fitness = customCC2(t, u, y)
%% Try to falsify requirement CC2: []_[0,70] (<>_[0,30] (y5-y4 > 15))

fitness = max(u(1:7));
fitness = fitness-min(u(8:end));

end