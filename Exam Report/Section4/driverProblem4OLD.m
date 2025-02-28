%{

Authors: Karl Takeuchi and Andreas Engly

DESCRIPTION
This file contains the code for plots, comparisons and solutions in
general to section 4 of the exam report. All necessary solvers are placed
in OptimizationSoftware in the main directory 'Exam Report'.

INFORMATION
To run this file, please comply with the following:

1. You path must be <'Exam Report/Section4'>

%}
%% Plotting Himmelblau

% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

hold off

legend([h5, h11, h13],{'Local Minimum', 'Saddle Point', 'Local Maximum'})

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')


saveas(gcf,'./Plots/ContourHB.png')

%% Solution to Himmelblau (fmincon vs IPOPT)

% Starting point
x0 = [-5; 0];

% Specification of constraints
c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% SOLUTION: fmincon

% Structure of constraints
A = [-4 10; 4 -10];
b = [c2_u; -c2_l];
Aeq = [];
beq = [];
lb = [x1_l; x2_l];
ub = [x1_u; x2_u];

% Solve with fmincon
optimoptions('fmincon','Display', 'iter', 'SpecifyObjectiveGradient', true, 'TolFun', 1e-8, 'Algorithm', 'interior-point');
[x_fmincon,fval,exitflag,output_fmincon,lambda,grad,hessian] = fmincon(@objfminconHimmelblau, x0, A, b, Aeq, beq, lb, ub, @confunHimmelblau);

% SOLUTION: CasADi with IPOPT

% Uncomment on MacOS with M1 processor
addpath('./../OptimizationSoftware/casadi-3.6.2-osx64-matlab2018b');

% OBS: The solver might be blocked by your operating system. Go to security
% settings to fix this.

% Import Casadi
import casadi.*

x = MX.sym('x', 2);

% Define objective function
t1 = x(1)*x(1)+x(2)-11;
t2 = x(1)+x(2)*x(2)-7;
f = t1*t1 + t2*t2;

% Constraints
c1 = (x(1)+2)^2 - x(2);
c2 = -4*x(1) + 10*x(2);
g = [c1; c2];

nlp = struct;
nlp.x = x;
nlp.f = f;
nlp.g = g;

% Specify options
opts = struct("ipopt", struct('max_iter', 100, 'print_level', 5));

% Create solver instance
S = nlpsol('S', 'ipopt', nlp, opts);

sol_ipopt = S('x0',x0,'ubg',[c1_u; c2_u], ...
    'lbg',[c1_l; c2_l],'lbx',[x1_l;x2_l],'ubx',[x1_u;x2_u]);

disp('----------- RESULTS FOR HIMMELBLAU WITH FMINCON AND IPOPT THROUGH CASADI -----------')
fprintf('\n----- FMINCON ------\n')
disp(x_fmincon);
fprintf('Iterations: %d\n\n', output_fmincon.iterations);
fprintf('\n----- IPOPT ------\n')
disp(sol_ipopt.x);

%% Solution to Portfolio (fmincon vs IPOPT)

n_max = 300;
k_max = 100;
step_size_n = 20;
step_size_k = 10;

n_steps = n_max/step_size_n;
k_steps = k_max/step_size_k;

N = step_size_n:step_size_n:n_max;
K = step_size_k:step_size_k:k_max;

iterations = zeros(n_steps, k_steps);
functionCalls = zeros(n_steps, k_steps);
timeRecordings = zeros(n_steps, k_steps);

