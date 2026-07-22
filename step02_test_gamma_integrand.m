%% Step 02: Numerical validation of the Gamma-based integrand
clear;
clc;
format long g;

fprintf('====================================================\n');
fprintf('STEP 02 - GAMMA INTEGRAND VALIDATION\n');
fprintf('====================================================\n\n');

%% Domain required by the project
a = 0.0;
b = 1.0;

maximum_t = sinh(b);

fprintf('x interval       : [%.1f, %.1f]\n', a, b);
fprintf('Required t range : [0, sinh(1)]\n');
fprintf('sinh(1)          : %.15f\n\n', maximum_t);

%% Test points
% Points near zero are included to examine continuity.
test_t = [
    0
    1e-12
    1e-10
    1e-8
    1e-6
    1e-4
    1e-2
    1e-1
    0.5
    1.0
    maximum_t
];

%% Evaluate the integrand
q_values = gamma_integrand(test_t);

%% Distance from the limiting value -1
distance_from_zero_limit = abs(q_values + 1);

%% Create output table
results_table = table( ...
    test_t, ...
    q_values, ...
    distance_from_zero_limit, ...
    'VariableNames', ...
    {'t', 'q_t', 'AbsoluteDistanceFromMinusOne'} ...
);

fprintf('Numerical values of the integrand:\n\n');
disp(results_table);

%% Test 1: exact continuous value at zero
if q_values(1) ~= -1
    error('The continuous value q(0) was not evaluated as -1.');
end

fprintf('Test q(0) = -1: PASSED\n');

%% Test 2: all outputs must be finite
if any(~isfinite(q_values))
    error('NaN or Inf was detected in the integrand values.');
end

fprintf('Finite-output test: PASSED\n');

%% Test 3: shape preservation
matrix_input = [
    0.0, 0.1
    0.5, 1.0
];

matrix_output = gamma_integrand(matrix_input);

if ~isequal(size(matrix_input), size(matrix_output))
    error('The function did not preserve the input dimensions.');
end

fprintf('Array-shape preservation test: PASSED\n');

%% Test 4: invalid negative input must be rejected
negative_input_rejected = false;

try
    gamma_integrand(-0.1);
catch error_information
    negative_input_rejected = ...
        strcmp(error_information.identifier, ...
               'gamma_integrand:NegativeInput');
end

if ~negative_input_rejected
    error('Negative-input validation did not work correctly.');
end

fprintf('Negative-input validation test: PASSED\n');

%% Final message
fprintf('\nAll Gamma-integrand tests passed successfully.\n');
fprintf('====================================================\n');