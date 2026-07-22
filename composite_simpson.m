function integral_value = composite_simpson(f, a, b, n)
%COMPOSITE_SIMPSON Approximate a definite integral numerically.
%
%   integral_value = composite_simpson(f, a, b, n)
%
%   approximates
%
%       integral from a to b of f(x) dx
%
%   by the composite Simpson rule using n equal subintervals.
%
%   Inputs:
%       f : function handle
%       a : lower integration bound
%       b : upper integration bound
%       n : positive even number of subintervals
%
%   Output:
%       integral_value : Simpson approximation of the integral

    %% Validate the function handle
    if ~isa(f, 'function_handle')
        error('composite_simpson:InvalidFunction', ...
              'Input f must be a MATLAB function handle.');
    end

    %% Validate the interval
    if ~isnumeric(a) || ~isnumeric(b) || ...
            ~isscalar(a) || ~isscalar(b) || ...
            ~isreal(a) || ~isreal(b) || ...
            ~isfinite(a) || ~isfinite(b)

        error('composite_simpson:InvalidInterval', ...
              'The integration bounds must be finite real scalars.');
    end

    if b <= a
        error('composite_simpson:InvalidIntervalOrder', ...
              'The upper bound b must be greater than a.');
    end

    %% Validate the number of subintervals
    if ~isnumeric(n) || ~isscalar(n) || ~isreal(n) || ...
            ~isfinite(n) || n < 2 || fix(n) ~= n

        error('composite_simpson:InvalidSubintervalCount', ...
              'n must be an integer greater than or equal to 2.');
    end

    if mod(n, 2) ~= 0
        error('composite_simpson:OddSubintervalCount', ...
              'The composite Simpson rule requires an even n.');
    end

    %% Construct equally spaced nodes
    h = (b - a) / n;
    x = linspace(a, b, n + 1);

    %% Evaluate the function
    try
        y = f(x);
    catch
        % Use element-by-element evaluation if the function
        % does not support vector inputs.
        y = arrayfun(f, x);
    end

    if ~isnumeric(y) || numel(y) ~= numel(x)
        error('composite_simpson:InvalidFunctionOutput', ...
              'The function must return one numeric value per node.');
    end

    y = reshape(y, size(x));

    if ~isreal(y) || any(~isfinite(y))
        error('composite_simpson:NonFiniteFunctionValue', ...
              'The function produced complex, NaN or Inf values.');
    end

    %% Simpson weighted sums
    % MATLAB index 1 corresponds to mathematical node x_0.
    odd_index_sum = sum(y(2:2:n));
    even_index_sum = sum(y(3:2:n-1));

    integral_value = (h / 3) * ...
        (y(1) + y(end) ...
        + 4 * odd_index_sum ...
        + 2 * even_index_sum);

    %% Validate the final result
    if ~isfinite(integral_value) || ~isreal(integral_value)
        error('composite_simpson:InvalidResult', ...
              'The Simpson approximation is not finite and real.');
    end
end