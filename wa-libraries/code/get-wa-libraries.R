# SETUP ----

library(tigris)
library(janitor) 
library(glue)
library(rvest)
library(placement) 
library(sf)
library(tidyverse)

options(tigris_class = "sf")

# GET DATA ----

libraries_table_url <- "http://www.publiclibraries.com/washington.htm"

libs <- read_html(libraries_table_url) %>% 
  html_nodes(css = "table") %>% 
  html_table(header = TRUE) %>% 
  flatten_df() %>% 
  rename_all(snakecase::to_screaming_snake_case)

counties <- tigris::counties(state = "WA", cb = TRUE) %>% 
  transmute(COUNTY = NAME) %>% 
  st_transform(4326)

# GECODE DATA ----

libs_addr <- libs %>%   
  mutate(ADDRESS_FULL = as.character(glue("{ADDRESS}, {CITY}, WA, {ZIP}")))

geocode_fun <- function(address){
    geocode_url(address, 
                auth="standard_api", 
                privkey="",  # this can be replaced with a free private key from Google's API
                clean=TRUE, 
                add_date='today', 
                verbose=TRUE) 
  }

libs_sf <- libs_addr %>%  
  mutate(geocode_addr =  map(ADDRESS_FULL, geocode_fun)) %>% 
  unnest %>% 
  janitor::clean_names("screaming_snake") %>% 
  st_as_sf(coords = c("LNG", "LAT")) %>% 
  st_set_crs(4326) 

get_coord <- function(x, coord){x %>% st_coordinates() %>% as.data.frame() %>% pluck(coord)}

libs_ready <- libs_sf %>% 
  transmute(LIBRARY_NAME = LIBRARY,
            FORMATTED_ADDRESS,
            PHONE = PHONE) %>% 
  st_join(counties) %>% 
  separate(FORMATTED_ADDRESS, c("ADDRESS","CITY","STATE_ZIP","COUNTRY"), sep = ", ") %>%  
  separate(STATE_ZIP, c("STATE", "ZIP_CODE"), sep = " ") %>% 
  transmute(LIBRARY_NAME,
         PHONE,
         ADDRESS,
         CITY,
         COUNTY,
         STATE,
         ZIP_CODE,
         LNG = map_dbl(geometry,get_coord,"X"),
         LAT = map_dbl(geometry,get_coord,"Y"))


# WRITE DATA ----

st_write(libs_ready, here::here("wa-libraries/data/wa-libraries.gpkg"))
