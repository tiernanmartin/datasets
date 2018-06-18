# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
        ~VARIABLE,                                               ~DESCRIPTION,                                                 ~SOURCE,                                                                                          ~NOTE,
           "Dept",  "The name of the department, agency, division or program",  "https://www.usa.gov/executive-departments",                                                                                             NA,
   "Abbreviation",                     "The official acronym or abbreviation",                 "https://www.usa.gov/executive-departments",  NA
  )

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("us-bureaucracy/data/us-bureaucracy-dictionary.csv"))
