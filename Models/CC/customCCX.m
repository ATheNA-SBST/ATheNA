function fitness = customCCX(t, u, y)
%% Try to falsify requirement CCX: /\_i=1:4 []_[0,50] (y_(i+1)-y_i > 7.5)

fitness = ((1-u(1))+u(2))/2;

end