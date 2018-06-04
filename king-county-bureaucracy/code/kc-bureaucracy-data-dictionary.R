# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----

vars <- read_csv(here::here("king-county-bureaucracy/data/kc-bureaucracy.csv")) %>% 
  colnames() %>%  
  to_mixed_case %>% 
  str_replace_all("_"," ") %>% 
  {tibble(VARIABLE = .)}

# dpasta(tibble(VARIABLE = vars))


data_dictionary <- tibble::tribble(
        ~VARIABLE,                                                  ~DESCRIPTION,                             ~SOURCE,                                                                                                      ~NOTE,
           "Name",     "The name of the department, agency, division or program",  "http://directory.kingcounty.gov/",                                                                                                         NA,
   "Abbreviation",                                        "The official acronym",  "http://directory.kingcounty.gov/",                                                                                                         NA,
    "Description",                                "A description of the purpose",  "http://directory.kingcounty.gov/",                                                                                                         NA,
         "Parent",          "The department underwhich this public office falls",  "http://directory.kingcounty.gov/",                                                                                                         NA,
          "Depth",  "The bureaucratic distance from the department-level parent",  "http://directory.kingcounty.gov/",  "Department-level parents are those departments and agencies with black backgrounds in the diagram below"
  )

  
# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("king-county-bureaucracy/data/kc-bureaucracy-dictionary.csv"))
