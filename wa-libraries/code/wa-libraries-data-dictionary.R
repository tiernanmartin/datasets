# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----

vars <- st_read(here::here("wa-libraries/data/wa-libraries.gpkg")) %>% 
  colnames() %>%  
  to_mixed_case %>% 
  str_replace_all("_"," ") %>% 
  {tibble(VARIABLE = .)}

# dpasta(tibble(VARIABLE = vars))


data_dictionary <- tibble::tribble(
        ~VARIABLE,                                          ~DESCRIPTION,                              ~SOURCE,                   ~NOTE,
   "Library Name",                             "The name of the library",            "www.publiclibraries.com",                      NA,
          "Phone",                                    "The phone number",            "www.publiclibraries.com",                      NA,
        "Address",                                  "The street address",                    "Google Maps API",                      NA,
           "City",               "The city where the library is located",                    "Google Maps API",                      NA,
         "County",             "The county where the library is located",  "US Census Bureau TIGER Shapefiles",                      NA,
          "State",              "The state where the library is located",                    "Google Maps API",                      NA,
       "Zip Code",            "The zip code where the libary is located",                    "Google Maps API",                      NA,
            "Lng",  "The longitude of the libraries geographic location",                    "Google Maps API",                      NA,
            "Lat",   "The latitude of the libraries geographic location",                    "Google Maps API",                      NA,
           "geom",              "The geometry of the libraries location",                    "Google Maps API",  "Geometry type: POINT"
  )



# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-libraries/data/wa-libraries-data-dictionary.csv"))
