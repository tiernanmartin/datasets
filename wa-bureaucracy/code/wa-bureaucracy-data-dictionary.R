# SETUP ----
 
library(snakecase)
library(datapasta)
library(tidyverse)

# GET DATA ----

vars <- read_csv(here::here("wa-bureaucracy/data/wa-bureaucracy.csv")) %>% 
  colnames() %>% 
  to_mixed_case %>% 
  str_replace_all("_"," ")

# dpasta(tibble(VARIABLE = vars))

            
data_dictionary <- tibble::tribble(
                        ~VARIABLE,                      ~DESCRIPTION,                                                                                                          ~NOTE,
                    "Agency Name",          "The name of the agency",  "Restructured from the original to fit the following pattern: `Type of Agency` `Focus of Agency` `(Acronym)`",
                          "Focus",  "The focus of the agency's work",                                                        "For instance: agriculture, ecology, the lottery, etc.",
                           "Type",          "The type of the agency",                                         "For instance: department, board, office, commission, committee, etc.",
                        "Abbreviation",   "The agency's official acronym",                                                                                                             NA
                   )
# WRITE DATA ----

write_csv(data_dictionary, here::here("wa-bureaucracy/data/wa-bureaucracy-data-dictionary.csv"))
