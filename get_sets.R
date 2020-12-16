library(tidyverse)
library(sf)

# Get geometry
cnty <- st_as_sf(maps::map("county", plot = F, fill = T))
stt <- st_as_sf(maps::map("state", plot = F, fill = T))

# Get census data and merge geometry
population <- read.csv(file = "data/census_pop.csv") %>% 
  merge(cnty, by="ID") %>% st_as_sf()

# Separate counties in sets of:
# production, distribution and consumption

# consumption
consumption <- population %>% 
  arrange(desc(population_2017)) %>% 
  slice(1:30) %>% 
  as_tibble() %>% 
  arrange(ID) 

# production
production <- population[sample(nrow(population), 10),] %>% 
  as_tibble() %>% 
  arrange(ID)

# distribution
distribution <- population[sample(nrow(population), 20),] %>% 
  as_tibble() %>% 
  arrange(ID)

# To assign values of production, distribution and consumption
# we assume that production and distribution values follow a normal distribution
# while consumption values follow a log-normal distribution

# In order for the model to be feasible, we need to ensure that the consumption and distribution
# values are equal to or lower than the sum of total production

# To do this while also generating random numbers, we normalize the random values by dividing them by the sum
# and then multiplying the whole set by an arbitrary value of 250 for production and distribution
# and 225 for consumption

# Production
random <- rnorm(10, mean = 100, sd = 30)  
random2 <- 250*(random/sum(random))

production <- production %>% 
  mutate(prod = random2)

# Distribution
random <- rnorm(20, mean = 100, sd = 40)  
random2 <- 250*(random/sum(random))

distribution <- distribution %>% 
  mutate(distr = random2)

# Consumption
# Assume a 10% loss 
#set.seed(92826)
random <- rlnorm(30, meanlog = log(100), sdlog = log(5))  
random2 <- 225*(random/sum(random))

consumption <- consumption %>% 
  mutate(cons = random2)

# Write production, distribution and consumption CSV sets:
write.table(production$prod, file = "data/production.csv", sep=",", row.names = FALSE, col.names = FALSE)
write.table(distribution$distr, file = "data/distribution.csv", sep=",", row.names = FALSE, col.names = FALSE)
write.table(consumption$cons, file = "data/consumption.csv", sep=",", row.names = FALSE, col.names = FALSE)

# Write county codes and make sure the id number X starts with zero
# row numbers in python start at 0, but in R they start at 1
production$X <- c(0:(nrow(production)-1))
distribution$X <- c(0:(nrow(distribution)-1))
consumption$X <- c(0:(nrow(consumption)-1))

write.csv(production %>% as_tibble() %>% select(ID, prod, X), file = "data/production_ID.csv", row.names = FALSE)
write.csv(distribution %>% as_tibble() %>% select(ID, distr, X), file = "data/distribution_ID.csv", row.names = FALSE)
write.csv(consumption %>% as_tibble() %>% select(ID, cons, X), file = "data/consumption_ID.csv", row.names = FALSE)
