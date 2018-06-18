# SETUP ----

library(rvest)
library(tidytext)
library(tidyverse)

# GET DATA ----

agencies_url <- "https://access.wa.gov/agency.html"

agencies_list <- read_html(agencies_url) %>% 
  html_nodes(".agencyList") %>% 
  html_text(trim = TRUE)

agencies <- tibble(AGENCIES = agencies_list) %>% 
  transmute(N = row_number(),
            AGENCY_NAME_FULL = str_squish(str_replace_all(AGENCIES,"\r\n","")),
            FOCUS = str_extract(AGENCY_NAME_FULL,".+(?=,)"),
            TYPE = str_extract(AGENCY_NAME_FULL,"(?<=,[[:space:]]).+(?=\\s\\()"),
            ACRONYM = str_extract(AGENCY_NAME_FULL,"(?<=\\().+(?=\\))")) %>%  
  transmute(N,
            AGENCY_NAME = case_when(
    is.na(FOCUS) ~AGENCY_NAME_FULL,
    TRUE ~ str_c(TYPE, FOCUS,str_c("(",ACRONYM,")",sep=""),sep = " ")
  ),
  FOCUS,
  TYPE,
  ACRONYM)
            
types <- tibble::tribble(
   ~TYPE_PATTERN, ~TYPE_CATEGORY,
         "Board",        "board",
        "Office",       "office",
    "Commission",   "commission",
    "Department",   "department",
       "Council",      "council",
     "Committee",    "committee",
     "Authority",    "authority",
       "Program",      "program",
        "Agency",       "agency",
         "Court",        "court",
      "Division",     "division",
     "Institute",    "institute",
       "Library",      "library",
        "Center",       "center",
   "Legislature",  "legislature"
  )

agencies_types <- agencies %>% 
  mutate(TOKEN = AGENCY_NAME) %>% 
  unnest_tokens(TOKEN, TOKEN) %>% 
  left_join(types, by = c(TOKEN = "TYPE_CATEGORY")) %>% 
  group_by(N) %>% 
  arrange(TYPE_PATTERN) %>% 
  slice(1) %>% 
  ungroup %>% 
  transmute(AGENCY_NAME, 
            FOCUS,
            TYPE = TYPE_PATTERN,
            ABBREVIATION = ACRONYM) 


# WRITE DATA ----

write_csv(agencies_types, here::here("wa-bureaucracy/data/wa-bureaucracy.csv"))
