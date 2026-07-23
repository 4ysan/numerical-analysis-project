function [polynomial_value, derivative_value] = ...
    evaluate_newton_polynomial( ...
        x_nodes, coefficients, evaluation_points)
%EVALUATE_NEWTON_POLYNOMIAL Evaluate a Newton polynomial and derivative.
%
% Inputs:
%   x_nodes           Interpolation nodes
%   coefficients      Newton divided-difference coefficients
%   evaluation_points Points at which the polynomial is evaluated
%
% Outputs:
%   polynomial_value  Value of the Newton interpolation polynomial
%   derivative_value  Value of its first derivative

    %% Validate coefficient and node vectors
    if ~isvector(x_nodes) || ~isvector(coefficients)
        error('The nodes and coefficients must be vectors.');
    end

    x_nodes = x_nodes(:);
    coefficients = coefficients(:);

    number_of_nodes = numel(x_nodes);

    if number_of_nodes ~= numel(coefficients)
        error('The nodes and coefficients must have equal lengths.');
    end

    if number_of_nodes < 2
        error('At least two Newton coefficients are required.');
    end

    if any(~isreal(x_nodes)) || any(~isfinite(x_nodes))
        error('The interpolation nodes must be finite and real.');
    end

    if any(~isreal(coefficients)) || any(~isfinite(coefficients))
        error('The Newton coefficients must be finite and real.');
    end

    if any(~isreal(evaluation_points), 'all') || ...
            any(~isfinite(evaluation_points), 'all')

        error('The evaluation points must be finite and real.');
    end

    %% Generalized Horner evaluation
    polynomial_value = ...
        coefficients(end) .* ones(size(evaluation_points));

    derivative_value = zeros(size(evaluation_points));

    for k = number_of_nodes - 1:-1:1

        derivative_value = ...
            derivative_value ...
            .* (evaluation_points - x_nodes(k)) ...
            + polynomial_value;

        polynomial_value = ...
            polynomial_value ...
            .* (evaluation_points - x_nodes(k)) ...
            + coefficients(k);
    end
end