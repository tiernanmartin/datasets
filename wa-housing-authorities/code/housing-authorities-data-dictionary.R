# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
        ~VARIABLE,   ~DESCRIPTION,  ~SOURCE,                                                                                          ~NOTE,
           "Name",  "The name of the organization",  "http://www.awha.org/" , NA,
           "Counties Served",  "The counties served by the housing authority",  "http://www.awha.org/" , NA
)

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-housing-authorities/data/wa-housing-authorities-dictionary.csv"))
