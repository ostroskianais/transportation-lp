library(tidyverse)
library(sf)

# Get county geometries and transform to latitude and longitude
stt <- st_as_sf(maps::map("state", plot = F, fill = T))

cnty <- st_as_sf(maps::map("county", plot = F, fill = T))
cnty_centroids <- st_centroid(cnty) %>% 
  mutate(longitude = st_coordinates(.)[,1],
         latitude = st_coordinates(.)[,2])%>% 
  as_tibble() %>% select(ID, longitude, latitude) 

# Create origin and destination file with latitude and longitude
ij_od <- read.csv("results/flow_ij.csv") %>% 
  left_join(cnty_centroids, by = c("orig" = "ID")) %>% 
  rename(x = longitude, y = latitude) %>% 
  left_join(cnty_centroids, by = c("dest" = "ID")) %>% 
  rename(xend = longitude, yend = latitude) %>% 
  filter(!x == xend, !y == yend) 

jk_od <- read.csv("results/flow_jk.csv") %>% 
  left_join(cnty_centroids, by = c("orig" = "ID")) %>% 
  rename(x = longitude, y = latitude) %>% 
  left_join(cnty_centroids, by = c("dest" = "ID")) %>% 
  rename(xend = longitude, yend = latitude) %>% 
  filter(!x == xend, !y == yend) 

# Map ----------------------------------------------------------

ggplot() +
  
  geom_sf(data = stt, color = "gray25", fill = "gray30") +
  
  geom_curve(aes(x = x, y = y, xend = xend, yend = yend, alpha=flow,
                 color="Production to Distribution"),     # draw edges as arcs
             data = ij_od, curvature = 0.1, size = 0.5, 
             show.legend = FALSE, 
             color = "tomato") +
  
  geom_curve(aes(x = x, y = y, xend = xend, yend = yend, alpha=flow,
                 color="Distribution to Consumption"),     # draw edges as arcs
             data = jk_od, curvature = 0.1, size = 0.5,
             show.legend = FALSE,
             color = "gold") +
  
  geom_sf(data=consumption_centroids, aes(size=cons), alpha = 0.6, color = "white") +
  
  geom_sf(data=production_centroids, aes(size=prod), alpha = 0.6, color = "tomato") +
  
  geom_sf(data=distribution_centroids, aes(size=distr), alpha = 0.6, color = "gold") +
  
  scale_size(range = c(1,10)) +
  
  scale_alpha(range = c(0.2,1)) +
  
  theme_void() +
  theme(plot.background = element_rect(fill = "black"),
        panel.background = element_rect(fill = "black"))
  
  
  
  
  