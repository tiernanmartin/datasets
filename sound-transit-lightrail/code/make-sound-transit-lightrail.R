# SETUP ----

library(sf)
library(tidyverse)

# READ DATA ---- 

# NOTE: data originally created by Reddit user u/CheeToS
# https://www.google.com/maps/d/viewer?mid=z7ISwUNS8q7g.k8CnU-m_-G0Q

# Tiernan Martin copied the data and edited it to fit the most recent system map: https://systemexpansion.soundtransit.org/

lightrail_kml <- here::here("sound-transit-lightrail/data/sound-transit-future-lightrail-system-unofficial.kml")

layers <- st_layers(lightrail_kml) %>% pluck("name")

lightrail_sf <- map(layers, st_read, dsn = lightrail_kml, quiet = TRUE) %>% 
  map2(layers, ~ mutate(.x, PROJECT = .y)) %>% 
  reduce(rbind) %>% 
  transmute(PROJECT = str_replace(PROJECT,".+\\-\\s",""),
            NAME = str_replace(Name,"Station","") %>% str_trim,
            LOCATION_CERTAINTY = case_when(
              str_detect(PROJECT, "ST3") ~ "low",
              str_detect(PROJECT, "Current") ~ "high (exists)",
              TRUE ~ "high (planned)"
            ),
         GEOM_IS_POINT = map_lgl(geometry,st_is, type = "POINT")) %>% 
  filter(GEOM_IS_POINT) %>% 
  select(-GEOM_IS_POINT) %>% 
  st_cast("POINT") %>% 
  st_zm(drop = TRUE) %>% 
  as_tibble() %>% 
  st_sf

lightrail_tbl <- lightrail_sf %>% 
  st_set_geometry(NULL) %>% 
  as_tibble()

# WRITE DATA ----

write_csv(lightrail_tbl, here::here("sound-transit-lightrail/data/sound-transit-lightrail.csv"))

st_write(lightrail_sf, here::here("sound-transit-lightrail/data/sound-transit-lightrail.gpkg"))

st_write(lightrail_sf, here::here("sound-transit-lightrail/data/sound-transit-lightrail.geojson"))
