# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----

vars <- read_csv( here::here("seattle-bureaucracy/data/seattle-bureaucracy-dictionary.csv")) %>% 
  colnames() %>%  
  to_mixed_case %>% 
  str_replace_all("_"," ") %>% 
  {tibble(VARIABLE = .)}

# dpasta(tibble(VARIABLE = vars))


data_dictionary <- tibble::tribble(
        ~VARIABLE,                                               ~DESCRIPTION,                                                 ~SOURCE,                                                                                          ~NOTE,
           "Dept",  "The name of the department, agency, division or program",  "http://www.seattle.gov/city-departments-and-agencies",                                                                                             NA,
   "Abbreviation",                     "The official acronym or abbreviation",                 "http://www.seattle.gov/pan/soup.htm#s",  "THe page is temporarily down, so an archived version of the page was used (Wayback Machine)"
  )

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("seattle-bureaucracy/data/seattle-bureaucracy-dictionary.csv"))
