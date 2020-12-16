library(tidyverse)
library(sf)


# In the form of f_jk_X_Y where X and Y are the county IDs (based on row number) of origin and destination, respectively
# Read results and remove f_jk
f_jk <- read.csv("opt_results/f_jk.csv") %>% 
  rename(id = V1, flow = V2) %>% 
  filter(flow > 0)

f_jk$id <- str_remove(f_jk$id, "f_jk_")

# Separate from and to columns based on the id column, where
# x_y means county x to slaughterhouse y

f_jk <- f_jk %>% 
  mutate(orig_id = sapply(strsplit(as.character(id),"_"), "[", 1)) %>% 
  mutate(dest_id = sapply(strsplit(as.character(id),"_"), "[", 2))

# Import the county codes
distr_id <- read.csv("data/distribution_ID.csv") %>% rename(orig_id = X)
cons_id <- read.csv("data/consumption_ID.csv") %>% rename(dest_id = X)

# Merge with the county ID to get their names
f_jk <- f_jk %>% merge(distr_id, by ="orig_id") %>% rename(orig = ID)
f_jk <- f_jk %>% merge(cons_id, by ="dest_id") %>% rename(dest = ID)

# Create ORIGIN-DESTINATION df
f_jk_od <- f_jk %>% 
  select(orig, dest, flow)

write.csv(f_jk_od, "results/flow_jk.csv")


  














