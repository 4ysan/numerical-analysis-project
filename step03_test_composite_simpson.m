%% Step 03: Validation of the composite Simpson rule
clear;
clc;
format long g;

fprintf('====================================================\n');
fprintf('STEP 03 - COMPOSITE SIMPSON RULE VALIDATION\n');
fprintf('====================================================\n\n');

%% Test 1: Cubic polynomial
% Simpson's rule must be exact for cubic polynomials.

cubic_function = @(x) x.^3;

a1 = 0.0;
b1 = 1.0;
n1 = 2;

exact_cubic_integral = 1 / 4;

simpson_cubic_integral = composite_simpson( ...
    cubic_function, a1, b1, n1);

cubic_absolute_error = abs( ...
    exact_cubic_integral - simpson_cubic_integral);

fprintf('Test 1: Integral of x^3 on [0, 1]\n');
fprintf('Exact value       : %.15f\n', exact_cubic_integral);
fprintf('Simpson value     : %.15f\n', simpson_cubic_integral);
fprintf('Absolute error    : %.15e\n\n', cubic_absolute_error);

if cubic_absolute_error > 100 * eps
    error('The Simpson rule failed the cubic-polynomial test.');
end

fprintf('Cubic-polynomial exactness test: PASSED\n\n');

%% Test 2: Integral of sin(x) on [0, pi]
sine_function = @(x) sin(x);

a2 = 0.0;
b2 = pi;

exact_sine_integral = 2.0;

subinterval_counts = [4; 8; 16; 32; 64];

simpson_values = zeros(size(subinterval_counts));
absolute_errors = zeros(size(subinterval_counts));

for k = 1:numel(subinterval_counts)
    current_n = subinterval_counts(k);

    simpson_values(k) = composite_simpson( ...
        sine_function, a2, b2, current_n);

    absolute_errors(k) = abs( ...
        exact_sine_integral - simpson_values(k));
end

convergence_table = table( ...
    subinterval_counts, ...
    simpson_values, ...
    absolute_errors, ...
    'VariableNames', ...
    {'n', 'SimpsonApproximation', 'AbsoluteError'} ...
);

fprintf('Test 2: Integral of sin(x) on [0, pi]\n\n');
disp(convergence_table);

%% Verify that the error decreases as n increases
if any(diff(absolute_errors) >= 0)
    error('The Simpson errors did not decrease consistently.');
end

fprintf('Error-reduction test: PASSED\n');

%% Test 3: Odd n must be rejected
odd_n_rejected = false;

try
    composite_simpson(sine_function, 0, pi, 5);
catch error_information
    odd_n_rejected = strcmp( ...
        error_information.identifier, ...
        'composite_simpson:OddSubintervalCount');
end

if ~odd_n_rejected
    error('The odd-subinterval validation did not work.');
end

fprintf('Odd-subinterval validation test: PASSED\n');

%% Final result
fprintf('\nAll composite-Simpson tests passed successfully.\n');
fprintf('====================================================\n');