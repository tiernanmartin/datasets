
# SETUP -------------------------------------------------------------------

library(svglite)
library(ggrepel) 
library(glue)
library(tigris)
library(sf)
library(tidyverse)

options(tigris_class = "sf")

# LOAD DATA ---------------------------------------------------------------

counties <- counties(state = "WA", cb = TRUE) %>% 
  select(COUNTY = NAME)

spd <- read_csv(here::here("wa-special-purpose-districts/data/wa-special-purpose-districts.csv"))



# TRANSFORM DATA ----------------------------------------------------------

counties_coords <- counties %>% 
  st_centroid() %>% 
  st_coordinates() %>% 
  as_tibble %>% 
  bind_cols(counties) %>% 
  st_sf()

count_counties <- function(x){
  tibble(COUNTY = x,
         N = str_count(spd$COUNTIES_INCLUDED,x) %>% sum(na.rm = TRUE) )
}

county_n <- map_df(unique(spd$COUNTY), count_counties) %>% 
  arrange(desc(N)) %>% 
  full_join(counties_coords) %>% 
  mutate(LABEL = glue("{COUNTY} ({N})") %>% as.character()
  ) %>% 
  st_sf()




# CREATE PLOT -------------------------------------------------------------

county_ready <- county_n %>% 
  mutate(X_RANGE = abs(max(X)-min(X)),
         Y_RANGE = abs(max(Y)-min(Y)),
         NUDGE_X = case_when( COUNTY %in% c("Island", "San Juan", "Wahkiakum") ~ -1 * 0.1 * X_RANGE, TRUE ~ 0 ),
         NUDGE_Y = case_when( COUNTY %in% c("Island", "San Juan") ~ 1 * 0.05 * Y_RANGE, 
                              COUNTY %in% c("Wahkiakum") ~ -1 * 0.05 * Y_RANGE,
                              TRUE ~ 0 )
  )


gg_plot <- ggplot(data = county_ready) +
  geom_sf(color = "white") +
  geom_text_repel(aes(x = X,y = Y, label = LABEL),
                  nudge_x = county_ready$NUDGE_X,
                  nudge_y = county_ready$NUDGE_Y,
                  size = 3,
                  min.segment.length = 0,
                  point.padding = NA,
                  segment.color = "grey50") +
  coord_sf(datum = NA) +
  theme_void()

gg_plot

ggsave(here::here("wa-special-purpose-districts/resources/spd-county-map.png"),dpi = "retina")
