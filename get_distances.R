library(tidyverse)
library(sf)
source("get_sets.R")

# Get county centroids
production_centroids <- st_centroid(production %>% st_as_sf())
distribution_centroids <- st_centroid(distribution %>% st_as_sf())
consumption_centroids <- st_centroid(consumption %>% st_as_sf())

#Calculate distances
d_ij <- st_distance(production_centroids, 
                    distribution_centroids) %>% as.matrix.data.frame()

d_jk <- st_distance(distribution_centroids, 
                    consumption_centroids) %>% as.matrix.data.frame()

# The distances do not have row/column names
# Assign names just for reference
prod_names <- as.vector(production_centroids$ID)
distr_names <- as.vector(distribution_centroids$ID)
cons_names <- as.vector(consumption_centroids$ID)

# Name production-distribution matrix
row.names(d_ij) <- prod_names
colnames(d_ij) <- distr_names

# Name distribution-consumption matrix
row.names(d_jk) <- distr_names
colnames(d_jk) <- cons_names

# Write file without names 
# (the optimization algorithm only uses row/column numbers right now)
write.table(d_ij, file="data/d_ij.csv", sep=",", row.names = FALSE, col.names = FALSE)
write.table(d_jk, file="data/d_jk.csv", sep=",", row.names = FALSE, col.names = FALSE)

# Also write file with names for book keeping 
write.csv(d_ij, file="data/distances_ij.csv")
write.csv(d_jk, file="data/distances_jk.csv")

