function fitness = custom_Subj1_AFC29(t,u,y)
    %Engine speeds below 1000 are negative, above are positive
    %The lower the throttle, the larger number this is multiplied by
    fitness = ((u(1)-1000)/200) * (mean(u(2:11))- 61.2)/61.2;
end