function [T, XT, YT, LT, CLG, Guards] = blackbox_MechVent(~,simT,TU,U)

simopt = simget('medicalVentilatorSystemModel');

evalin('base','medicalVentilatorSystemParams');
% controlParams;

% Set T_room and T_body
assignin('base','T_body',U(1,2));
assignin('base','T_room',U(1,3));

% Run the model
% simopt = simset(simopt,'SaveFormat','Array'); % Replace input outputs with structures
T = sim('medicalVentilatorSystemModel',[0 simT],simopt,[TU U(:,1)]);
YT = [yout{1}.Values.Data, yout{2}.Values.Data];

XT = [];
LT = [];
Guards = [];
CLG = [];

end