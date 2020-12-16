library(tidyverse)
library(sf)


# In the form of f_ij_X_Y where X and Y are the county IDs (based on row number) of origin and destination, respectively
# Read results and remove f_ij
f_ij <- read.csv("opt_results/f_ij.csv") %>% 
  rename(id = V1, flow = V2) %>% 
  filter(flow > 0)

f_ij$id <- str_remove(f_ij$id, "f_ij_")

# Separate from and to columns based on the id column, where
# x_y means county x to slaughterhouse y

f_ij <- f_ij %>% 
  mutate(orig_id = sapply(strsplit(as.character(id),"_"), "[", 1)) %>% 
  mutate(dest_id = sapply(strsplit(as.character(id),"_"), "[", 2))

# Import the county codes
prod_id <- read.csv("data/production_ID.csv") %>% rename(orig_id = X)
distr_id <- read.csv("data/distribution_ID.csv") %>% rename(dest_id = X)

# Merge with the county ID to get their names
f_ij <- f_ij %>% merge(prod_id, by ="orig_id") %>% rename(orig = ID)
f_ij <- f_ij %>% merge(distr_id, by ="dest_id") %>% rename(dest = ID)

# Create ORIGIN-DESTINATION df
f_ij_od <- f_ij %>% 
  select(orig, dest, flow)

write.csv(f_ij_od, "results/flow_ij.csv")
