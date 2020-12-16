import numpy as np
import pandas as pd
import pulp as plp
from pandas import DataFrame, Series
from pandas.io.parsers import TextFileReader

# DATA ----------------------------------------------------
# DISTANCE
d_ij = np.asmatrix(pd.read_csv("data/d_ij.csv", header=None))

d_jk = np.asmatrix(pd.read_csv("data/d_jk.csv", header=None))

# TOTAL PRODUCTION
P_i = np.array(pd.read_csv("data/production.csv", header=None))

# DISTRIBUTOR VALUES
D_j = np.array((pd.read_csv("data/distribution.csv", header=None)))

# CONSUMPTION DEMAND
C_k = np.array(pd.read_csv("data/consumption.csv", header=None))

# SETS
set_I = range(0,len(P_i))
set_J = range(0,len(D_j))
set_K = range(0,len(C_k))

# MODEL -----------------------------------------------------
model = plp.LpProblem(name="Network", sense=plp.LpMinimize)

# COSTS $/kg*km
# The transport cost of production-distribution is cheaper than
# the transport cost of distribution-consumption
t = 2
c = 5

# DECISION VARIABLES

# Flow production-distribution
f_ij = {(i,j): plp.LpVariable(cat=plp.LpContinuous, lowBound=0,
                              name="f_ij_{0}_{1}".format(i,j))
        for i in set_I for j in set_J}

# Flow distribution-consumption
f_jk = {(j,k): plp.LpVariable(cat=plp.LpContinuous, lowBound=0,
                              name="f_jk_{0}_{1}".format(j,k))
        for j in set_J for k in set_K}

# Control variable for distribution
x_j = {(j):
       plp.LpVariable(cat=plp.LpContinuous, lowBound=0,
                      name="x_{0}".format(j))
       for j in set_J}

# # Control variable for consumption
# y_k = {(k):
#        plp.LpVariable(cat=plp.LpContinuous, lowBound=0,
#                       name="y_{0}".format(k))
#        for k in set_K}

print("Done with Variables")

# OBJECTIVE FUNCTION
# (plp.lpSum(P_i[i]*f_ij[(i,j)] for i in set_I for j in set_J)) PRICE
model += t*(plp.lpSum(d_ij[i,j]*f_ij[(i,j)] for i in set_I for j in set_J)) + c*(plp.lpSum(d_jk[j,k]*f_jk[(j,k)] for j in set_J for k in set_K)), "Minimize_transportation_costs"
print("passed objective function")

# CONSTRAINTS

# Constraint 1: Inflow Distribution
for j in set_J:
    model += plp.lpSum(f_ij[(i,j)] for i in set_I) == x_j[j]
print("passed constraint 1")

# Constraint 2: Outflow of distribution center must be equal to inflow
for j in set_J:
    model += plp.lpSum(f_jk[(j,k)] for k in set_K) == x_j[j]
print("passed constraint 2")

# Constraint 3: Capacity of production
for i in set_I:
        model += plp.lpSum(f_ij[(i,j)] for j in set_J) <= P_i[i]
print("passed constraint 3")

# Constraint 4: Demand at distribution facility
for j in set_J:
        model += plp.lpSum(f_ij[(i,j)] for i in set_I) >= 0.8*D_j[j]
print("passed constraint 4")

# Constraint 5: Capacity at distribution facility
for j in set_J:
        model += plp.lpSum(f_ij[(i,j)] for i in set_I) <= D_j[j]
print("passed constraint 5")

# Constrain 6: Consumption Demand
for k in set_K:
    model += plp.lpSum(f_jk[(j,k)] for j in set_J) >= C_k[k]
print("passed constraint 6")

# Constrain 7: Make sure f_jk exists
for k in set_K:
    model += f_jk[(j,k)] <= C_k[k]
print("passed constraint 7")

# # Constraint 8: Control variable for consumption
# for k in set_K:
#     model += plp.lpSum(f_jk[(j,k)] for j in set_J) == y_k[k]
# print("passed constraint 8")

model.writeLP("transportation_model.lp")

# model.solve()
