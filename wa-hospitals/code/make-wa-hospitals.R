# SETUP ----
  
library(glue)
library(placement)
library(janitor) 
library(sf)
library(tidyverse)

options(tigris_class = "sf")

# READ DATA ---- 

# NOTE: data source is "https://data.medicare.gov/Hospital-Compare/Hospital-General-Information/xubh-q36u/data"

hospitals_raw <- read_csv(here::here("wa-hospitals/data/Hospital_General_Information.csv")) %>% 
  clean_names("screaming_snake")


# TRANSFORM DATA ----------------------------------------------------------

hospitals <- hospitals_raw %>% 
  transmute(NAME = str_to_title(HOSPITAL_NAME),
            HOSPITAL_TYPE = HOSPITAL_TYPE,
            OWNERSHIP_TYPE = HOSPITAL_OWNERSHIP,
            ADDRESS = str_to_title(ADDRESS),
            CITY = str_to_title(CITY),
            COUNTY = str_to_title(COUNTY_NAME),
            STATE,
            ZIP_CODE,
            ADDRESS_FULL = as.character(glue("{NAME}, {ADDRESS}, {CITY}, {STATE} {ZIP_CODE}, USA"))
            )
hospitals_wa <- filter(hospitals, STATE %in% "WA") 
   
# GECODE DATA ----
 
geocode_fun <- function(address){
    geocode_url(address, 
                auth="standard_api", 
                privkey="",  # this can be replaced with a free private key from Google's API
                clean=TRUE, 
                add_date='today', 
                verbose=TRUE) 
  }

get_coord <- function(x, coord){x %>% st_coordinates() %>% as.data.frame() %>% purrr::pluck(coord)}

hospitals_geocode <- hospitals_wa %>%  
  mutate(geocode_addr =  map(ADDRESS_FULL, geocode_fun)) %>% 
  unnest %>% 
  janitor::clean_names("screaming_snake") %>% 
  st_as_sf(coords = c("LNG", "LAT")) %>% 
  st_set_crs(4326) 

hospitals_sf <- hospitals_geocode %>%   
  mutate(FORMATTED_ADDRESS = case_when(
    str_count(FORMATTED_ADDRESS,",") %in% 5 ~ str_extract(FORMATTED_ADDRESS,"(?<=,\\s).+" ) %>% str_extract("(?<=,\\s).+" ),# drop triple-line street addresses
    str_count(FORMATTED_ADDRESS,",") %in% 4 ~ str_extract(FORMATTED_ADDRESS,"(?<=,\\s).+" ), # drop double-line street addresses
    TRUE ~ FORMATTED_ADDRESS
  )) %>%   
  select(NAME, 
         HOSPITAL_TYPE,
         OWNERSHIP_TYPE,
         COUNTY,
         FORMATTED_ADDRESS) %>% 
  separate(FORMATTED_ADDRESS, c("ADDRESS","CITY","STATE_ZIP","COUNTRY"), sep = ", ") %>%  
  separate(STATE_ZIP, c("STATE", "ZIP_CODE"), sep = " ") %>% 
  transmute(NAME, 
         HOSPITAL_TYPE,
         OWNERSHIP_TYPE,
         ADDRESS,
         CITY,
         COUNTY,
         STATE,
         ZIP_CODE,
         LNG = map_dbl(geometry, get_coord,"X"),
         LAT = map_dbl(geometry, get_coord,"Y"))  
         
 hospitals_tbl <- hospitals_sf %>% 
   st_set_geometry(NULL) %>% 
   as_tibble
 
# WRITE DATA ----

write_csv(hospitals_tbl, here::here("wa-hospitals/data/wa-hospitals.csv"))

st_write(hospitals_sf, here::here("wa-hospitals/data/wa-hospitals.gpkg"))

st_write(hospitals_sf, here::here("wa-hospitals/data/wa-hospitals.geojson"))


