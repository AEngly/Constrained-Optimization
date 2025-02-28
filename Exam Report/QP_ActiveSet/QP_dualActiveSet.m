
function [xk, muk] = QP_dualActiveSet(G, g, A, b, max_iter, tol)

% ---------------- DESCRIPTION --------------
%
% Name: QP_dualActiveSet   
% Type: Primal-Dual Active-Set QP Solver
%
% Problem structure:
%          min  g'*x
%           x
%          s.t. A x  = b      (Lagrange multiplier: mu)
%                 x >= 0      (Lagrange multiplier: lamba)
%
% Syntax: [x,info,mu,lambda,iter] = QP_dualActiveSet(g,A,b,x)
%
%         info = true   : Converged
%              = false  : Not Converged
%
% Created: 24.03.2023
% Authors: Andreas Engly (s170303) and Karl Takeuchi-Storm (s130377)
%          IMM, Technical University of Denmark
%
% ---------------- IMPLEMENTATION --------------

% Tolerances in equality checks
tol1 = tol;

% Get number of constraints
[n, m] = size(A);

% Find initial, feasible solution
xk = -G \ g;
muk = zeros(m,1);
Wk = false(m,1);

ci = A(:,~Wk)'*xk - b(~Wk);

% Max iter
iter = 1;

while iter < max_iter

    if all(ci(~Wk) >= 0)
        fprintf("Optimal solution found!\n");
        break;
    end

    % Select a r
    ci = A'*xk - b;
    r = ci(~Wk) == min(ci(~Wk));

    % Enter loop
    while ci(r) < 0

        % Index vector
        index_j = find(Wk == 1);

        % Compute direction in primal and dual space
        Ak = A(:,Wk);
        mk = sum(Wk);
        ar = A(:,r);

        % Construct KKT matrix
        row1 = [G -Ak];
        row2 = [-Ak' zeros(mk, mk)];
        LHS = [row1; row2];
        RHS = [ar; zeros(mk,1)];

        % We can solve the system in many ways. Initially, we start by
        % using default method (later range-space and null-space).
        results = LHS \ RHS;
        p = results(1:n);
        v = results(n+1:end);

        if norm(ar'*p) < tol1
            % Infeasibility check
            if all(v >= 0)
                fprintf("\nThe primal problem is infeasible.\n");
                break;
            else
                % Take step in dual space and remove constraints
                idx_bool = v < 0;
                idx_index_j = index_j(idx_bool);
                t = min(-muk(idx_index_j) ./ v(idx_bool));
                j = (-muk(idx_index_j) ./ v(idx_bool)) == t;
                ij = idx_index_j(j);

                % Update variables
                muk(index_j) = muk(index_j) + t*v;
                muk(r) = muk(r) + t;

                % Update working set Wk
                Wk(ij) = 0;
            end
        else

            % Take step in dual space and remove constraints
            idx_bool = v < 0;
            idx_index_j = index_j(idx_bool);
            t1 = min([Inf; min(-muk(idx_index_j) ./ v(idx_bool))]);
            t2 = -ci(r)/(A(:,r)' * p);

            if t2 <= t1
                % Take full step and add constraint r to the working set.
                xk = xk + t2*p;
                if mk > 0
                    muk(index_j) = muk(index_j) + t2*v;
                end
                muk(r) = muk(r) + t2;
                Wk(r) = 1;
            else
                % Take partial step and remove a constraint from the working set.
                j = (-muk(idx_index_j) ./ v(idx_bool)) == min((-muk(idx_index_j) ./ v(idx_bool)));
                ij = idx_index_j(j);
                xk = xk + t1*p;
                muk_prev = muk;
                muk(idx_index_j) = muk(idx_index_j) + t1*v;
                muk(r) = muk_prev(r) + t1;
                Wk(ij) = 0;       
            end
        end

        % Update constraint values.
        ci = A'*xk - b;

    end

    iter = iter + 1;
end
end