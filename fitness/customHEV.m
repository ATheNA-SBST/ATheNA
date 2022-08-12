function fitness = customHEV(t, u, y)

%fitness=max(mean([u(1,1),u(2,1),u(3,1),u(4,1)]));

fitness=u(3,1)-u(2,1);
end