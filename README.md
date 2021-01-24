# Linear Optimization: Transportation Problem

## A transportation problem solved with PuLP and Gurobi (python) with visualization in R.

The classic transportation problem is solved with randomly generated data in R. The first script to run is get_sets.R, where we will assign counties to the production, distribution and consumption stages of the problem. The consumption counties were the most populated areas whereas production and distribution were random. 

It was assumed that production and distribution capacities follow a normal distribution while demands follow a log-normal distribution with most counties having low-average values.

Once demands and capacities were assigned, the script get_distances.R is ran to generate a matrix with the straight distances between all counties.

Then, the python codes can be executed, first the model_transportation.py that will write a .lp file that will be solved by gurobi in model_solver.py

For the results processing, we go back to R. The get_opt_results.R script reads the csv file generated by the python script and separates the variables. The networks between production and distribution and distribution and consumption are cleaned in the respective scripts network_ij.R and network_jk.R

The script network_viz.R creates a visualization for the network on the map.
