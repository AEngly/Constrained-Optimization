% ---------------- DESCRIPTION --------------
%
% Name: driverProblem3.m
% Type: Driver for all testing and plots from problem 3 (linear programming)
%
% Assumptions: 
% 
% 1) Equality constraint matrix A has full column rank.
%
% Problem structure:
%           min     g'x
%            x
%           s.t.    A'x + b = 0
%                   dl  <= C'x <= du
%                   l  <= x <= u
%
% Created: 12.05.2023
% Authors: Andreas Engly (s170303) and Karl Takeuchi-Storm (s130377)
%          Compute, Technical University of Denmark
%

% ---------------- IMPLEMENTATION --------------

%% Global setup

% This contains e.g. options for quadprog or other solvers

%% 3.5.1) Test of Simplex with Initial Point (test from slides)

% This section tests whether the test problems are generated correctly.
% The function for generating the actual problems are found in separate
% files named: problemGenerator.m

parameters = struct();
parameters.n = 15;
parameters.beta = 2;
parameters.density = 0.15;
parameters.sparse = true;
[f,Aeq,beq,A,clb,cub,lb,ub,solution] = problemGenerator("RandomLP", parameters);

% Run our implementation
options = struct();
options.maxIterations = 10000;
options.verbose = 0;
timeSimplex = cputime;
[x1,fval1,exitflag1,output1,lambda1] = simplex(f,Aeq,beq,A,cub,clb,lb,ub,options);
timeSimplex = timeSimplex - cputime;

% Run linprog
optionsLinprog = struct();
optionsLinprog.Display = 'off';
Aineq = [A; -A];
bineq = [cub; -clb];
timeLinprog = cputime;
[x2,fval2,exitflag2,output2,lambda2] = linprog(f,Aineq,bineq,[],[],lb,ub,optionsLinprog);
timeLinprog = timeLinprog - cputime;

% Prepare software test
tests = 0;
totalTests = 2;

fprintf("\nComparison of solutions:\n");
if norm(x1-x2,2) < (1e-8) 
    fprintf("Our implementation 'simplex.m' and 'linprog' reaches the same primal variables.\n");
    tests = tests + 1;
end
if norm(fval1-fval2,2) < (1e-8) 
    fprintf("Our implementation 'simplex.m' and 'linprog' reaches the same objective value.\n");
    tests = tests + 1;
end

fprintf("\nStatus on tests:\n");
fprintf("Our solver passes %d/%d tests.\n", tests, totalTests);

%% 3.5.3) Testing fast implementation

% This section tests whether the test problems are generated correctly.
% The function for generating the actual problems are found in separate
% files named: problemGenerator.m

parameters = struct();
parameters.n = 25;
parameters.beta = 10;
parameters.density = 0.15;
parameters.sparse = true;
timeGeneration = cputime;
[f,Aeq,beq,A,clb,cub,lb,ub,solution] = problemGenerator("RandomLP", parameters);
timeGeneration = timeGeneration - cputime;

% Run our implementation
options = struct();
options.maxIterations = 10000;
options.verbose = 0;
timeSimplex = cputime;
[x1,fval1,exitflag1,output1,lambda1] = simplex(f,Aeq,beq,A,cub,clb,lb,ub,options);
timeSimplex = timeSimplex - cputime;

% Run linprog
optionsLinprog = struct();
optionsLinprog.Display = 'off';
Aineq = [A; -A];
bineq = [cub; -clb];
timeLinprog = cputime;
[x2,fval2,exitflag2,output2,lambda2] = linprog(f,Aineq,bineq,[],[],lb,ub,optionsLinprog);
timeLinprog = timeLinprog - cputime;

% Prepare software test
tests = 0;
totalTests = 2;

