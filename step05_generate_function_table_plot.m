%% Step 05: Generate the numerical table and plot of F(x)
clear;
clc;
close all;
format long g;

fprintf('====================================================\n');
fprintf('STEP 05 - PROJECT FUNCTION TABLE AND PLOT\n');
fprintf('====================================================\n\n');

%% Project settings
a = 0.0;
b = 1.0;

n_inner = 160;
number_of_plot_points = 101;

fprintf('Project interval      : [%.1f, %.1f]\n', a, b);
fprintf('Inner Simpson count   : %d\n', n_inner);
fprintf('Number of grid points : %d\n\n', number_of_plot_points);

%% Determine the project folders
% This script is expected to be stored inside the "code" folder.

script_full_path = mfilename('fullpath');
code_directory = fileparts(script_full_path);
project_root = fileparts(code_directory);

figures_directory = fullfile(project_root, 'figures');
results_directory = fullfile(project_root, 'results');

if ~exist(figures_directory, 'dir')
    mkdir(figures_directory);
end

if ~exist(results_directory, 'dir')
    mkdir(results_directory);
end

fprintf('Project root:\n%s\n\n', project_root);

%% Generate an equally spaced grid on [0, 1]
x_grid = linspace(a, b, number_of_plot_points).';

grid_spacing = x_grid(2) - x_grid(1);

fprintf('Grid spacing: %.15f\n\n', grid_spacing);

%% Evaluate the project function
F_grid = project_function(x_grid, n_inner);

%% Validate the numerical results
if numel(F_grid) ~= numel(x_grid)
    error('The number of F(x) values does not match the grid size.');
end

if any(~isfinite(F_grid))
    error('The project function produced NaN or Inf values.');
end

if ~isreal(F_grid)
    error('The project function produced complex values.');
end

fprintf('Finite real output test: PASSED\n');

%% Find the minimum value on the numerical grid
[minimum_F, minimum_index] = min(F_grid);

x_at_minimum = x_grid(minimum_index);

fprintf('Grid minimum location : %.15f\n', x_at_minimum);
fprintf('Grid minimum value    : %.15f\n\n', minimum_F);

%% Construct the complete numerical table
function_table = table( ...
    x_grid, ...
    F_grid, ...
    'VariableNames', {'x', 'F_x'} ...
);

%% Display selected values with spacing 0.1
selected_indices = 1:10:number_of_plot_points;

selected_table = function_table(selected_indices, :);

fprintf('Selected numerical values of F(x):\n\n');
disp(selected_table);

%% Save the complete table as a CSV file
table_file_path = fullfile( ...
    results_directory, ...
    'project_function_table_n160.csv' ...
);

writetable(function_table, table_file_path);

fprintf('Numerical table saved to:\n%s\n\n', table_file_path);

%% Plot the numerical project function
figure_handle = figure( ...
    'Name', ...
    'Numerical Project Function' ...
);

plot( ...
    x_grid, ...
    F_grid, ...
    'LineWidth', ...
    1.8 ...
);

hold on;

plot( ...
    x_at_minimum, ...
    minimum_F, ...
    'o', ...
    'MarkerSize', ...
    7, ...
    'LineWidth', ...
    1.5 ...
);

xlabel('$x$', ...
    'Interpreter', 'latex');

ylabel('$F_{160}(x)$', ...
    'Interpreter', 'latex');

title('Numerical Evaluation of the Project Function');

legend( ...
    '$F_{160}(x)$', ...
    'Minimum on the numerical grid', ...
    'Interpreter', 'latex', ...
    'Location', 'best' ...
);

grid on;
box on;

%% Save the figure
figure_file_path = fullfile( ...
    figures_directory, ...
    'project_function_plot_n160.png' ...
);

exportgraphics( ...
    figure_handle, ...
    figure_file_path, ...
    'Resolution', ...
    300 ...
);

fprintf('Figure saved to:\n%s\n\n', figure_file_path);

%% Final validation
if abs(F_grid(1) - 1.0) > 100 * eps
    error('The first grid value is inconsistent with F(0) = 1.');
end

fprintf('Endpoint test F(0) = 1: PASSED\n');
fprintf('Table generation test: PASSED\n');
fprintf('Figure generation test: PASSED\n');

fprintf('\nStep 05 completed successfully.\n');
fprintf('====================================================\n');