% Construct a grid and run solver
for i = 1:n_steps
    for j = 1:k_steps

        % Set assets and factors
        n = N(i);
        k = K(j);

        % Diplay iteration to check how far we are
        fprintf("(%d, %d)\n", n, k);

        % Define risk-aversion
        gamma = 1;
        
        % Generate problem
        D = diag(rand(1,n))*sqrt(k);
        F = sprand(n,k,0.5);
        mu = 0 + 1.*randn(n,1);
        
        % Define anonymous function
        objfun = @(x)objPortfolio(x,mu,D,gamma,n,k);
        
        % Find feasible solution as starting point
        x0 = zeros(n+k,1);
        aux_x0 = rand(n,1);
        x0(1:n) = aux_x0/sum(aux_x0);
        x0(n+1:n+k) = transpose(F)*x0(1:n);
        
        % Specification of constraints
        x_l = 0;
        x_u = 0.5;
        A = [[transpose(F) -eye(k)]; [repelem(1,n) repelem(0,k)]];
        b = [zeros(k,1); 1];
        Aeq = [];
        beq = [];
        lb = [repelem(x_l,n) repelem(-inf,k)];
        ub = [repelem(x_u,n) repelem(inf,k)];
        
        % Solve with fmincon
        options = optimoptions('fmincon','Display', 'off', 'SpecifyObjectiveGradient', false, 'MaxFunctionEvaluations', 1e+6, 'TolFun', 1e-6, 'Algorithm', 'interior-point');
        startTime = cputime;
        [x_fmincon,fval,exitflag,output_fmincon,lambda,grad,hessian] = fmincon(objfun, x0, A, b, Aeq, beq, lb, ub, [], options);
        totalTime = cputime - startTime;

        % Save results
        iterations(i,j) = output_fmincon.iterations;
        functionCalls(i,j) = output_fmincon.funcCount;
        timeRecordings(i,j) = totalTime;
    
    end
end

heatmap(K, N, iterations)
xlabel('Factors (k)') 
ylabel('Assets (n)')
saveas(gcf,'./Plots/PortfolioHeatmapIterations.png')

heatmap(K, N, functionCalls)
xlabel('Factors (k)') 
ylabel('Assets (n)')
saveas(gcf,'./Plots/PortfolioHeatmapFunctionCalls.png')

heatmap(K, N, timeRecordings)
xlabel('Factors (k)') 
ylabel('Assets (n)')
saveas(gcf,'./Plots/PortfolioHeatmapTimer.png')

%% Solution to Recycle Problem

n_max = 1000;
step_size = 5;
n_min = step_size;
n_steps = n_max/step_size;

N = step_size:step_size:n_max;

iterations = zeros(n_steps, 1);
functionCalls = zeros(n_steps, 1);
timeRecordings = zeros(n_steps, 1);

% Construct a grid and run solver
for i = 1:n_steps

        % Set assets and factors
        n = N(i);

        % Diplay iteration to check how far we are
        fprintf("n = %d\n", n);

        % Define risk-aversion
        u_bar = 0.2;
        d0 = 1;

        % Define anonymous function
        objfun = @(u) transpose(u - u_bar) * (u - u_bar);
        
        % Specification of constraints
        x_l = [];
        x_u = [];
        A = [];
        b = [];
        lb = [];
        ub = [];

        % Construct Aeq
        Aeq = zeros(n,n+1);
        Aeq(1,1) = -1;
        Aeq(1,n) = 1;
        for j = 1:(n-2)
            k = j+1;
            Aeq(k,k-1) = 1;
            Aeq(k,k) = -1;
        end
        Aeq(n, n-1) = 1;
        Aeq(n, n) = -1;
        Aeq(n, n+1) = -1;

        % Construct beq
        beq = zeros(n,1);
        beq(1) = -d0;

        % Construct feasible starting point
        u0 = zeros(n+1,1);
        kappa = 0;
        u0(1:n-1) = kappa;
        u0(n) = -d0 + kappa;
        u0(n+1) = d0;

        % Solve with fmincon
        options = optimoptions('fmincon','Display', 'off', 'SpecifyObjectiveGradient', false, 'MaxFunctionEvaluations', 1e+6, 'TolFun', 1e-6, 'Algorithm', 'interior-point');
        startTime = cputime;
        [x_fmincon,fval,exitflag,output_fmincon,lambda,grad,hessian] = fmincon(objfun, u0, A, b, Aeq, beq, lb, ub, [], options);
        totalTime = cputime - startTime;

        if exitflag == 0
            fprintf("Not optimal for n = %d", n);
        end

        % Save results
        iterations(i) = output_fmincon.iterations;
        functionCalls(i) = output_fmincon.funcCount;
        timeRecordings(i) = totalTime;
    
