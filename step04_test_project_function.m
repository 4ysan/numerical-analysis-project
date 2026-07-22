%% Step 04: Numerical construction and validation of F(x)
clear;
clc;
format long g;

fprintf('====================================================\n');
fprintf('STEP 04 - PROJECT FUNCTION VALIDATION\n');
fprintf('====================================================\n\n');

%% Project settings
a = 0.0;
b = 1.0;

decimal_digits = 6;

% Required tolerance for six correct decimal places
tolerance = 0.5 * 10^(-decimal_digits);

fprintf('Project interval    : [%.1f, %.1f]\n', a, b);
fprintf('Required precision  : %d decimal places\n', decimal_digits);
fprintf('Target tolerance    : %.10e\n\n', tolerance);

%% Test points in the closed interval [0, 1]
test_x = [
    0.00
    0.25
    0.50
    0.75
    1.00
];

%% Numbers of subintervals for the inner Simpson integration
subinterval_counts = [20, 40, 80, 160];

number_of_points = numel(test_x);
number_of_grids = numel(subinterval_counts);

% Each column contains F(x) values for one Simpson grid
F_values = zeros(number_of_points, number_of_grids);

%% Evaluate F(x) using progressively finer Simpson grids
for j = 1:number_of_grids

    current_n = subinterval_counts(j);

    F_values(:, j) = project_function(test_x, current_n);
end

%% Estimate the error of the finest Simpson result
% The composite Simpson rule has order four.
%
% If S_n and S_2n are two consecutive approximations, then:
%
%   error(S_2n) approximately equals |S_2n - S_n| / (2^4 - 1)
%
% Therefore, the denominator is 15.

estimated_error_n160 = abs( ...
    F_values(:, 4) - F_values(:, 3) ...
) / 15;

%% Construct and display the convergence table
results_table = table( ...
    test_x, ...
    F_values(:, 1), ...
    F_values(:, 2), ...
    F_values(:, 3), ...
    F_values(:, 4), ...
    estimated_error_n160, ...
    'VariableNames', ...
    { ...
        'x', ...
        'F_n20', ...
        'F_n40', ...
        'F_n80', ...
        'F_n160', ...
        'EstimatedError_n160' ...
    } ...
);

fprintf('Project-function convergence table:\n\n');
disp(results_table);

%% Test 1: Endpoint value
% Since sinh(0) = 0, the integral has zero length and F(0) = 1.

if F_values(1, 4) ~= 1.0
    error('The endpoint value F(0) was not evaluated as 1.');
end

fprintf('Endpoint test F(0) = 1: PASSED\n');

%% Test 2: All computed values must be finite
if any(~isfinite(F_values(:)))
    error('NaN or Inf was detected in the F(x) values.');
end

fprintf('Finite-output test: PASSED\n');

%% Test 3: Verify the required six-decimal accuracy
if any(estimated_error_n160 > tolerance)
    error(['The estimated Simpson error exceeds the target ', ...
           'tolerance for at least one test point.']);
end

fprintf('Six-decimal accuracy test: PASSED\n');

%% Test 4: Scalar and vector evaluations must agree
scalar_value = project_function(0.5, 160);
vector_value = F_values(3, 4);

scalar_vector_difference = abs(scalar_value - vector_value);

fprintf('Scalar/vector consistency difference: %.15e\n', ...
    scalar_vector_difference);

if scalar_vector_difference > 100 * eps
    error('Scalar and vector evaluations are inconsistent.');
end

fprintf('Scalar/vector consistency test: PASSED\n');

%% Test 5: An odd number of Simpson subintervals must be rejected
odd_n_rejected = false;

try
    project_function(0.5, 15);

catch error_information

    odd_n_rejected = strcmp( ...
        error_information.identifier, ...
        'project_function:OddSubintervalCount' ...
    );
end

if ~odd_n_rejected
    error('Odd-subinterval validation did not work correctly.');
end

fprintf('Odd-subinterval validation test: PASSED\n');

%% Display final values based on the finest grid
fprintf('\nFinal values based on n_inner = 160:\n\n');

for k = 1:number_of_points

    fprintf('F(%.2f) = %.15f\n', ...
        test_x(k), F_values(k, 4));
end

%% Display estimated errors separately
fprintf('\nEstimated Simpson errors for n_inner = 160:\n\n');

for k = 1:number_of_points

    fprintf('Estimated error at x = %.2f : %.15e\n', ...
        test_x(k), estimated_error_n160(k));
end

%% Final message
fprintf('\nAll project-function tests passed successfully.\n');
fprintf('====================================================\n');