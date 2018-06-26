# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
               ~VARIABLE,                                               ~DESCRIPTION,                                     ~SOURCE, ~NOTE,
                  "Name",                                  "Name of the institution",  "National Center for Education Statistics",   " ",
    "Student Population",                             "Number of students attending",  "National Center for Education Statistics",   " ",
      "Institution Type",  "The type of public or private status of the institution",  "National Center for Education Statistics",   "Includes: Private not-for-profit, private for-profit, Public",
           "Degree Type",                               "The type of degree offered",  "National Center for Education Statistics",   "Includes: 4-year, 2-year, < 2-year",
   "Campus Setting Type",            "The type of place where the campus is located",  "National Center for Education Statistics",   "Includes: City, Suburb, Town, Rural",
   "Campus Setting Size",                     "The size of the campus setting place",  "National Center for Education Statistics",   "For instance: Large, Midsize, Small, etc.",
               "Address",                         "The institution's street address",                           "Google Maps API",   " ",
                  "City",                "The city where the institution is located",                           "Google Maps API",   " ",
                "County",              "The county where the institution is located",                           "Google Maps API",   " ",
                 "State",               "The state where the institution is located",                           "Google Maps API",   " ",
              "Zip Code",                       "The institution's address zip code",                           "Google Maps API",   " ",
                   "Lng",   "The longitude of the institution's geographic location",                           "Google Maps API",   " ",
                   "Lat",    "The latitude of the institution's geographic location",                           "Google Maps API",   " ",
                  "geom",                   "The geometry of the libraries location",                           "Google Maps API",   " "
  )

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-higher-ed-providers/data/wa-higher-ed-providers-dictionary.csv"))
