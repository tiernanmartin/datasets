# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
        ~VARIABLE,                                               ~DESCRIPTION,                                                 ~SOURCE,                                                                                          ~NOTE,
           "Department",  "The name of the department, agency, division or program",  "https://www.usa.gov/executive-departments; https://www.usa.gov/independent-agencies",                                                                                             NA,
   "Abbreviation",                     "The official acronym or abbreviation",                 "https://www.usa.gov/executive-departments",  NA
  )

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("us-bureaucracy/data/us-bureaucracy-dictionary.csv"))
