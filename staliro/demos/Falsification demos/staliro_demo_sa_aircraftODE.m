% This is a demo for using S-TALIRO with models defined as m-functions and
% Simulated Annealing as an optimization solver.
%
% The demo also presents different ways to model the same requirement and
% trade-offs.

% (C) Georgios Fainekos 2010 - Arizona State University

clear

cd('..')
cd('SystemModelsAndData')

disp(' ')
disp(' Demo: Simulated Annealing on the aircraft example from the HSCC 2010 paper. ')
disp(' Two runs will be performed for a maximum of 400 tests each. ')
disp(' ')

model = @aircraftODE;

disp(' ')
disp(' The initial conditions defined as a hypercube:')
init_cond = [200 260;-10 10;120 150] %#ok<*NOPTS>

disp(' ')
disp(' The constraints on the input signals defined as a hypercube:')
input_range = [34386 53973; 0 16]
disp(' ')
disp(' The number of control points for each input signal:')
cp_array = [10 20];

phi{1} = '!([]_[0,4.0] a /\ <>_[3.5,4.0] b)';
phi{2} = '!([]_[0,4.0] (a1 /\ a2) /\ <>_[3.5,4.0] (b1 /\ b2) )';
phi{3} = '!([]_[0,4.0] (a1 /\ a2) /\ <>_[3.5,4.0] (b1 /\ b2) )';

disp(' ')
disp(' The specification is:')
disp('  We are looking for a system behavior where x1 is in the range 240 <= x1 <= 250 for time between 0 and 4, and')
disp('  x1 eventually gets a value in the range 240 <= x1 <= 240.1 within time 3.5 to 4.')
disp(' ')
disp(' We have several options for capturing the same requirement: ')
disp(['  1. ', phi{1} ]);
disp('          where ')
disp('              a is mapped to the convex set [1 0 0; -1 0 0] * x <= [250; -240] ')
disp('              b is mapped to the convex set [1 0 0; -1 0 0] * x <= [240.1; -240] ')
disp('          since the model output is a 3 dimensional signal, i.e., x = [x1; x2; x3]. ')
disp('      This option requires the Matlab Optimization toolbox since the predicates are mapped to general convex sets. ')
disp('      In general, this approach results in better approximations of the robustness estimate. ')
disp(' ')
disp(['  2. ', phi{2} ]);
disp('          where ')
disp('              a1 is mapped to the half space [1 0 0] * x <= 250 ')
disp('              a2 is mapped to the half space [-1 0 0] * x <= -240 ')
disp('              b1 is mapped to the half space [1 0 0] * x <= 240.1 ')
disp('              b2 is mapped to the half space [-1 0 0] * x <= -240 ')
disp('          since the model output is a 3 dimensional signal, i.e., x = [x1; x2; x3]. ')
disp('      This option does not require the Matlab Optimization toolbox since the distance computations are analytical. ')
disp(' ')
disp(' ')
disp(['  3. ', phi{3} ]);
disp('          where ')
disp('              a1 is mapped to the interval x1 <= 250 ')
disp('              a2 is mapped to the interval -x1 <= -240 ')
disp('              b1 is mapped to the interval x1 <= 240.1 ')
disp('              b2 is mapped to the interval -x1 <= -240 ')
disp('      This option is the fastest in case all the constraints are only on one variable. ')
disp('      This option does not require the Matlab Optimization toolbox since the distance computations are analytical. ')
disp(' ')
form_id = input(' Select requirement representation : ')

preds(1).str = 'a';
preds(1).A = [1 0 0; -1 0 0];
preds(1).b = [250; -240];
preds(2).str = 'b';
preds(2).A = [1 0 0; -1 0 0];
preds(2).b = [240.1; -240];

if form_id == 2
    preds(3).str = 'a1';
    preds(3).A = [1 0 0];
    preds(3).b = 250;
    preds(4).str = 'a2';
    preds(4).A = [-1 0 0];
    preds(4).b = -240;
    preds(5).str = 'b1';
    preds(5).A = [1 0 0];
    preds(5).b = 240.1;
    preds(6).str = 'b2';
    preds(6).A = [-1 0 0];
    preds(6).b = -240;
elseif form_id == 3
    preds(3).str = 'a1';
    preds(3).A = 1;
    preds(3).b = 250;
    preds(3).proj = 1;
    preds(4).str = 'a2';
    preds(4).A = -1;
    preds(4).b = -240;
    preds(4).proj = 1;
    preds(5).str = 'b1';
    preds(5).A = 1;
    preds(5).b = 240.1;
    preds(5).proj = 1;
    preds(6).str = 'b2';
    preds(6).A = -1;
    preds(6).b = -240;
    preds(6).proj = 1;
end


disp(' ')
disp('Total Simulation time:')
time = 4

disp(' ')
disp('Create an staliro_options object with the default options.')
opt = staliro_options();

disp(' ')
disp('Change options:')
opt.runs = 2;
opt.spec_space = 'X';

opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 400;

opt

disp(' ')
disp('Running S-TaLiRo with Simulated Annealing ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi{form_id},preds,time,opt);
toc

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(1).bestRob)])
display(['Minimum Robustness found in Run 2 = ',num2str(results.run(2).bestRob)])

figure(1)
clf
[T1,XT1,YT1,IT1] = SimFunctionMdl(model,init_cond,input_range,cp_array,results.run(1).bestSample,time,opt);
subplot(3,1,1)
plot(T1,XT1(:,1))
title('State trajectory x_1')
subplot(3,1,2)
plot(IT1(:,1),IT1(:,2))
title('Input Signal u_1')
subplot(3,1,3)
plot(IT1(:,1),IT1(:,3))
title('Input Signal u_2')

figure(2)
clf
[T2,XT2,YT2,IT2] = SimFunctionMdl(model,init_cond,input_range,cp_array,results.run(2).bestSample,time,opt);
subplot(3,1,1)
plot(T2,XT2(:,1))
title('State trajectory x_1')
subplot(3,1,2)
plot(IT2(:,1),IT2(:,2))
title('Input Signal u_1')
subplot(3,1,3)
plot(IT2(:,1),IT2(:,3))
title('Input Signal u_2')

cd('..')
cd('Falsification demos')

