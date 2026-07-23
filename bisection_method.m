function [root, f_root, final_left, final_right, ...
          iteration_count, history_table] = ...
    bisection_method(function_handle, left_endpoint, ...
                     right_endpoint, x_tolerance, ...
                     maximum_iterations)
%BISECTION_METHOD Find a root using the bisection method.
%
% Inputs:
%   function_handle     Function whose root is required
%   left_endpoint       Left endpoint of the initial bracket
%   right_endpoint      Right endpoint of the initial bracket
%   x_tolerance         Required absolute root tolerance
%   maximum_iterations  Maximum allowed number of iterations
%
% Outputs:
%   root                Final midpoint approximation
%   f_root              Function value at the approximation
%   final_left          Left endpoint of the final bracket
%   final_right         Right endpoint of the final bracket
%   iteration_count     Number of performed iterations
%   history_table       Complete iteration history

    %% Validate the function handle
    if ~isa(function_handle, 'function_handle')
        error('The first input must be a valid function handle.');
    end

    %% Validate the initial endpoints
    if ~isscalar(left_endpoint) || ...
            ~isscalar(right_endpoint) || ...
            ~isreal(left_endpoint) || ...
            ~isreal(right_endpoint) || ...
            ~isfinite(left_endpoint) || ...
            ~isfinite(right_endpoint)

        error('The interval endpoints must be finite real scalars.');
    end

    if left_endpoint >= right_endpoint
        error('The left endpoint must be smaller than the right endpoint.');
    end

    %% Validate the tolerance
    if ~isscalar(x_tolerance) || ...
            ~isreal(x_tolerance) || ...
            ~isfinite(x_tolerance) || ...
            x_tolerance <= 0

        error('The x tolerance must be a positive finite scalar.');
    end

    %% Validate the iteration limit
    if ~isscalar(maximum_iterations) || ...
            ~isreal(maximum_iterations) || ...
            ~isfinite(maximum_iterations) || ...
            maximum_iterations <= 0 || ...
            maximum_iterations ~= floor(maximum_iterations)

        error('The maximum iteration count must be a positive integer.');
    end

    %% Evaluate the initial endpoints
    left_value = function_handle(left_endpoint);
    right_value = function_handle(right_endpoint);

    validate_scalar_function_value(left_value, 'left endpoint');
    validate_scalar_function_value(right_value, 'right endpoint');

    %% Handle an exact endpoint root
    if left_value == 0
        root = left_endpoint;
        f_root = left_value;
        final_left = left_endpoint;
        final_right = left_endpoint;
        iteration_count = 0;

        history_table = table( ...
            0, ...
            left_endpoint, ...
            left_endpoint, ...
            left_endpoint, ...
            left_value, ...
            0, ...
            'VariableNames', ...
            {'Iteration', 'Left', 'Right', ...
             'Midpoint', 'FunctionValue', 'HalfWidth'} ...
        );

        return;
    end

    if right_value == 0
        root = right_endpoint;
        f_root = right_value;
        final_left = right_endpoint;
        final_right = right_endpoint;
        iteration_count = 0;

        history_table = table( ...
            0, ...
            right_endpoint, ...
            right_endpoint, ...
            right_endpoint, ...
            right_value, ...
            0, ...
            'VariableNames', ...
            {'Iteration', 'Left', 'Right', ...
             'Midpoint', 'FunctionValue', 'HalfWidth'} ...
        );

        return;
    end

    %% Verify the initial sign-change condition
    if left_value * right_value > 0
        error(['The initial interval is invalid because the ', ...
               'function does not change sign.']);
    end

    %% Preallocate iteration history
    iteration_values = zeros(maximum_iterations, 1);
    left_values = zeros(maximum_iterations, 1);
    right_values = zeros(maximum_iterations, 1);
    midpoint_values = zeros(maximum_iterations, 1);
    function_values = zeros(maximum_iterations, 1);
    half_width_values = zeros(maximum_iterations, 1);

    %% Bisection iterations
    for iteration = 1:maximum_iterations

        midpoint = ...
            (left_endpoint + right_endpoint) / 2;

        midpoint_function_value = ...
            function_handle(midpoint);

        validate_scalar_function_value( ...
            midpoint_function_value, ...
            'midpoint' ...
        );

        half_width = ...
            (right_endpoint - left_endpoint) / 2;

        iteration_values(iteration) = iteration;
        left_values(iteration) = left_endpoint;
        right_values(iteration) = right_endpoint;
        midpoint_values(iteration) = midpoint;
        function_values(iteration) = midpoint_function_value;
        half_width_values(iteration) = half_width;

        %% Stopping condition
        if midpoint_function_value == 0 || ...
                half_width <= x_tolerance

            root = midpoint;
            f_root = midpoint_function_value;
            final_left = left_endpoint;
            final_right = right_endpoint;
            iteration_count = iteration;

            history_table = table( ...
                iteration_values(1:iteration), ...
                left_values(1:iteration), ...
                right_values(1:iteration), ...
                midpoint_values(1:iteration), ...
                function_values(1:iteration), ...
                half_width_values(1:iteration), ...
                'VariableNames', ...
                {'Iteration', 'Left', 'Right', ...
                 'Midpoint', 'FunctionValue', 'HalfWidth'} ...
            );

            return;
        end

        %% Preserve the sign-change bracket
        if left_value * midpoint_function_value < 0

            right_endpoint = midpoint;
            right_value = midpoint_function_value;

        else

            left_endpoint = midpoint;
            left_value = midpoint_function_value;

        end
    end

    error(['The bisection method did not converge within ', ...
           'the specified maximum number of iterations.']);
end


function validate_scalar_function_value(value, location_name)
%VALIDATE_SCALAR_FUNCTION_VALUE Validate a scalar function evaluation.

    if ~isscalar(value) || ...
            ~isreal(value) || ...
            ~isfinite(value)

        error( ...
            'Invalid function value at the %s.', ...
            location_name ...
        );
    end
end