end

plot(N, timeRecordings)

xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('CPU time','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

saveas(gcf,'./Plots/RecycleProblemCPUTime.png')

plot(N, iterations)

xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('Iterations','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

saveas(gcf,'./Plots/RecycleProblemIterations.png')

plot(N, functionCalls)

xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('Function calls','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

saveas(gcf,'./Plots/RecycleProblemFunctionCalls.png')

%% Testing of SQP with Line Search and Damped BFGS

% Starting point
x0 = [-5; 0];

% Specification of constraints
c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% SOLUTION: fmincon

% Structure of constraints
A = [-4 10; 4 -10];
b = [c2_u; -c2_l];
Aeq = [];
beq = [];
lb = [x1_l; x2_l];
ub = [x1_u; x2_u];

% Testing the functions
[f,df,d2f] = objHimmelblau(x0);
[cIq,dcIq,d2cIq] = conIqHimmelblau(x0);
[cEq,dcEq,d2cEq] = conEqHimmelblau(x0);

% Evaluate nonlinear constraints (Himmelblau)
[c, ceq] = conHimmelblau(x0);

%% Testing of SQP with Line Search and Damped BFGS

options = struct();
options.maxit = 2;
options.BFGS = true;
options.stepSolver = "quadprog";

x0 = [0;0];
A = [];
b = [];
Aeq = [];
beq = [];
lb = -50;
ub = 50;

% Make function calls clear

pk = SQPLineSearchDampedBFGS(fun,x0,lb,ub,con,options);

%% Testing the nonlinear constraint function for Himmelblau's Test Problem
x_test = [1;2];
[c,ceq,GC,GCeq] = conHimmelblau(x_test);

if all(c == [11;16],'all') && all(GC == [6 -4;-1 10], 'all')
    fprintf("Testing Constraint Function for Himmelblau: PASSED\n")
else
    fprintf("Testing Constraint Function for Himmelblau: FAILED\n")
end

%% Testing 'SQPLineSearchDampedBFGS'

% This code tests the core algorithm
x0 = [2;2];
xlb = [-5; -5];
xub = [5; 5];
cub = [47; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxit = 100;
options.BFGS = true;
options.stepSolver = "quadprog";
options.l1Penalty = 1;
options.lineSearch = "slides";
options.convergenceRequirement = 1e-10;

[x_final, solverInformation] = SQPLineSearchDampedBFGS(fun,x0,xlb,xub,clb,cub,nonlcon,options);

%%

% Plotting sequence
% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

    % Plot points from sequence
    h14 = plot(solverInformation.stepSequence(1,:), solverInformation.stepSequence(2,:), "LineStyle", ":", 'LineWidth',3, 'color', 'black');

hold off

legend([h5, h11, h13, h14],{'Local Minimum', 'Saddle Point', 'Local Maximum', 'SQP path'})

xlim([x1_l x1_u])
ylim([x2_l x2_u])
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')


saveas(gcf,'./Plots/ContourHB_dampedBFGS_quadprog.png')

%% Testing 'SQPTrustRegion'

% This code specifies the problem structure
x0 = [1;1];
lb = [-5; -5];
ub = [5; 5];
cub = [47; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxIter = 100;
options.l1Penalty = 30;
options.precision = 15;
options.eta = 0;
options.trustRegion = 0.5;

[x, solverInformation] = SQPTrustRegion(fun,x0,lb,ub,clb,cub,nonlcon,options);

%%
% ---------------- DESCRIPTION --------------
%
% Name: driverProblem4.m
% Type: Driver for all testing and plots from problem 4 (NLP)
%
% Assumptions: 
% 
% 1) Functions are sufficiently smooth and [nabla(h) nabla(g)] has full
% column rank.
%
% Problem structure:
%           min     f(x)
%            x
%           s.t.    h(x) = 0
%                   cl  <= g(x) <= cu
%                   l  <= x <= u
%
% Created: 12.05.2023
% Authors: Andreas Engly (s170303) and Karl Takeuchi-Storm (s130377)
%          Compute, Technical University of Denmark
%

% ---------------- IMPLEMENTATION --------------

%% Global setup

% This contains e.g. options for quadprog or other solvers

%% 4.4) Plot of Himmelblau's Test Problem

% This section tests whether the test problems are generated correctly.
% The function for the objective and constraints are found in
% files named: conHimmelblau.m and objHimmelblau.m

% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

hold off

legend([h5, h11, h13],{'Local Minimum', 'Saddle Point', 'Local Maximum'})

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')


saveas(gcf,'./Plots/441_ContourHB.png')

%% 4.5) Scalable test problems (TO DO)

% This section contains tests for adjusted general QP solvers.
% The adjusted implementation are found is separate files named:
% XXXXXXXXXXXXXXX

%% 4.6) TO DO (look at code above)

% This section contains tests for primal-dual interior point algorithm for LP.
% The implementation is found in the file named: XXXX

% The test should be on some general LP for different starting points.
% The plots should show the paths.
%
% We should also provide statistics of:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

%% 4.7) Testing of SQP with Line Search and BFGS approximation

