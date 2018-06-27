# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
          ~VARIABLE,                                              ~DESCRIPTION,                                     ~SOURCE,                                                  ~NOTE,
             "Name",                                 "Name of the hospital",                           "data.medicare.gov",                                                    " ",
    "Hospital Type",                           "The type of services provided",                        "data.medicare.gov",     "Includes: Acute Care, Critical Access, Childrens",
   "Ownership Type",                                   "The type of ownership",                        "data.medicare.gov",  "For instance: Government - Local, Voluntary non-profit - Private, Proprietary, etc.",
          "Address",                        "The hospital's street address",                           "Google Maps API",                                                    " ",
             "City",               "The city where the hospital is located",                           "Google Maps API",                                                    " ",
           "County",             "The county where the hospital is located",                           "Google Maps API",                                                    " ",
            "State",              "The state where the hospital is located",                           "Google Maps API",                                                    " ",
         "Zip Code",                      "The hospital's address zip code",                           "Google Maps API",                                                    " ",
              "Lng",  "The longitude of the hospital's geographic location",                           "Google Maps API",                                                    " ",
              "Lat",   "The latitude of the hospital's geographic location",                           "Google Maps API",                                                    " ",
             "geom",                  "The geometry of the libraries location",                           "Google Maps API",                                                    " "
  )


# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-hospitals/data/wa-hospitals-dictionary.csv"))
