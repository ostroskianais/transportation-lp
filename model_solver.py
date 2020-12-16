from gurobipy import *
import csv

model = read("transportation_model.lp")

model.optimize()

var = model.getVars()
# model.printAttr('X')

var_names = []
var_values = []

varInfo = [(v.varName, v.X) for v in model.getVars()]

# Write to csv
with open('opt_results/variables.csv', 'w') as myfile:
     wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
     wr.writerows(varInfo)