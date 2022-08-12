function fitness = customCC5(t, u, y)
%% Try to falsify requirement CC5: []_[0,72] (<>_[0,8] (([]_[0,5] (y2-y1 > 9)) -> ([]_(5,20) (y5-y4 > 9))))

throttleContribution = sum(abs(u(1:3)-0.3))/3;
brakeContribution = sum(u(8:9))/2;
fitness = throttleContribution - brakeContribution;

end