%% Step 08: Validate the bisection method
clear;
clc;
format long g;

fprintf('====================================================\n');
fprintf('STEP 08 - BISECTION METHOD VALIDATION\n');
fprintf('====================================================\n\n');

%% Test problem from numerical analysis
test_function = @(x) x.^3 + 4 .* x.^2 - 10;

left_endpoint = 1.0;
right_endpoint = 2.0;

x_tolerance = 0.5e-6;
maximum_iterations = 100;

reference_root = 1.365230013414097;

fprintf('Test equation:\n');
fprintf('f(x) = x^3 + 4*x^2 - 10\n\n');

fprintf('Initial bracket      : [%.1f, %.1f]\n', ...
    left_endpoint, right_endpoint);

fprintf('Root tolerance       : %.10e\n', ...
    x_tolerance);

fprintf('Maximum iterations   : %d\n\n', ...
    maximum_iterations);

%% Run the bisection method
[root, f_root, final_left, final_right, ...
 iteration_count, history_table] = ...
    bisection_method( ...
        test_function, ...
        left_endpoint, ...
        right_endpoint, ...
        x_tolerance, ...
        maximum_iterations ...
    );

%% Compute validation quantities
root_absolute_error = abs(root - reference_root);

final_half_width = ...
    (final_right - final_left) / 2;

final_sign_product = ...
    test_function(final_left) ...
    * test_function(final_right);

%% Display the final results
fprintf('Final numerical results:\n\n');

fprintf('Computed root        = %.15f\n', root);
fprintf('Reference root       = %.15f\n', reference_root);
fprintf('Absolute root error  = %.15e\n', root_absolute_error);
fprintf('Function value       = %.15e\n', f_root);
fprintf('Iteration count      = %d\n\n', iteration_count);

fprintf('Final bracket:\n');
fprintf('[%.15f, %.15f]\n\n', ...
    final_left, final_right);

fprintf('Final half-width     = %.15e\n', ...
    final_half_width);

fprintf('Final sign product   = %.15e\n\n', ...
    final_sign_product);

%% Display the last iterations
number_of_rows_to_display = min(8, height(history_table));

fprintf('Last %d bisection iterations:\n\n', ...
    number_of_rows_to_display);

disp(history_table( ...
    end - number_of_rows_to_display + 1:end, : ...
));

%% Accuracy validation
if root_absolute_error > x_tolerance
    error('The computed root does not satisfy the required tolerance.');
end

fprintf('Reference-root accuracy test: PASSED\n');

if final_half_width > x_tolerance
    error('The final interval does not satisfy the width tolerance.');
end

fprintf('Final-bracket width test: PASSED\n');

if final_sign_product > 0
    error('The final interval does not preserve the sign change.');
end

fprintf('Sign-change preservation test: PASSED\n');

%% Endpoint-root validation
endpoint_test_function = @(x) x - 1;

[endpoint_root, endpoint_value] = ...
    bisection_method( ...
        endpoint_test_function, ...
        1, ...
        2, ...
        x_tolerance, ...
        maximum_iterations ...
    );

if endpoint_root ~= 1 || endpoint_value ~= 0
    error('The endpoint-root test failed.');
end

fprintf('Endpoint-root test: PASSED\n');

%% Invalid-bracket validation
invalid_bracket_rejected = false;

try
    bisection_method( ...
        test_function, ...
        2, ...
        3, ...
        x_tolerance, ...
        maximum_iterations ...
    );

catch
    invalid_bracket_rejected = true;
end

if ~invalid_bracket_rejected
    error('The invalid-bracket test failed.');
end

fprintf('Invalid-bracket rejection test: PASSED\n');

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

%% Save the iteration history
history_file_path = fullfile( ...
    results_directory, ...
    'bisection_validation_history.csv' ...
);

writetable(history_table, history_file_path);

fprintf('\nIteration history saved to:\n%s\n', ...
    history_file_path);

%% Final message
fprintf('\nStep 08 completed successfully.\n');
fprintf('====================================================\n');