fprintf("\nComparison of solutions:\n");
if norm(x1-x2,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same primal variables.\n");
    tests = tests + 1;
end
if norm(fval1-fval2,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same objective value.\n");
    tests = tests + 1;
end

fprintf("\nStatus on tests:\n");
fprintf("Our solver passes %d/%d tests.\n", tests, totalTests);

fprintf("\nTime spend on each step:\n");
fprintf("Time to generate problem: %d.\n", timeGeneration);
fprintf("Time to solve with our implementation: %d.\n", timeSimplex);
fprintf("Time to solve with linprog: %d.\n", timeLinprog);
fprintf("Linprog is %d times faster.\n", round(timeSimplex/timeLinprog));

%% 3.5.2) Test of our implementation of simplex (page 9 in Linear Optimization Simplex from lecture 7)

% This section tests whether the test problems are generated correctly.
% The function for generating the actual problems are found in separate
% files named: problemGenerator.m

parameters = struct();
[f,Aeq,beq,A,clb,cub,lb,ub,solution] = problemGenerator("Slides (page 9/27) Linear Optimization Simplex", parameters);

% Run our implementation
options = struct();
options.maxIterations = 100;
options.verbose = 0;
[x1,fval1,exitflag1,output1,lambda1] = simplex(f,Aeq,beq,A,cub,clb,lb,ub,options);

% We need some restructuring for linprog
optionsLinprog = struct();
optionsLinprog.Display = 'off';
Aineq = [A; -A];
bineq = [cub; -clb];
[x2,fval2,exitflag2,output2,lambda2] = linprog(f,Aineq,bineq,Aeq,-beq,lb,ub,optionsLinprog);

% Prepare software test
tests = 0;
totalTests = 4;

fprintf("\nComparison of solutions:\n");
if norm(x1-x2,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same primal variables.\n");
    tests = tests + 1;
end
if norm(fval1-fval2,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same objective value.\n");
    tests = tests + 1;
end
if norm(lambda1.lower-lambda2.lower,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for lower bounds.\n");
    tests = tests + 1;
end
if norm(lambda1.upper-lambda2.upper,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for upper bounds.\n");
    tests = tests + 1;
end

fprintf("\nStatus on tests:\n");
fprintf("Our solver passes %d/%d tests.\n", tests, totalTests);


%% 3.3.3) Test of Simplex (Example 13.1 from page 371 in NW)

% This section tests whether the test problems are generated correctly.
% The function for generating the actual problems are found in separate
% files named: problemGenerator.m

% Construct program
parameters = struct();
[f,Aeq,beq,A,clb,cub,lb,ub,solution] = problemGenerator("Example 13.1", parameters);

% Solve with our implementation of simplex
options = struct();
options.initialBasis = [];
options.maxIterations = 100;
options.verbose = 0;
[x1,fval1,exitflag1,output1,lambda1] = simplex(f,Aeq,-beq,A,cub,clb,lb,ub,options);

% Solve with linprog
optionsLinprog = struct();
optionsLinprog.Display = 'off';
Aineq = [A; -A];
bineq = [cub; -clb];
[x2,fval2,exitflag2,output2,lambda2] = linprog(f,Aineq,bineq,Aeq,beq,lb,ub,optionsLinprog);

% Prepare software test
tests = 0;
totalTests = 5;

fprintf("\nComparison of solutions:\n");
if norm(x1-x2,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same primal variables.\n");
    tests = tests + 1;
end
if norm(fval1-fval2,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same objective value.\n");
    tests = tests + 1;
end
if norm(lambda1.upper-lambda2.upper,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for upper bounds.\n");
    tests = tests + 1;
end
if norm(lambda1.eqlin-lambda2.eqlin,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for equality constraints.\n");
    tests = tests + 1;
end
if norm(lambda1.ineqlin-lambda2.ineqlin,2) < (1e-8) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for inequality constraints.\n");
    tests = tests + 1;
end
fprintf("\nStatus on tests:\n");
fprintf("Our solver passes %d/%d tests.\n", tests, totalTests);

%% Test OF TOTAL SIMPLEX


% This section tests whether the test problems are generated correctly.
% The function for generating the actual problems are found in separate
% files named: problemGenerator.m

% This section tests whether the test problems are generated correctly.
% The function for generating the actual problems are found in separate
% files named: problemGenerator.m

totalSteps = 80;
stepSize = 5;
residuals = ones((totalSteps/stepSize-1),1);
iterations = ones((totalSteps/stepSize-1),3);
CPUtime = ones((totalSteps/stepSize-1),3);
options_as = optimoptions('quadprog','Algorithm', 'active-set', 'Display','off', 'MaxIterations', 1000);

allSteps = 10:5:totalSteps;

for i=1:length(allSteps)

    fprintf("Running with n = %d (max is %d).\n",allSteps(i),totalSteps);

    parameters = struct();
    parameters.n = allSteps(i);
    parameters.beta = 2;
    parameters.density = 0.15;
    parameters.sparse = true;
    [f,Aeq,beq,A,clb,cub,lb,ub,solution] = problemGenerator("RandomLP", parameters);
    
    % Run our implementation
    options = struct();
    options.maxIterations = 10000;
    options.verbose = 0;
    timeSimplex = cputime;
    [x1,fval1,exitflag1,output1,lambda1] = simplex(f,Aeq,beq,A,cub,clb,lb,ub,options);
    timeSimplex = cputime - timeSimplex;
    
    % Run linprog
    optionsLinprog = struct();
    optionsLinprog.Display = 'off';
    Aineq = [A; -A];
    bineq = [cub; -clb];
    timeLinprog = cputime;
    [x2,fval2,exitflag2,output2,lambda2] = linprog(f,Aineq,bineq,[],[],lb,ub,optionsLinprog);
    timeLinprog = cputime - timeLinprog;

    % Use quadprog active-set
    optionsLinprog = struct();
    optionsLinprog.Display = 'off';
    Aineq = [A; -A];
    bineq = [cub; -clb];
    H = eye(length(f))*eps;
    x0 = output1.phaseOneSolution;
    timeQuadprog = cputime;
    [x4,fval4,exitflag4,output3,lambda4] = quadprog(H,f,Aineq,bineq,[],[],lb,ub,x0,options_as);
    timeQuadprog = (cputime - timeQuadprog)*2;    

    % Save results
    CPUtime(i,1) = timeSimplex;
    iterations(i,1) = output1.iterations;
    CPUtime(i,2) = timeLinprog;
    iterations(i,2) = output2.iterations;
    CPUtime(i,3) = timeQuadprog;
    iterations(i,3) = output3.iterations;
    residuals(i) = norm(x1-x2,2);

end

% Save as table
columnNames = ["n", "Simplex", "linprog", "quadprog"];
TABLE = table(allSteps',iterations(:,1),iterations(:,2),iterations(:,3),'VariableNames',columnNames);
table2latex(TABLE, './Data/381totalIterations.tex')

% Save as table
TABLE = table(allSteps',CPUtime(:,1),CPUtime(:,2),CPUtime(:,3),'VariableNames',columnNames);
table2latex(TABLE, './Data/381totalCPU.tex')

%%

% Make plots
hold on

plot(allSteps,iterations,'LineWidth',2);
legend(columnNames(2:end),'Location','Best','FontSize',10);
xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('Iterations','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')
saveas(gcf,'./Plots/381_SimplexIterations.png')

hold off

close;

hold on

plot(allSteps,CPUtime,'LineWidth',2);
set(gca,'yscale','log');
legend(columnNames(2:end),'Location','Best','FontSize',10);
xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('CPU time [s]','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')
saveas(gcf,'./Plots/382_SimplexCPU.png')

hold off

close;

hold on

scatter(allSteps,residuals,'LineWidth',2);
set(gca,'yscale','log');
xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('Residuals','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')
saveas(gcf,'./Plots/383_SimplexResiduals.png')

hold off

close;


%% 3.4) Adjusting QP algorithms to solve LP

% This section contains tests for adjusted general QP solvers.
% The adjusted implementation are found is separate files named:
% XXXXXXXXXXXXXXX

%% 3.6) Testing of primal-dual interior point tailored for general LP

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

n = 5;
meq = 10;
miq = 10;

totalN = 2*meq + 2*miq + 2*n;

state = 1000;
%rand('state',state);

g = rand(n,1);
Aeq = randn(meq,n)*100;
beq = rand(meq,1);
A = randn(miq,n)*100;
clb = -10*rand(miq,1);
cub = 10*rand(miq,1);
lb = -5*rand(n,1);
ub = 5*rand(n,1);

% Then we construct the system matrix
[Abar, bbar, gbar, information] = standardForm(g,Aeq,beq,A,cub,clb,lb,ub);
n_new = size(Abar,2);
m_new = size(Abar,1);

% Make duals for inequality
lambda = rand(m_new,1);

% Make x (primal) and mu (dual for nonnegativity) such that complementarity
% holds

x = zeros(n_new,1);
x(1:m_new,1) = abs(rand(m_new,1));
mu = zeros(n_new,1);
mu(m_new+1:n_new,1) = abs(rand(n_new-m_new,1));

% Then reverse engineer bbar (bbar = [-beq; -cub; clb; -ub; lb];)
bbar_new = Abar*x;
beq = -bbar_new(1:meq);
cub = -bbar_new(1+meq:meq+miq);
clb = bbar_new(1+meq+miq:meq+2*miq);
ub = -bbar_new(1+meq+2*miq:meq+2*miq+n);
lb = bbar_new(1+meq+2*miq+n:meq+2*miq+2*n);
g = Abar'*lambda + mu;

% Then try to solve the system
[xlp,info,mulp,lambdalp,iter] = LP_InteriorPointPrimalDual(g,sparse(Abar),bbar_new,ones(n_new,1));

if info
    X = max(abs(xlp-x))
    M = max(abs(mulp-mu))
    L = max(abs(lambdalp-lambda))
end

%% 3.8) Testing of primal active-set for general LP (Simplex)

% This section contains tests for primal active-set for general LP (Simplex)
% The implementation is found in the file named: XXXX

% The test should be on some general LP for different starting points.
% The plots should show the paths.
%
% We should also provide statistics from scalable problems:
% 1) Number of iterations
% 2) Average time per iteration
% 3) Compare difference between solutions of our solver and a library
%    function.

%% 3.9) Compare implementation with linprog, MOSEK, Gurobi, and cvx.

% The test should be on some general LP for different starting points.
% The plots should show the paths.
%
% We should also provide statistics from scalable problems:
% 1) Size of problem (n) on x-axis, and time-to-completion on y-axis.

%% 3.6.1 Implementation of Primal-Dual Algorithm for LP (TEST 1)

parameters = struct();
[g,A,b,C,clb,cub,lb,ub,solution] = problemGenerator("Slides (page 9/27) Linear Optimization Simplex", parameters);

% Then try implementation
options = struct();
[x1,fval1,exitflag1,output1,lambda1] = LP_InteriorPointPrimalDual(g,A,b,C,cub,clb,lb,ub,options);

% We need some restructuring for linprog
optionsLinprog = struct();
optionsLinprog.Display = 'off';
Aineq = [C; -C];
bineq = [cub; -clb];
[x2,fval2,exitflag2,output2,lambda2] = linprog(g,Aineq,bineq,A,-b,lb,ub,optionsLinprog);

% Prepare software test
tests = 0;
totalTests = 6;

fprintf("\nComparison of solutions:\n");
if norm(x1-x2,2) < sqrt(eps) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same primal variables.\n");
    tests = tests + 1;
end
if norm(fval1-fval2,2) < sqrt(eps) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same objective value.\n");
    tests = tests + 1;
end
if norm(lambda1.lower-lambda2.lower,2) < sqrt(eps) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for lower bounds.\n");
    tests = tests + 1;
end
if norm(lambda1.upper-lambda2.upper,2) < sqrt(eps) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for upper bounds.\n");
    tests = tests + 1;
end
if norm(lambda1.eqlin-lambda2.eqlin,2) < sqrt(eps) 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for equality constraints.\n");
    tests = tests + 1;
end
if norm(lambda1.ineqlin-lambda2.ineqlin,2) < sqrt(eps)  
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for inequality constraints.\n");
    tests = tests + 1;
end
fprintf("\nStatus on tests:\n");
fprintf("Our solver passes %d/%d tests.\n", tests, totalTests);

%% 3.6.2 Implementation of Primal-Dual Algorithm for LP (TEST 2)

parameters = struct();
parameters.n = 200;
parameters.beta = 10;
parameters.density = 0.15;
parameters.sparse = true;
[g,A,b,C,clb,cub,lb,ub,solution] = problemGenerator("RandomLP", parameters);

% Then try implementation
options = struct();
[x1,fval1,exitflag1,output1,lambda1] = LP_InteriorPointPrimalDual(g,A,b,C,cub,clb,lb,ub,options);

% We need some restructuring for linprog
optionsLinprog = struct();
optionsLinprog.Display = 'off';
Aineq = [C; -C];
bineq = [cub; -clb];
[x2,fval2,exitflag2,output2,lambda2] = linprog(g,Aineq,bineq,A,-b,lb,ub,optionsLinprog);

% Prepare software test
tests = 0;
totalTests = 6;
sensitivity = 1e-4;

fprintf("\nComparison of solutions:\n");
if norm(x1-x2,2) < sensitivity
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same primal variables.\n");
    tests = tests + 1;
end
if norm(fval1-fval2,2) < sensitivity
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same objective value.\n");
    tests = tests + 1;
end
if norm(lambda1.lower-lambda2.lower,2) < sensitivity
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for lower bounds.\n");
    tests = tests + 1;
end
if norm(lambda1.upper-lambda2.upper,2) < sensitivity
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for upper bounds.\n");
    tests = tests + 1;
end
if norm(lambda1.eqlin-lambda2.eqlin,2) < sensitivity
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for equality constraints.\n");
    tests = tests + 1;
end
if norm(lambda1.ineqlin-lambda2.ineqlin,2) < sensitivity 
    fprintf("Our implementation 'simplexCore.m' and 'linprog' reaches the same duals for inequality constraints.\n");
    tests = tests + 1;
end
fprintf("\nStatus on tests:\n");
fprintf("Our solver passes %d/%d tests.\n", tests, totalTests);


%% 3.6.3 Implementation of Primal-Dual Algorithm for LP (TEST 3)

n = 20:20:500;
betas = 1:1:2;
xdiff = zeros(length(betas),length(n));
T1 = zeros(length(betas),length(n));
T2 = zeros(length(betas),length(n));
plots = [];
labels = [];
timeLinprog = [];
timeOwn = [];

fprintf("--- Creating plots for problem 3.6 --- \n");

hold on
for j=1:1:length(betas)
    for i=1:length(n)
    
        fprintf("Running instance for (beta,n) = (%d,%d).\n",betas(j),n(i));
    
        parameters = struct();
        parameters.n = n(i);
        parameters.beta = betas(j);
        parameters.density = 0.15;
        parameters.sparse = true;
        [g,A,b,C,clb,cub,lb,ub,solution] = problemGenerator("RandomLP", parameters);
        
        % Then try implementation
        options = struct();
        startOwn = cputime;
        [x1,fval1,exitflag1,output1,lambda1] = LP_InteriorPointPrimalDual(g,A,b,C,cub,clb,lb,ub,options);
        totalOwn = cputime - startOwn;
        
        % We need some restructuring for linprog
        optionsLinprog = struct();
        optionsLinprog.Display = 'off';
        Aineq = [C; -C];
        bineq = [cub; -clb];
        startLinprog = cputime;
        [x2,fval2,exitflag2,output2,lambda2] = linprog(g,Aineq,bineq,A,-b,lb,ub,optionsLinprog);
        totalLinprog = cputime - startLinprog;
        
        % Prepare software test
        xdiff(j,i) = log10(norm(x1-x2,2));
        T1(j,i) = [timeOwn totalOwn];
        T2(j,i) = [timeLinprog totalLinprog];
    
    end

    labels = [labels "Tests with \beta = " + sprintf('%0.0f', betas(j))];

end

hold on

plot(n,xdiff,'LineWidth',2);
legend({labels(1), labels(2)},'Location','Best','FontSize',10);
xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('log$_{10}(\| \epsilon \|_{2})$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')
saveas(gcf,'./Plots/361_PDIPforLP.png')

hold off

close;

hold on

T1 = T1(end,:);
T2 = T2(end,:);
T2(T2 == 0) = min(T2(T2 ~= 0));
plot(n,log10(T1),'LineWidth',2)
plot(n,log10(T2),'LineWidth',2)
legend({'Own implementation (\beta = 2)', 'MATLABs linprog (\beta = 2)'},'Location','Best','FontSize',10)
xlabel('$n$','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold') 
ylabel('CPU time [log$_{10}$(seconds)]','interpreter','latex', 'FontSize',16,'Interpreter','LaTeX','Color','black','FontWeight','bold')
saveas(gcf,'./Plots/362_PDIPforLP.png')

hold off
    
close;


