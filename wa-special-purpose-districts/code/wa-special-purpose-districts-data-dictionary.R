# SETUP ----
 
library(snakecase)
library(datapasta)
library(sf)
library(tidyverse)

# GET DATA ----
  
vars <- read_csv(here::here("wa-special-purpose-districts/data/wa-special-purpose-districts.csv")) %>% 
  colnames() %>% 
  to_mixed_case %>% 
  str_replace_all("_"," ")



data_dictionary <- tibble::tribble(
             ~VARIABLE,                                                      ~DESCRIPTION,             ~SOURCE,                                                               ~NOTE,
       "District Name",                       "The name of the district or taxing entity",  "http://mrsc.org/",                                                                  NA,
     "District Number",                       "The identification number of the district",  "http://mrsc.org/",                                                                  NA,
                "Type",                                    "The type of service provided",  "http://mrsc.org/",             "For instance: Fire Protection, School, Cemetary, etc.",
              "Status",  "Whether the district is active, inactive, or some other status",  "http://mrsc.org/",          "For instance: annexed, disposition unknown, merged, etc.",
              "County",                        "The county where the district is located",  "http://mrsc.org/",                                                                  NA,
   "Counties Included",        "The counties included in the district (if more than one)",  "http://mrsc.org/",                              "County names are separated by commas",
              "Places",                              "The place included in the district",  "http://mrsc.org/",                                                                  NA,
       "District Note",                                                  "A general note",  "http://mrsc.org/",  "The original data includes this information in the District Name",
        " Change Note",                      "A summary of the changes or a general note",  "http://mrsc.org/",   "Data in this column is not consistently structured or formatted"
  )

  

# WRITE DATA DICTIONARY ----

write_csv(data_dictionary, here::here("wa-special-purpose-districts/data/wa-special-purpose-districts-dictionary.csv"))
