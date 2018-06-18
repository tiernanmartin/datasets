# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
data_dictionary <- tibble::tribble(
        ~VARIABLE,   ~DESCRIPTION,  ~SOURCE,                                                                                          ~NOTE,
           "Name",  "The name of the tribe",  "http://www.washingtontribes.org/" , NA
)

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-tribes/data/wa-tribes-dictionary.csv"))
