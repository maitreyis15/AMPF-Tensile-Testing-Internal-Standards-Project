original_length = 15.875;      % gauge length
cross_sectional_area = 3.175*3.175; % cross-sec


opts = detectImportOptions('D:\Glass Fiber\A12 Glass Fiber\A12 Glass Fiber 2.xlsx');
data = readtable('D:\Glass Fiber\A12 Glass Fiber\A12 Glass Fiber 2.xlsx', opts);


data.Properties.VariableNames = {'Index', 'Time', 'Displacement', 'Force_kN', ...
    'TensileStrainPercent', 'EpsilonOneDisplacement'};



elongation = ((data.EpsilonOneDisplacement(end)-data.EpsilonOneDisplacement(3))/25)*100;

displacement = data.EpsilonOneDisplacement - data.EpsilonOneDisplacement(3);      % mm

force_kN = data.Force_kN;              
force = force_kN * 1000;               

strain = displacement ./ original_length;  % unitless
stress = force ./ cross_sectional_area;  % MPa

% --- Young's Modulus (E) - Calculation Method Selection ---
% IMPORTANT: UNCOMMENT ONLY ONE OF THE TWO OPTIONS BELOW AT A TIME!

% --- OPTION 1: Fit to a fixed number of initial data points ---
%num_points_for_fit = 20; % <--- ADJUST THIS VALUE MANUALLY
%linear_range_indices = 1 : min(num_points_for_fit, length(strain));


% --- OPTION 2: Fit to a fixed maximum strain value (often more robust) ---
% COMMENT OUT 'OPTION 1' ABOVE IF YOU UNCOMMENT THIS ONE.
 
 max_strain_for_fit = 0.0015; % <--- UNCOMMENT AND ADJUST THIS VALUE MANUALLY
 linear_range_indices = find(strain >= 0.0005 & strain <= max_strain_for_fit);


% --- Young's Modulus Calculation (Common to both options) ---
valid_indices_for_fit = linear_range_indices(~isnan(strain(linear_range_indices)) & ~isnan(stress(linear_range_indices)));

if isempty(valid_indices_for_fit)
    warning('Warning: No valid data points found for Young''s Modulus calculation after filtering. Check your data and fit range.');
    E = NaN;
    current_strain_segment = [];
    current_stress_segment = [];
else
    current_strain_segment = strain(valid_indices_for_fit);
    current_stress_segment = stress(valid_indices_for_fit);

    if length(current_strain_segment) < 2
        warning('Warning: Not enough data points (%d) to perform linear fit for Young''s Modulus. At least 2 points are required.', length(current_strain_segment));
        E = NaN;
    else
        p = polyfit(current_strain_segment, current_stress_segment, 1);
        E = p(1);
    end
end

% --- Ultimate Tensile Strength (UTS) ---
UTS = max(stress);

% --- Display Results ---
fprintf('Young''s Modulus (E): %.2f MPa\n', E);
fprintf('Ultimate Tensile Strength (UTS): %.2f MPa\n', UTS);

% --- Plot Final Stress-Strain Curve with Young's Modulus Fit ---
figure;
plot(strain, stress, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Stress-Strain Curve');
hold on;

if ~isnan(E) && length(current_strain_segment) >= 2
    plot(current_strain_segment, current_stress_segment, 'ro', 'MarkerSize', 6, ...
        'DisplayName', 'Region Used for Modulus Calculation');

    extrapolated_strain = [0, max(current_strain_segment)];
    extrapolated_stress = E * extrapolated_strain;
    plot(extrapolated_strain, extrapolated_stress, 'g--', 'LineWidth', 1.5, ...
        'DisplayName', 'Young''s Modulus Fit');
end

xlabel('Strain');
ylabel('Stress (MPa)');
title('Stress-Strain Curve with Simplified Young''s Modulus Fit');
grid on;
legend('Location', 'northwest');
hold off;

% --- Basic Force Range Display ---
min_force_kN = min(force_kN);
max_force_kN = max(force_kN);
fprintf('Minimum Force: %.4f kN\n', min_force_kN);
fprintf('Maximum Force: %.4f kN\n', max_force_kN);
fprintf('Elongation: %.4f \n', elongation);

export_table = table(strain, stress, 'VariableNames', {'Strain', 'Stress_MPa'});
writetable(export_table, 'Strain_Stress_Data.csv');