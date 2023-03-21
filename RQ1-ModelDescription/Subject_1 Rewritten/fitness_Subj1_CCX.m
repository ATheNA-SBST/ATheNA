function fitness = fitness_Subj1_CCX(t,u,y)

fit = zeros(size(t));

for ii = 1:length(t)

    %if throttle is larger than brake, this function yields a larger negative
    %number whenever vehicle 1 and 2 are close together
    if u(ii,1) > u(ii,2)
        fit(ii) = -u(ii,1) / ((y(ii,2) - y(ii,1))/10);
    
    %if brake is larger than throttle, this function yields a larger negative 
    % number whenver vehicle 1 and 2 are far apart  
    else
        fit(ii) = -u(ii,2) * ((y(ii,1) - y(ii,2))/10);
    
    end

end

%If I had more time there would be a way to incorporate all time stamps
fitness = mean(fit);

end