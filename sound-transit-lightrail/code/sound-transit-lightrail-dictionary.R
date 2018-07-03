# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
        ~VARIABLE,   ~DESCRIPTION,  ~SOURCE,  ~NOTE,
           "Project",  "The name of the specific Sound Transit project during which each station is constructed",  "https://systemexpansion.soundtransit.org/projects" , NA,
        "Name", "The name of the station", "https://systemexpansion.soundtransit.org/projects", "Station names for ST3 stations may change",
        "Location Certainty", "The level of certainty about the geographic location of each station","https://systemexpansion.soundtransit.org/projects", "Including: 'high (exists)', 'high (planned)', and 'low'"
)

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("sound-transit-lightrail/data/sound-transit-lightrail-dictionary.csv"))
