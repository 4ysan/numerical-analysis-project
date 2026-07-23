function [interpolated_values, derivative_values, ...
          stencil_start_indices] = ...
    local_newton_interpolant( ...
        x_nodes, y_nodes, evaluation_points, stencil_size)
%LOCAL_NEWTON_INTERPOLANT Evaluate a local Newton interpolant.
%
% Inputs:
%   x_nodes           Strictly increasing interpolation nodes
%   y_nodes           Function values at the nodes
%   evaluation_points Points at which interpolation is required
%   stencil_size      Number of nearby nodes used in each local polynomial
%
% Outputs:
%   interpolated_values    Local interpolation values
%   derivative_values      Derivatives of the local interpolants
%   stencil_start_indices  Starting index of each selected stencil

    %% Validate node and value vectors
    if ~isvector(x_nodes) || ~isvector(y_nodes)
        error('The interpolation nodes and values must be vectors.');
    end

    x_nodes = x_nodes(:);
    y_nodes = y_nodes(:);

    number_of_nodes = numel(x_nodes);

    if number_of_nodes ~= numel(y_nodes)
        error('The node and value vectors must have equal lengths.');
    end

    if any(~isreal(x_nodes)) || any(~isfinite(x_nodes))
        error('The interpolation nodes must be finite and real.');
    end

    if any(~isreal(y_nodes)) || any(~isfinite(y_nodes))
        error('The function values must be finite and real.');
    end

    if any(diff(x_nodes) <= 0)
        error('The interpolation nodes must be strictly increasing.');
    end

    %% Validate stencil size
    if ~isscalar(stencil_size) || ...
            ~isreal(stencil_size) || ...
            ~isfinite(stencil_size) || ...
            stencil_size ~= floor(stencil_size) || ...
            stencil_size < 2 || ...
            stencil_size > number_of_nodes

        error(['The stencil size must be an integer between 2 ', ...
               'and the number of nodes.']);
    end

    %% Validate evaluation points
    if any(~isreal(evaluation_points), 'all') || ...
            any(~isfinite(evaluation_points), 'all')

        error('The evaluation points must be finite and real.');
    end

    if any(evaluation_points < x_nodes(1), 'all') || ...
            any(evaluation_points > x_nodes(end), 'all')

        error('Evaluation points must lie inside the node interval.');
    end

    %% Preserve the original output shape
    original_size = size(evaluation_points);
    evaluation_vector = evaluation_points(:);

    number_of_evaluation_points = numel(evaluation_vector);

    interpolated_vector = zeros(number_of_evaluation_points, 1);
    derivative_vector = zeros(number_of_evaluation_points, 1);
    stencil_start_vector = zeros(number_of_evaluation_points, 1);

    half_stencil = floor(stencil_size / 2);
    maximum_start_index = number_of_nodes - stencil_size + 1;

    %% Construct and evaluate a local polynomial at each point
    for j = 1:number_of_evaluation_points

        current_point = evaluation_vector(j);

        [~, nearest_node_index] = min( ...
            abs(x_nodes - current_point) ...
        );

        start_index = nearest_node_index - half_stencil;

        start_index = max(start_index, 1);
        start_index = min(start_index, maximum_start_index);

        stencil_indices = ...
            start_index:(start_index + stencil_size - 1);

        local_x_nodes = x_nodes(stencil_indices);
        local_y_nodes = y_nodes(stencil_indices);

        local_coefficients = newton_divided_differences( ...
            local_x_nodes, ...
            local_y_nodes ...
        );

        [local_value, local_derivative] = ...
            evaluate_newton_polynomial( ...
                local_x_nodes, ...
                local_coefficients, ...
                current_point ...
            );

        interpolated_vector(j) = local_value;
        derivative_vector(j) = local_derivative;
        stencil_start_vector(j) = start_index;
    end

    interpolated_values = reshape( ...
        interpolated_vector, ...
        original_size ...
    );

    derivative_values = reshape( ...
        derivative_vector, ...
        original_size ...
    );

    stencil_start_indices = reshape( ...
        stencil_start_vector, ...
        original_size ...
    );
end