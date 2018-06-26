# SETUP ----
 
library(tigris)
library(placement)
library(janitor) 
library(sf)
library(tidyverse)

options(tigris_class = "sf")

# READ DATA ---- 

 higher_ed_schools_raw <- read_csv(here::here("wa-higher-ed-providers/data/CollegeNavigator_Search_2018-06-26_15.26.18.csv")) %>% 
   clean_names(case = "screaming_snake")
 
 counties <- tigris::counties(state = "WA", cb = TRUE) %>% 
  transmute(COUNTY = NAME) %>% 
  st_transform(4326)
 
# TRANSFORM DATA ----------------------------------------------------------

 higher_ed_schools <- higher_ed_schools_raw %>% 
   slice(1:119) %>% 
   select(NAME, ADDRESS, TYPE, CAMPUS_SETTING, CAMPUS_HOUSING, STUDENT_POPULATION) %>% 
   transmute(NAME,
             ADDRESS,
             STUDENT_POPULATION,
             INSTITUTION_TYPE = str_extract(TYPE, "(?<=,).+") %>% str_replace(".+,",""),
             DEGREE_TYPE = str_extract(TYPE, ".+(?=,)") %>% str_replace(",.+","") , 
             CAMPUS_SETTING_TYPE = str_extract(CAMPUS_SETTING,".+(?=:)"),
             CAMPUS_SETTING_SIZE = str_extract(CAMPUS_SETTING,"(?<=:).+")
             ) %>% 
   mutate_if(is.character, str_trim)
   
# GECODE DATA ----
 
geocode_fun <- function(address){
    geocode_url(address, 
                auth="standard_api", 
                privkey="AIzaSyAC19c3TtQwrSiQYKYDaf-9nDIqahirnD8",  # this can be replaced with a free private key from Google's API
                clean=TRUE, 
                add_date='today', 
                verbose=TRUE) 
  }

get_coord <- function(x, coord){x %>% st_coordinates() %>% as.data.frame() %>% purrr::pluck(coord)}

higher_ed_schools_geocode <- higher_ed_schools %>%  
  mutate(geocode_addr =  map(ADDRESS, geocode_fun)) %>% 
  unnest %>% 
  janitor::clean_names("screaming_snake") %>% 
  st_as_sf(coords = c("LNG", "LAT")) %>% 
  st_set_crs(4326) 



higher_ed_schools_sf <- higher_ed_schools_geocode %>%   
  mutate(FORMATTED_ADDRESS = case_when(
    str_count(FORMATTED_ADDRESS,",") %in% 5 ~ str_extract(FORMATTED_ADDRESS,"(?<=,\\s).+" ) %>% str_extract("(?<=,\\s).+" ),# drop triple-line street addresses
    str_count(FORMATTED_ADDRESS,",") %in% 4 ~ str_extract(FORMATTED_ADDRESS,"(?<=,\\s).+" ), # drop double-line street addresses
    TRUE ~ FORMATTED_ADDRESS
  )) %>%  
  st_join(counties) %>% 
  separate(FORMATTED_ADDRESS, c("ADDRESS","CITY","STATE_ZIP","COUNTRY"), sep = ", ") %>%  
  separate(STATE_ZIP, c("STATE", "ZIP_CODE"), sep = " ") %>% 
  transmute(NAME, 
            STUDENT_POPULATION,
            INSTITUTION_TYPE,
            DEGREE_TYPE,
            CAMPUS_SETTING_TYPE,
            CAMPUS_SETTING_SIZE,
         ADDRESS,
         CITY,
         COUNTY,
         STATE,
         ZIP_CODE,
         LNG = map_dbl(geometry, get_coord,"X"),
         LAT = map_dbl(geometry, get_coord,"Y"))  
         
 higher_ed_schools_tbl <- higher_ed_schools_sf %>% 
   st_set_geometry(NULL) %>% 
   as_tibble
 
# WRITE DATA ----

write_csv(higher_ed_schools_tbl, here::here("wa-higher-ed-providers/data/wa-higher-ed-providers.csv"))

st_write(higher_ed_schools_sf, here::here("wa-higher-ed-providers/data/wa-higher-ed-providers.gpkg"))

st_write(higher_ed_schools_sf, here::here("wa-higher-ed-providers/data/wa-higher-ed-providers.geojson"))


