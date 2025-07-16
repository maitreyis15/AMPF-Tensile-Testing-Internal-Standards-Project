import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# --- User Inputs ---
original_length = float(input("Enter gauge length (in mm): "))
cross_sectional_area = float(input("Enter cross-sectional area (in mm): "))
file_path = input("Enter full path to Excel file: ")



# --- Load Excel Data ---
data = pd.read_excel(file_path)

# Rename columns to match expected format
data = pd.read_excel(file_path)

# Rename columns to expected format
data.columns = ['Index', 'Time', 'Displacement', 'Force_kN', 'TensileStrainPercent', 'EpsilonOneDisplacement']

# Convert important columns to numeric
data['EpsilonOneDisplacement'] = pd.to_numeric(data['EpsilonOneDisplacement'], errors='coerce')
data['Force_kN'] = pd.to_numeric(data['Force_kN'], errors='coerce')


# --- Elongation Calculation ---
elongation = ((data['EpsilonOneDisplacement'].iloc[-1] - data['EpsilonOneDisplacement'].iloc[2]) / original_length) * 100

# --- Preprocess ---
displacement = data['EpsilonOneDisplacement'] - data['EpsilonOneDisplacement'].iloc[2]
force = data['Force_kN'] * 1000  # convert kN to N
strain = displacement / original_length
stress = force / cross_sectional_area  # MPa

# --- Young's Modulus (Fit to strain range) ---
min_strain = 0.0005
max_strain = 0.0015

mask = (strain >= min_strain) & (strain <= max_strain) & (~strain.isna()) & (~stress.isna())
strain_fit = strain[mask]
stress_fit = stress[mask]

if len(strain_fit) < 2:
    print("Warning: Not enough data points to perform linear fit.")
    E = np.nan
else:
    coeffs = np.polyfit(strain_fit, stress_fit, 1)
    E = coeffs[0]

# --- Ultimate Tensile Strength (UTS) ---
UTS = stress.max()

# --- Output ---
print(f"\nYoung's Modulus (E): {E:.2f} MPa")
print(f"Ultimate Tensile Strength (UTS): {UTS:.2f} MPa")
print(f"Minimum Force: {data['Force_kN'].min():.4f} kN")
print(f"Maximum Force: {data['Force_kN'].max():.4f} kN")
print(f"Elongation: {elongation:.4f}%")

# --- Plot ---
plt.figure(figsize=(10,6))
plt.plot(strain, stress, 'b-', label='Stress-Strain Curve')

if not np.isnan(E):
    plt.plot(strain_fit, stress_fit, 'ro', label='Fit Region')
    extrapolated_strain = np.array([0, strain_fit.max()])
    extrapolated_stress = E * extrapolated_strain
    plt.plot(extrapolated_strain, extrapolated_stress, 'g--', label="Young's Modulus Fit")

plt.xlabel('Strain')
plt.ylabel('Stress (MPa)')
plt.title('Stress-Strain Curve with Young\'s Modulus Fit')
plt.grid(True)
plt.legend(loc='upper left')
plt.tight_layout()
plt.show()

# --- Export to CSV ---
export_table = pd.DataFrame({'Strain': strain, 'Stress_MPa': stress})
export_table.to_csv('Strain_Stress_Data.csv', index=False)