% This section contains tests for a SQP with Line Search and BFGS
% approximation.
% The implementation is found in the file named: SQPLineSearchDampedBFGS.m

% The plots should show the paths on Himmelblau's Test Problem.
%
% We should also provide statistics from scalable problems:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

% This code tests the core algorithm
x0 = [3;3];
xlb = [-5; -5];
xub = [5; 5];
cub = [70; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxit = 1000;
options.BFGS = true;
options.stepSolver = "quadprog";
options.l1Penalty = 100;
options.lineSearch = "all";
options.convergenceRequirement = sqrt(1e-16);

[primal_final, dual_final, solverInformation] = SQPLineSearchDampedBFGS(fun,x0,xlb,xub,clb,cub,nonlcon,options);

% Plotting sequence
% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

    % Plot points from sequence
    h14 = plot(solverInformation.stepSequence(1,end), solverInformation.stepSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");

hold off

legend([h5, h11, h13, h14],{'Local Minimum', 'Saddle Point', 'Local Maximum', 'Solution'})

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

%% 4.6.1) Test of Simple SQP solver (with BFGS)

% This section contains tests for a SQP with Line Search and BFGS
% approximation.
% The implementation is found in the file named: SQPSimpleDamedBFGS.m

% The plots should show the paths on Himmelblau's Test Problem.
%
% We should also provide statistics from scalable problems:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

% This code tests the core algorithm
x0 = [0;0];
xlb = [-5; -5];
xub = [5; 5];
cub = [70; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxit = 1000;
options.BFGS = true;
options.stepSolver = "quadprog";
options.l1Penalty = 100;
options.lineSearch = "all";
options.convergenceRequirement = sqrt(1e-16);

[primal_final, dual_final, solverInformation] = SQPSimpleDampedBFGS(fun,x0,xlb,xub,clb,cub,nonlcon,options);

% Plotting sequence
% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

    % Plot solution point
    h14 = plot(solverInformation.primalSequence(1,end), solverInformation.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h15 = plot(solverInformation.primalSequence(1,1:end-1), solverInformation.primalSequence(2,1:end-1), 'LineStyle', "--", 'LineWidth', 2);

hold off

legend([h5, h11, h13, h15, h14],{'Local Minimum', 'Saddle Point', 'Local Maximum', 'Path', 'Solution'})

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

%% 4.6.2) Test of Simple SQP solver (with Line Search and BFGS)

% This section contains tests for a SQP with Line Search and BFGS
% approximation.
% The implementation is found in the file named: SQPSimpleDamedBFGS.m

% The plots should show the paths on Himmelblau's Test Problem.
%
% We should also provide statistics from scalable problems:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

% Test points (starting points)
x1 = [1;2.5];
x2 = [3.5;3.5];
x3 = [1;1];
x4 = [1;1];

% This code tests the core algorithm
xlb = [-5; -5];
xub = [5; 5];
cub = [70; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxit = 1000;
options.BFGS = true;
options.stepSolver = "quadprog";
options.l1Penalty = 100;
options.lineSearch = "all";
options.convergenceRequirement = sqrt(1e-16);

[primal_final_1, dual_final_1, solverInformation_1] = SQPSimpleLSDampedBFGS(fun,x1,xlb,xub,clb,cub,nonlcon,options);
[primal_final_2, dual_final_2, solverInformation_2] = SQPSimpleLSDampedBFGS(fun,x2,xlb,xub,clb,cub,nonlcon,options);
[primal_final_3, dual_final_3, solverInformation_3] = SQPSimpleLSDampedBFGS(fun,x3,xlb,xub,clb,cub,nonlcon,options);
[primal_final_4, dual_final_4, solverInformation_4] = SQPSimpleLSDampedBFGS(fun,x4,xlb,xub,clb,cub,nonlcon,options);

% Plotting sequence
% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

    % Plot solution point
    h14 = plot(solverInformation_1.primalSequence(1,end), solverInformation_1.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h15 = plot(solverInformation_1.primalSequence(1,1:end-1), solverInformation_1.primalSequence(2,1:end-1), 'LineStyle', "--", 'LineWidth', 2);

    % Plot solution point
    h16 = plot(solverInformation_2.primalSequence(1,end), solverInformation_2.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h17 = plot(solverInformation_2.primalSequence(1,1:end-1), solverInformation_2.primalSequence(2,1:end-1), 'LineStyle', "--", 'LineWidth', 2);
    
    % Plot solution point
    h18 = plot(solverInformation_3.primalSequence(1,end), solverInformation_3.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h19 = plot(solverInformation_3.primalSequence(1,1:end-1), solverInformation_3.primalSequence(2,1:end-1), 'LineStyle', "--", 'LineWidth', 2);
    
    % Plot solution point
    h20 = plot(solverInformation_4.primalSequence(1,end), solverInformation_4.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h21 = plot(solverInformation_4.primalSequence(1,1:end-1), solverInformation_4.primalSequence(2,1:end-1), 'LineStyle', "--", 'LineWidth', 2);

hold off

legend([h5, h11, h13, h15, h14,h17,h16,h19,h18,h21,h20],{'Local Minimum', 'Saddle Point', 'Local Maximum', 'Path', 'Solution', 'Path', 'Solution', 'Path', 'Solution', 'Path', 'Solution'}, 'Location','southeast')

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

%% 4.6.3) Test of Simple SQP solver (with Line Search and BFGS and infeasibility handling)

% This section contains tests for a SQP with Line Search and BFGS
% approximation.
% The implementation is found in the file named: SQPSimpleDamedBFGS.m

% The plots should show the paths on Himmelblau's Test Problem.
%
% We should also provide statistics from scalable problems:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

% Test points (starting points)
%x1 = [-1.35;-0.35];
x1 = [-1.4242;0.3315];
x2 = [-0.85;0.2];
x3 = [-1.8;-0.25];
%x3 = [-2;3];
x4 = [-3.25;0.35];

% This code tests the core algorithm
xlb = [-5; -5];
xub = [5; 5];
cub = [70; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxit = 1000;
options.BFGS = true;
options.stepSolver = "quadprog";
options.l1Penalty = 100;
options.lineSearch = "all";
options.convergenceRequirement = sqrt(1e-16);

[primal_final_1, dual_final_1, solverInformation_1] = SQP_LS_BFGS_Infeasiblility(fun,x1,xlb,xub,clb,cub,nonlcon,options);
[primal_final_2, dual_final_2, solverInformation_2] = SQP_LS_BFGS_Infeasiblility(fun,x2,xlb,xub,clb,cub,nonlcon,options);
[primal_final_3, dual_final_3, solverInformation_3] = SQP_LS_BFGS_Infeasiblility(fun,x3,xlb,xub,clb,cub,nonlcon,options);
[primal_final_4, dual_final_4, solverInformation_4] = SQP_LS_BFGS_Infeasiblility(fun,x4,xlb,xub,clb,cub,nonlcon,options);

% Plotting sequence
% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

    % Plot solution point
    h14 = plot(solverInformation_1.primalSequence(1,end), solverInformation_1.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h15 = plot(solverInformation_1.primalSequence(1,1:end-1), solverInformation_1.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);

    % Plot solution point
    h16 = plot(solverInformation_2.primalSequence(1,end), solverInformation_2.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#0072BD");
    h17 = plot(solverInformation_2.primalSequence(1,1:end-1), solverInformation_2.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);
    
    % Plot solution point
    h18 = plot(solverInformation_3.primalSequence(1,end), solverInformation_3.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#D95319");
    h19 = plot(solverInformation_3.primalSequence(1,1:end-1), solverInformation_3.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);
    
    % Plot solution point
    h20 = plot(solverInformation_4.primalSequence(1,end), solverInformation_4.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#77AC30");
    h21 = plot(solverInformation_4.primalSequence(1,1:end-1), solverInformation_4.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);

hold off

legend([h5, h11, h13, h15, h14, h16, h18, h20],{'Local Minimum', 'Saddle Point', 'Local Maximum', 'Paths', sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x1(1), x1(2)), sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x2(1), x2(2)), sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x3(1),x3(2)), sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x4(1),x4(2))}, 'Location','southeast')

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

%% 4.7) Testing of SQP with Trust Region

% This section contains tests for a SQP with Line Search and BFGS
% approximation.
% The implementation is found in the file named: SQPSimpleDamedBFGS.m

% The plots should show the paths on Himmelblau's Test Problem.
%
% We should also provide statistics from scalable problems:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

% Test points (starting points)
%x1 = [-1.35;-0.35];
x1 = [-1.4242;0.3315];
x2 = [0.0;0.90];
x3 = [-1.8;-0.25];
%x3 = [-2;3];
x4 = [-4.25;0.00];

% This code tests the core algorithm
xlb = [-5; -5];
xub = [5; 5];
cub = [70; 70];
clb = [0; 0];
nonlcon = @(x) conHimmelblau(x);
fun = @(x) objHimmelblau(x);

% Set options
options = struct();
options.maxit = 1000;
options.BFGS = true;
options.stepSolver = "quadprog";
options.l1Penalty = 0.1;
options.lineSearch = "all";
options.trustRegion = 0.1;
options.adaptiveTrustRegion = true;
options.infeasibilityPenalty = 50;
options.acceptanceMargin = 0.001;
options.convergenceRequirement = sqrt(1e-16);

[primal_final_1, dual_final_1, solverInformation_1] = SQPSimpleTrustRegion(fun,x1,xlb,xub,clb,cub,nonlcon,options);
[primal_final_2, dual_final_2, solverInformation_2] = SQPSimpleTrustRegion(fun,x2,xlb,xub,clb,cub,nonlcon,options);
[primal_final_3, dual_final_3, solverInformation_3] = SQPSimpleTrustRegion(fun,x3,xlb,xub,clb,cub,nonlcon,options);
[primal_final_4, dual_final_4, solverInformation_4] = SQPSimpleTrustRegion(fun,x4,xlb,xub,clb,cub,nonlcon,options);

% Plotting sequence
% SETTINGS FOR LABELS, AXIS' AND FILL

upper_colorbar = 200;
lower_colorbar = 0;
granularity_colorbar = 10;

% BOUNDS FOR HIMMELBLAU

c1_l = 0;
c1_u = 47;

c2_l = 0;
c2_u = 70;

x1_l = -5;
x1_u = 5;

x2_l = -5;
x2_u = 5;

% OBJECTIVE VALUES ON GRID

x1 = x1_l:0.05:x1_u;
x2 = x2_l:0.05:x2_u;
[X1, X2] = meshgrid(x1,x2);
F = objfunHimmelblau(X1, X2);

v = lower_colorbar:granularity_colorbar:upper_colorbar;
contour(X1,X2,F,v,"linewidth",2);
colorbar;

% CONSTRAINT BOUNDARIES

yc11 = (x1 + 2).^2 - c1_l; % >= x2
yc12 = (x1 + 2).^2 - c1_u; % <= x2 - c1_u
yc21 = (4 .* x1 + c2_l)./10; % <= x2
yc22 = (4 .* x1 + c2_u)./10; % >= x2

% CONSTRAINT COLORS AND TRANSPARANCY

% ORANGE: [0.8500 0.3250 0.0980]
% BLUE: [0.6350 0.0780 0.1840]

yc1_color = [0 0 0];
yc1_density_l = 0.7; 
yc1_density_u = 0.7; 

yc2_color = [0 0 0];
yc2_density_l = 0.7;
yc2_density_u = 0.7;

% MAKE PLOT

hold on

    % Constraint 1
    h1 = fill([x1_l x1],[x2_u yc11], yc1_color, "facealpha",yc1_density_l);
    h2 = fill([x1_l x1 x1_u],[x2_l yc12 x2_l], yc1_color, "facealpha",yc1_density_u);

    % Constraint 2
    h3 = fill([x1_l x1 x1_u],[x2_l yc21 x2_l], yc2_color, "facealpha",yc2_density_l);
    h4 = fill([x1_l x1 x1_u],[x2_u yc22 x2_u], yc2_color, "facealpha",yc2_density_u);

    % Points
    h5 = plot(-3.5485, -1.4194,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h6 = plot(-0.2983,  2.8956,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h7 = plot(-3.6546,  2.7377,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h8 = plot(3.216440661, 1.286576264,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h9 = plot(3,2,'black', 'MarkerSize', 16, 'Marker', 'v', 'MarkerFaceColor', '#EDB120');
    h10 = plot(-1.4242,0.3315,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');
    h11 = plot(-3.0730,-0.0814,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h12 = plot(0.0867, 2.8843,'black', 'MarkerSize', 16, 'Marker', 'diamond', 'MarkerFaceColor', '#D95319');
    h13 = plot(-0.4870, -0.1948,'black', 'MarkerSize', 16, 'Marker', '^', 'MarkerFaceColor', '#A2142F');

    % Plot solution point
    h14 = plot(solverInformation_1.primalSequence(1,end), solverInformation_1.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#FF0000");
    h15 = plot(solverInformation_1.primalSequence(1,1:end-1), solverInformation_1.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);

    % Plot solution point
    h16 = plot(solverInformation_2.primalSequence(1,end), solverInformation_2.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#0072BD");
    h17 = plot(solverInformation_2.primalSequence(1,1:end-1), solverInformation_2.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);
    
    % Plot solution point
    h18 = plot(solverInformation_3.primalSequence(1,end), solverInformation_3.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#D95319");
    h19 = plot(solverInformation_3.primalSequence(1,1:end-1), solverInformation_3.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);
    
    % Plot solution point
    h20 = plot(solverInformation_4.primalSequence(1,end), solverInformation_4.primalSequence(2,end), 'black', 'MarkerSize', 16, 'Marker', 'pentagram', 'MarkerFaceColor', "#77AC30");
    h21 = plot(solverInformation_4.primalSequence(1,1:end-1), solverInformation_4.primalSequence(2,1:end-1), 'black', 'LineStyle', "--", 'LineWidth', 2);

hold off

legend([h5, h11, h13, h15, h14, h16, h18, h20],{'Local Minimum', 'Saddle Point', 'Local Maximum', 'Paths', sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x1(1), x1(2)), sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x2(1), x2(2)), sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x3(1),x3(2)), sprintf('Solution with x_{0} = (%0.2f, %0.2f)',x4(1),x4(2))}, 'Location','southeast')

xlim([x1_l x1_u])
ylim([x2_l x2_u])
%title('Contour Plot of Linear Program', 'FontSize',20)
xlabel('$x_{1}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('$x_{2}$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')

%% 4.9) Compare with fmincon or other solvers

% We should also provide statistics from scalable problems:
% 1) Size of problem (n) on x-axis and time-to-completion on y-axis.
% 1) Size of problem (n) on x-axis and number of iterations on y-axis.

%% HELPER

test = nonlcon(x0);
disp(cub - test);
disp(test - clb);
