
% ---------------- DESCRIPTION --------------
%
% Name: Driver for Problem 1
% Type: Execution File
%
% Problem structure:
%           min     0.5 x' H x + g' x
%            x
%           s.t.    A'x + b = 0
%
% Created: 30.03.2023
% Authors: Andreas Engly (s170303) and Karl Takeuchi-Storm (s130377)
%          Compute, Technical University of Denmark
%
% ---------------- IMPLEMENTATION --------------

alpha = 0.15;
beta = 0.05; % Must be 0 < beta < 1
density = 0.15; % 15% must be non-zero

% Options for quadprog
options =  optimoptions('quadprog','Display','off');

n = 500;
step = 10;

smoother = 10;
problem_sizes = 10:step:n;

l = size(problem_sizes,2);
TTC = zeros(6,l,smoother);
TTC_avg = zeros(6,l);
j = 1;

problem_sizes = 10:step:n;

for i = problem_sizes

    % Display
    %fprintf('Problem size: %d\n', i);

    for k = 1:smoother

        [H,g,A,b] = updated_GeneratorECQP(i,alpha,beta,density);

        TTC(1,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUdense");
        TTC(2,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUsparse");
        TTC(3,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLdense");
        TTC(4,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLsparse");
        TTC(5,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "RangeSpace");
        TTC(6,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "NullSpace");
        %TTC(7,j,k) = cpuTimer(@quadprog, H, g, A', b, [], [], [], [], [], options);

    end

    TTC_avg(1,j) = mean(TTC(1,j,:));
    TTC_avg(2,j) = mean(TTC(2,j,:));
    TTC_avg(3,j) = mean(TTC(3,j,:));
    TTC_avg(4,j) = mean(TTC(4,j,:));
    TTC_avg(5,j) = mean(TTC(5,j,:));
    TTC_avg(6,j) = mean(TTC(6,j,:));
    %TTC_avg(7,j) = mean(TTC(7,j,:));

    j = j + 1;

end

%% Plotting the comparison (with quadprog)
%{
figure,
hold on

    for i=1:7
        plot(problem_sizes, TTC_avg(i,:));
    end
    
    legend('LUdense', 'LUsparse', 'LDLdense', 'LDLsparse', 'RangeSpace', 'NullSpace', 'quadprog')
    xlabel("n")
    ylabel("CPU time")

hold off

saveas(gcf,'./Plots/ComparisonSolvers1.png')
%}
%% Plotting the comparison (without quadprog)

figure,
hold on

    for i=1:6
        plot(problem_sizes, TTC_avg(i,:));
    end
    
    legend('LUdense', 'LUsparse', 'LDLdense', 'LDLsparse', 'RangeSpace', 'NullSpace')
    xlabel("n")
    ylabel("CPU time")

hold off

saveas(gcf,'./Plots/ComparisonSolvers_beta_0_05.png')


%% beta 0.2

beta = 0.2;

TTC = zeros(6,l,smoother);
TTC_avg = zeros(6,l);
j = 1;

for i = problem_sizes

    % Display
    %fprintf('Problem size: %d\n', i);

    [H,g,A,b] = updated_GeneratorECQP(i,alpha,beta,density);

    for k = 1:smoother

        TTC(1,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUdense");
        TTC(2,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUsparse");
        TTC(3,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLdense");
        TTC(4,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLsparse");
        TTC(5,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "RangeSpace");
        TTC(6,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "NullSpace");
        %TTC(7,j,k) = cpuTimer(@quadprog, H, g, A', b, [], [], [], [], [], options);

    end

    TTC_avg(1,j) = mean(TTC(1,j,:));
    TTC_avg(2,j) = mean(TTC(2,j,:));
    TTC_avg(3,j) = mean(TTC(3,j,:));
    TTC_avg(4,j) = mean(TTC(4,j,:));
    TTC_avg(5,j) = mean(TTC(5,j,:));
    TTC_avg(6,j) = mean(TTC(6,j,:));
    %TTC_avg(7,j) = mean(TTC(7,j,:));

    j = j + 1;

end

figure,
hold on

    for i=1:6
        plot(problem_sizes, TTC_avg(i,:));
    end
    
    legend('LUdense', 'LUsparse', 'LDLdense', 'LDLsparse', 'RangeSpace', 'NullSpace')
    xlabel("n")
    ylabel("CPU time")

hold off

saveas(gcf,'./Plots/ComparisonSolvers_beta_0_2.png')
%% beta 0.5

beta = 0.5;

TTC = zeros(6,l,smoother);
TTC_avg = zeros(6,l);
j = 1;

for i = problem_sizes

    % Display
    %fprintf('Problem size: %d\n', i);

    [H,g,A,b] = updated_GeneratorECQP(i,alpha,beta,density);

    for k = 1:smoother

        TTC(1,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUdense");
        TTC(2,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUsparse");
        TTC(3,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLdense");
        TTC(4,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLsparse");
        TTC(5,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "RangeSpace");
        TTC(6,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "NullSpace");
        %TTC(7,j,k) = cpuTimer(@quadprog, H, g, A', b, [], [], [], [], [], options);

    end

    TTC_avg(1,j) = mean(TTC(1,j,:));
    TTC_avg(2,j) = mean(TTC(2,j,:));
    TTC_avg(3,j) = mean(TTC(3,j,:));
    TTC_avg(4,j) = mean(TTC(4,j,:));
    TTC_avg(5,j) = mean(TTC(5,j,:));
    TTC_avg(6,j) = mean(TTC(6,j,:));
    %TTC_avg(7,j) = mean(TTC(7,j,:));

    j = j + 1;

end

figure,
hold on

    for i=1:6
        plot(problem_sizes, TTC_avg(i,:));
    end
    
    legend('LUdense', 'LUsparse', 'LDLdense', 'LDLsparse', 'RangeSpace', 'NullSpace')
    xlabel("n")
    ylabel("CPU time")

hold off

saveas(gcf,'./Plots/ComparisonSolvers_beta_0_5.png')
%% beta 0.8

beta = 0.8;

TTC = zeros(6,l,smoother);
TTC_avg = zeros(6,l);
j = 1;

for i = problem_sizes

    % Display
    %fprintf('Problem size: %d\n', i);

    [H,g,A,b] = updated_GeneratorECQP(i,alpha,beta,density);

    for k = 1:smoother

        TTC(1,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUdense");
        TTC(2,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUsparse");
        TTC(3,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLdense");
        TTC(4,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLsparse");
        TTC(5,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "RangeSpace");
        TTC(6,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "NullSpace");
        %TTC(7,j,k) = cpuTimer(@quadprog, H, g, A', b, [], [], [], [], [], options);

    end

    TTC_avg(1,j) = mean(TTC(1,j,:));
    TTC_avg(2,j) = mean(TTC(2,j,:));
    TTC_avg(3,j) = mean(TTC(3,j,:));
    TTC_avg(4,j) = mean(TTC(4,j,:));
    TTC_avg(5,j) = mean(TTC(5,j,:));
    TTC_avg(6,j) = mean(TTC(6,j,:));
    %TTC_avg(7,j) = mean(TTC(7,j,:));

    j = j + 1;

end

figure,
hold on

    for i=1:6
        plot(problem_sizes, TTC_avg(i,:));
    end
    
    legend('LUdense', 'LUsparse', 'LDLdense', 'LDLsparse', 'RangeSpace', 'NullSpace')
    xlabel("n")
    ylabel("CPU time")

hold off

saveas(gcf,'./Plots/ComparisonSolvers_beta_0_8.png')
%% beta 0.95
beta = 0.95;

[TTC_avg] = dataGatheringLoop(beta, problem_sizes, smoother, l, alpha, density);

figure,
hold on

    for i=1:6
        plot(problem_sizes, TTC_avg(i,:));
    end
    
    legend('LUdense', 'LUsparse', 'LDLdense', 'LDLsparse', 'RangeSpace', 'NullSpace')
    xlabel("n")
    ylabel("CPU time")

hold off

saveas(gcf,'./Plots/ComparisonSolvers_beta_0_95.png')

%% data gathering loop

function [TTC_avg] = dataGatheringLoop(beta, problem_sizes, smoother, l, alpha, density) 
    TTC = zeros(6,l,smoother);
    TTC_avg = zeros(6,l);
    j = 1;

    for i = problem_sizes
    
        % Display
        %fprintf('Problem size: %d\n', i);
    
        [H,g,A,b] = updated_GeneratorECQP(i,alpha,beta,density);
    
        for k = 1:smoother
    
            TTC(1,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUdense");
            TTC(2,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LUsparse");
            TTC(3,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLdense");
            TTC(4,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "LDLsparse");
            TTC(5,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "RangeSpace");
            TTC(6,j,k) = cpuTimer(@EqualityQPSolver, H, g, A, b, "NullSpace");
            %TTC(7,j,k) = cpuTimer(@quadprog, H, g, A', b, [], [], [], [], [], options);
    
        end
    
        TTC_avg(1,j) = mean(TTC(1,j,:));
        TTC_avg(2,j) = mean(TTC(2,j,:));
        TTC_avg(3,j) = mean(TTC(3,j,:));
        TTC_avg(4,j) = mean(TTC(4,j,:));
        TTC_avg(5,j) = mean(TTC(5,j,:));
        TTC_avg(6,j) = mean(TTC(6,j,:));
        %TTC_avg(7,j) = mean(TTC(7,j,:));
    
        j = j + 1;
    
    end
end