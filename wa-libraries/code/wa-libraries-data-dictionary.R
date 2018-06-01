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
        ~VARIABLE,                                          ~DESCRIPTION,                                                  ~NOTE,
   "Library Name",                             "The name of the library",                                                     NA,
          "Phone",                                    "The phone number",                                                     NA,
        "Address",                                  "The street address",  "Formatted according to the Google Maps API standard",
           "City",               "The city where the library is located",                                                     NA,
         "County",              "The county where the librar is located",                                                     NA,
          "State",              "The state where the library is located",                                                     NA,
       "Zip Code",            "The zip code where the libary is located",                                                     NA,
            "Lng",  "The longitude of the libraries geographic location",                                                     NA,
            "Lat",   "The latitude of the libraries geographic location",                                                     NA,
           "geom",              "The geometry of the libraries location",                                 "Geometry type: POINT"
  )

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-libraries/data/wa-libraries-data-dictionary.csv"))
