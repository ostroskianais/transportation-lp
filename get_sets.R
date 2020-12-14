library(tidyverse)
library(sf)

# Get geometry
cnty <- st_as_sf(maps::map("county", plot = F, fill = T))
stt <- st_as_sf(maps::map("stt", plot = F, fill = T))

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
# We are going to assume no losses throughout the supply chain, so 
# the sum for production is the same as the sum for distribution
# We generate values, normalize them by dividing by the sum and then scale

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
random <- rlnorm(30, meanlog = log(100), sdlog = log(5))  
random2 <- 225*(random/sum(random))

consumption <- consumption %>% 
  mutate(cons = random2)

# Write production, distribution and consumption CSV sets:
write.csv(production$prod, file = "data/production.csv", row.names = FALSE)
write.csv(distribution$distr, file = "data/distribution.csv", row.names = FALSE)
write.csv(consumption$cons, file = "data/consumption.csv", row.names = FALSE)

