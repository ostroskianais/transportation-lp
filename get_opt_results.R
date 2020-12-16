library(tidyverse)
library(sf)

# The results are in the "variables.csv" file
# In the form of f_ij_X_Y where X and Y are the county IDs (based on row number) of origin and destination, respectively
# f_ij is the flow from production to distribution
# f_jk is the flow from distribution to consumption
# x is the control variable to see the distribution values

# Read variables and separate the first column to extract ij or jk
variables <- read.csv("opt_results/variables.csv", header = F) %>% 
  mutate(Var = sapply(strsplit(as.character(V1),"_"), "[", 2)) %>% 
  mutate(letter_var = sapply(strsplit(as.character(V1),"_"), "[",1))

fij_var <- variables %>% 
  filter(Var == "ij") 

fjk_var <- variables %>% 
  filter(Var == "jk")

xj_var <- variables %>% 
  filter(letter_var == "x") %>% 
  select(V1, V2)

# Write files

fij_var %>% write.csv("opt_results/f_ij.csv", row.names = F)
fjk_var %>% write.csv("opt_results/f_jk.csv", row.names = F)
xj_var %>% write.csv("opt_results/x_j.csv", row.names = F)

