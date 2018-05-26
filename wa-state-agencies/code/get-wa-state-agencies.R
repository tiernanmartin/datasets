# SETUP ----

library(rvest)
library(tidyverse)

# GET DATA ----

agencies_url <- "https://access.wa.gov/agency.html"

agencies_list <- read_html(agencies_url) %>% 
  html_nodes(".agencyList") %>% 
  html_text(trim = TRUE)

agencies <- tibble(AGENCIES = agencies_list) %>% 
  transmute(AGENCY_NAME_FULL = str_squish(str_replace_all(AGENCIES,"\r\n","")),
            FOCUS = str_extract(AGENCY_NAME_FULL,".+(?=,)"),
            TYPE = str_extract(AGENCY_NAME_FULL,"(?<=,[[:space:]]).+(?=\\s\\()"),
            ACRONYM = str_extract(AGENCY_NAME_FULL,"(?<=\\().+(?=\\))")) %>%  
  transmute(AGENCY_NAME = case_when(
    is.na(FOCUS) ~AGENCY_NAME_FULL,
    TRUE ~ str_c(TYPE, FOCUS,str_c("(",ACRONYM,")",sep=""),sep = " ")
  ),
  FOCUS,
  TYPE,
  ACRONYM) %>% 
  mutate_all(funs(if_else(is.na(.),"",.)))
            
# WRITE DATA ----

write_csv(agencies, here::here("wa-state-agencies/data/wa-state-agencies.csv"))
