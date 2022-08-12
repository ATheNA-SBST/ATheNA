function [T, XT, YT, LT, CLG, Guards] = blackboxF16(X0,~,~,~)
% Blackbox model to run the F16 aircraft using Staliro

global initialState
global x_f16_0
global sys

LT = [];
CLG = [];
Guards = [];
T = [];  %#ok<NASGU>

% Initial Search Space Variable Update (for simpleGCAS)
initialState(4) = X0(1);          % Roll angle from wings level (rad)
initialState(5) = X0(2);        % Pitch angle from nose level (rad)
initialState(6) = X0(3);          % Yaw angle from North (rad)    

x_f16_0(4) = X0(1);          % Roll angle from wings level (rad)
x_f16_0(5) = X0(2);        % Pitch angle from nose level (rad)
x_f16_0(6) = X0(3);          % Yaw angle from North (rad)
assignin('base','x_f16_0',x_f16_0)

set_param(sys, 'SimulationCommand', 'update')

cd('F16/AeroBenchVV-develop/src/main');

%execute the simulink model
[T, XT] = sim(strcat(sys,'.slx'));

cd('../../../..');

T = t_out;
   
% YT becomes the predicates state trajectory, [Altitude, GCAS_mode, Roll, Pitch]
YT = [x_f16_out(:,12) GCAS_mode_out x_f16_out(:,4) x_f16_out(:,5)];
end