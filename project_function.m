function F = project_function(x, n_inner)
%PROJECT_FUNCTION Evaluate the numerical-analysis project function.
%
%   F = PROJECT_FUNCTION(x, n_inner) evaluates
%
%       F(x) = 1 + integral from 0 to sinh(x) of
%              (1 / Gamma(t) - 1) dt
%
%   using the composite Simpson rule with n_inner
%   subintervals for the inner integral.
%
%   Inputs:
%       x       : real value or array in the interval [0, 1]
%       n_inner : positive even number of Simpson subintervals
%
%   Output:
%       F       : numerical values of the project function
%
%   The function preserves the size of the input x.

    %% Validate x
    if ~isnumeric(x) || ~isreal(x)
        error('project_function:InvalidInput', ...
              'Input x must be a real numeric value or array.');
    end

    x = double(x);

    if any(~isfinite(x(:)))
        error('project_function:NonFiniteInput', ...
              'Input x must contain only finite values.');
    end

    if any(x(:) < 0) || any(x(:) > 1)
        error('project_function:OutOfInterval', ...
              'Input x must belong to the closed interval [0, 1].');
    end

    %% Validate n_inner
    if ~isnumeric(n_inner) || ~isscalar(n_inner) || ...
            ~isreal(n_inner) || ~isfinite(n_inner) || ...
            n_inner < 2 || fix(n_inner) ~= n_inner

        error('project_function:InvalidSubintervalCount', ...
              'n_inner must be an integer greater than or equal to 2.');
    end

    if mod(n_inner, 2) ~= 0
        error('project_function:OddSubintervalCount', ...
              'n_inner must be even for the Simpson rule.');
    end

    %% Initialize output
    F = zeros(size(x));

    %% Evaluate F at every input point
    for k = 1:numel(x)

        current_x = x(k);

        % At x = 0, sinh(0) = 0 and the integral is zero.
        if current_x == 0
            F(k) = 1.0;
            continue;
        end

        upper_limit = sinh(current_x);

        inner_integral = composite_simpson( ...
            @gamma_integrand, ...
            0.0, ...
            upper_limit, ...
            n_inner ...
        );

        F(k) = 1.0 + inner_integral;
    end

    %% Validate output
    if any(~isfinite(F(:))) || ~isreal(F)
        error('project_function:InvalidOutput', ...
              'The project function produced invalid numerical values.');
    end
end