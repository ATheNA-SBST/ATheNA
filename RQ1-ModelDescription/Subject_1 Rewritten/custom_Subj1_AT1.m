function fitness = custom_Subj1_AT1(t,u,y)

%Braking bad, throttle good
fitness = sum(u(8:10))/(3*100) - sum(u(1:7))/(7*110);

end