# AMPF Tensile Testing Internal Standards Project

## The Project
This project's purpose is to conduct tensile tests of specific geometries. These varying geometries are meant to create an internal standard for the AMPF because current industrial-grade specimen geometries are too large to be applied to every project at the AMPF.

The tensile tests are conducted using the 5982 Instron Frame, which allows uniaxial tensile tests on the various samples. The tests encompass multiple materials, such as PLA, glass fiber, and tool steel. This repository will provide a basic run-through of the procedure. A handful of specimens from each batch of samples contain gauge markers that are meant to be read using the extensometer connected to the Instron frame. This allows for the raw displacement vs. force data provided in the files in this repository. 

## Breakdown of Files
Each folder should have a process similar to the one laid out below. (This does not include the code)
1. Folders are first separated by **material**
2. Next, the folders will be separated by **specimen geometry**
3. There will be one csv file that contains all the raw data from each test and/or corresponding results from the test (if there is an 'X' next to a specimen in the results table, that indicates that the data for that test should be considered invalid)
4. The other Excel files contain the data that will be used for the main MATLAB code that analyzes your data (this was done manually due to the fact that it makes it easier for MATLAB to read the file)

## MATLAB Code Simple Documentation
1. Add your specimen measurements in the first few lines of code, inputting the gauge length and computing the cross-sectional area
2. Change lines 5 and 6 to the specific file path that you are trying to analyze

From each execution of this code, you should get Young's modulus, ultimate tensile strength, min/max force, elongation, and a graph of the stress vs. strain of the data
