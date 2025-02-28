function [H,g,A,b,C,dl,du,l,u] = GeneratorBoxQP(n,alpha,beta,density)
% RandomQP Generates data for a random convex QP
%
%
%   min 0.5 x  H x + g’ x
%   x
%   s.t. bl <= A  x <= bu
%       l <= x <= u
%
% Syntax: [H,g,bl,A,bu,l,u] = GeneratorQPRandom(n,alpha,density)
%
% Inputs:
% n number of variabels
% alpha regularization factor. alpha > 0
% density density of sparse matrix. 0 < density < 1
%
% Outputs: QP data

    m = beta*n;
    b = zeros(0,1);
    A = zeros(n,0);
    C = sprandn(n,m,density);
    dl = -rand(m,1);
    du = rand(m,1);
    M = sprandn(n,n,density);
    H = M*M' + alpha*eye(n,n);
    g = randn(n,1);
    l = -ones(n,1);
    u = ones(n,1);