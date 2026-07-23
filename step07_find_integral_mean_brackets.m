%% Step 07: Locate sign-change brackets for the integral mean root
clear;
clc;
format long g;

fprintf('====================================================\n');
fprintf('STEP 07 - INTEGRAL MEAN ROOT BRACKETS\n');
fprintf('====================================================\n\n');

%% Project settings
a = 0.0;
b = 1.0;

n_inner = 160;
number_of_scan_points = 1001;

fprintf('Project interval      : [%.1f, %.1f]\n', a, b);
fprintf('Inner Simpson count   : %d\n', n_inner);
fprintf('Number of scan points : %d\n\n', number_of_scan_points);

%% Determine project folders
script_full_path = mfilename('fullpath');

if isempty(script_full_path)
    error(['The script must be saved before execution so that ', ...
           'the project path can be determined.']);
end

code_directory = fileparts(script_full_path);
project_root = fileparts(code_directory);

results_directory = fullfile(project_root, 'results');
figures_directory = fullfile(project_root, 'figures');

if ~exist(results_directory, 'dir')
    mkdir(results_directory);
end

if ~exist(figures_directory, 'dir')
    mkdir(figures_directory);
end

fprintf('Project root:\n%s\n\n', project_root);

%% Read the integral mean computed in Step 06
summary_file_path = fullfile( ...
    results_directory, ...
    'integral_mean_summary.csv' ...
);

if ~isfile(summary_file_path)
    error(['The Step 06 summary file was not found:\n', ...
           summary_file_path]);
end

summary_table = readtable(summary_file_path);

required_variable = 'IntegralMean';

if ~ismember(required_variable, summary_table.Properties.VariableNames)
    error('The summary file does not contain the IntegralMean column.');
end

integral_mean_value = summary_table.IntegralMean(1);

if ~isscalar(integral_mean_value) || ...
        ~isreal(integral_mean_value) || ...
        ~isfinite(integral_mean_value)

    error('The integral mean value is invalid.');
end

fprintf('Integral mean value:\n');
fprintf('M_I = %.15f\n\n', integral_mean_value);

%% Define the integral mean equation
integral_mean_equation = @(x) ...
    project_function(x, n_inner) - integral_mean_value;

%% Scan the project interval
x_scan = linspace(a, b, number_of_scan_points).';

scan_spacing = x_scan(2) - x_scan(1);

F_scan = project_function(x_scan, n_inner);
G_scan = F_scan - integral_mean_value;

if any(~isfinite(F_scan)) || any(~isreal(F_scan))
    error('Non-finite or complex values were produced for F(x).');
end

if any(~isfinite(G_scan)) || any(~isreal(G_scan))
    error('Non-finite or complex values were produced for G_I(x).');
end

fprintf('Scan spacing: %.15f\n', scan_spacing);
fprintf('Finite real scan test: PASSED\n\n');

%% Locate sign changes
sign_change_indices = find( ...
    G_scan(1:end-1) .* G_scan(2:end) < 0 ...
);

number_of_brackets = numel(sign_change_indices);

if number_of_brackets == 0
    error(['No sign-change bracket was detected. ', ...
           'A finer scan grid may be required.']);
end

bracket_number = (1:number_of_brackets).';

x_left = x_scan(sign_change_indices);
x_right = x_scan(sign_change_indices + 1);

G_left = G_scan(sign_change_indices);
G_right = G_scan(sign_change_indices + 1);

bracket_width = x_right - x_left;

bracket_table = table( ...
    bracket_number, ...
    x_left, ...
    x_right, ...
    G_left, ...
    G_right, ...
    bracket_width, ...
    'VariableNames', ...
    { ...
        'BracketNumber', ...
        'x_left', ...
        'x_right', ...
        'G_left', ...
        'G_right', ...
        'BracketWidth' ...
    } ...
);

fprintf('Number of sign-change brackets: %d\n\n', ...
    number_of_brackets);

fprintf('Detected brackets:\n\n');
disp(bracket_table);

%% Validate all brackets
bracket_products = G_left .* G_right;

if any(bracket_products >= 0)
    error('At least one detected interval is not a valid bracket.');
end

fprintf('Sign-change validation test: PASSED\n');

%% Save the complete scan table
scan_table = table( ...
    x_scan, ...
    F_scan, ...
    G_scan, ...
    'VariableNames', ...
    {'x', 'F_x', 'G_I_x'} ...
);

scan_file_path = fullfile( ...
    results_directory, ...
    'integral_mean_root_scan.csv' ...
);

writetable(scan_table, scan_file_path);

%% Save the bracket table
bracket_file_path = fullfile( ...
    results_directory, ...
    'integral_mean_root_brackets.csv' ...
);

writetable(bracket_table, bracket_file_path);

%% Plot the integral mean equation
figure_handle = figure('Color', 'w');

plot(x_scan, G_scan, 'LineWidth', 1.5);
hold on;

yline(0, '--', 'LineWidth', 1.0);

plot(x_left, G_left, 'o', ...
    'MarkerSize', 7, ...
    'LineWidth', 1.2);

plot(x_right, G_right, 'o', ...
    'MarkerSize', 7, ...
    'LineWidth', 1.2);

grid on;

xlabel('x');
ylabel('G_I(x) = F(x) - M_I');
title('Integral Mean Equation and Sign-Change Bracket');

axes_handle = gca;
axes_handle.Toolbar.Visible = 'off';

figure_file_path = fullfile( ...
    figures_directory, ...
    'integral_mean_bracket_scan.png' ...
);

exportgraphics( ...
    figure_handle, ...
    figure_file_path, ...
    'Resolution', ...
    300 ...
);

%% Display saved paths
fprintf('\nComplete scan table saved to:\n%s\n', ...
    scan_file_path);

fprintf('\nBracket table saved to:\n%s\n', ...
    bracket_file_path);

fprintf('\nFigure saved to:\n%s\n', ...
    figure_file_path);

%% Final message
fprintf('\nStep 07 completed successfully.\n');
fprintf('====================================================\n');