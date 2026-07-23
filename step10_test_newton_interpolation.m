%% Step 10: Validate Newton interpolation and differentiation
clear;
clc;
format long g;

fprintf('====================================================\n');
fprintf('STEP 10 - NEWTON INTERPOLATION VALIDATION\n');
fprintf('====================================================\n\n');

%% Validation polynomial
test_function = @(x) x.^3 - 2 .* x + 1;
test_derivative = @(x) 3 .* x.^2 - 2;

x_nodes = [-1; 0; 1; 2];
y_nodes = test_function(x_nodes);

expected_coefficients = [2; -1; 0; 1];

error_tolerance = 1e-12;

fprintf('Validation polynomial:\n');
fprintf('p(x) = x^3 - 2*x + 1\n\n');

fprintf('Interpolation nodes:\n');
disp(x_nodes.');

fprintf('Function values at nodes:\n');
disp(y_nodes.');

%% Compute Newton coefficients
computed_coefficients = ...
    newton_divided_differences(x_nodes, y_nodes);

coefficient_error = max(abs( ...
    computed_coefficients - expected_coefficients ...
));

fprintf('Computed Newton coefficients:\n');
disp(computed_coefficients.');

fprintf('Expected Newton coefficients:\n');
disp(expected_coefficients.');

fprintf('Maximum coefficient error = %.15e\n\n', ...
    coefficient_error);

%% Evaluate the interpolating polynomial and derivative
evaluation_points = linspace(-1, 2, 13);

[interpolated_values, derivative_values] = ...
    evaluate_newton_polynomial( ...
        x_nodes, ...
        computed_coefficients, ...
        evaluation_points ...
    );

exact_values = test_function(evaluation_points);
exact_derivative_values = test_derivative(evaluation_points);

interpolation_errors = abs( ...
    interpolated_values - exact_values ...
);

derivative_errors = abs( ...
    derivative_values - exact_derivative_values ...
);

maximum_interpolation_error = max(interpolation_errors);
maximum_derivative_error = max(derivative_errors);

fprintf('Maximum interpolation error = %.15e\n', ...
    maximum_interpolation_error);

fprintf('Maximum derivative error    = %.15e\n\n', ...
    maximum_derivative_error);

%% Construct the validation table
validation_table = table( ...
    evaluation_points.', ...
    exact_values.', ...
    interpolated_values.', ...
    interpolation_errors.', ...
    exact_derivative_values.', ...
    derivative_values.', ...
    derivative_errors.', ...
    'VariableNames', ...
    { ...
        'x', ...
        'ExactValue', ...
        'InterpolatedValue', ...
        'InterpolationError', ...
        'ExactDerivative', ...
        'InterpolatedDerivative', ...
        'DerivativeError' ...
    } ...
);

fprintf('Interpolation and derivative validation table:\n\n');
disp(validation_table);

%% Accuracy tests
if coefficient_error > error_tolerance
    error('The Newton coefficient test failed.');
end

fprintf('Newton coefficient test: PASSED\n');

if maximum_interpolation_error > error_tolerance
    error('The interpolation accuracy test failed.');
end

fprintf('Polynomial interpolation test: PASSED\n');

if maximum_derivative_error > error_tolerance
    error('The interpolation derivative test failed.');
end

fprintf('Polynomial derivative test: PASSED\n');

%% Output-shape validation
row_test_points = [-0.75, 0.25, 1.75];

[row_polynomial_values, row_derivative_values] = ...
    evaluate_newton_polynomial( ...
        x_nodes, ...
        computed_coefficients, ...
        row_test_points ...
    );

if ~isequal(size(row_polynomial_values), size(row_test_points)) || ...
        ~isequal(size(row_derivative_values), size(row_test_points))

    error('The output-shape preservation test failed.');
end

fprintf('Output-shape preservation test: PASSED\n');

%% Repeated-node rejection test
repeated_nodes_rejected = false;

try
    newton_divided_differences( ...
        [0; 1; 1], ...
        [1; 2; 3] ...
    );

catch
    repeated_nodes_rejected = true;
end

if ~repeated_nodes_rejected
    error('The repeated-node rejection test failed.');
end

fprintf('Repeated-node rejection test: PASSED\n');

%% Mismatched-length rejection test
mismatched_lengths_rejected = false;

try
    newton_divided_differences( ...
        [0; 1; 2], ...
        [1; 2] ...
    );

catch
    mismatched_lengths_rejected = true;
end

if ~mismatched_lengths_rejected
    error('The mismatched-length rejection test failed.');
end

fprintf('Mismatched-length rejection test: PASSED\n');

%% Determine project folders
script_full_path = mfilename('fullpath');

if isempty(script_full_path)
    error(['The script must be saved before execution so that ', ...
           'the project path can be determined.']);
end

code_directory = fileparts(script_full_path);
project_root = fileparts(code_directory);

results_directory = fullfile(project_root, 'results');

if ~exist(results_directory, 'dir')
    mkdir(results_directory);
end

%% Save the validation table
validation_file_path = fullfile( ...
    results_directory, ...
    'newton_interpolation_validation.csv' ...
);

writetable(validation_table, validation_file_path);

fprintf('\nValidation table saved to:\n%s\n', ...
    validation_file_path);

%% Final message
fprintf('\nStep 10 completed successfully.\n');
fprintf('====================================================\n');