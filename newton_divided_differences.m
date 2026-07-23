function coefficients = ...
    newton_divided_differences(x_nodes, y_nodes)
%NEWTON_DIVIDED_DIFFERENCES Compute Newton interpolation coefficients.
%
% Inputs:
%   x_nodes  Distinct interpolation nodes
%   y_nodes  Function values at the interpolation nodes
%
% Output:
%   coefficients  Newton divided-difference coefficients

    %% Validate input shapes
    if ~isvector(x_nodes) || ~isvector(y_nodes)
        error('The interpolation nodes and values must be vectors.');
    end

    x_nodes = x_nodes(:);
    y_nodes = y_nodes(:);

    number_of_nodes = numel(x_nodes);

    if number_of_nodes ~= numel(y_nodes)
        error('The node and value vectors must have equal lengths.');
    end

    if number_of_nodes < 2
        error('At least two interpolation nodes are required.');
    end

    %% Validate numerical values
    if any(~isreal(x_nodes)) || any(~isfinite(x_nodes))
        error('The interpolation nodes must be finite and real.');
    end

    if any(~isreal(y_nodes)) || any(~isfinite(y_nodes))
        error('The function values must be finite and real.');
    end

    %% Reject repeated nodes
    if numel(unique(x_nodes)) ~= number_of_nodes
        error('The interpolation nodes must be distinct.');
    end

    %% Construct the divided-difference coefficients
    coefficients = y_nodes;

    for order = 2:number_of_nodes

        numerator = ...
            coefficients(order:number_of_nodes) ...
            - coefficients(order - 1:number_of_nodes - 1);

        denominator = ...
            x_nodes(order:number_of_nodes) ...
            - x_nodes(1:number_of_nodes - order + 1);

        coefficients(order:number_of_nodes) = ...
            numerator ./ denominator;
    end
end