function derivative_values = project_derivative_approximation( ...
    x_nodes, F_nodes, evaluation_points, stencil_size)
%PROJECT_DERIVATIVE_APPROXIMATION Evaluate the numerical derivative.
%
% Inputs:
%   x_nodes           Nodes used to construct local interpolants
%   F_nodes           Numerical values of the project function
%   evaluation_points Points at which the derivative is required
%   stencil_size      Number of nodes in each local stencil
%
% Output:
%   derivative_values Numerical approximation of F'(x)

    [~, derivative_values] = local_newton_interpolant( ...
        x_nodes, ...
        F_nodes, ...
        evaluation_points, ...
        stencil_size ...
    );
end