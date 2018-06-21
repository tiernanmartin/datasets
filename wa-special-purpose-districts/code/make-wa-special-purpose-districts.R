# SETUP -------------------------------------------------------------------

library(fuzzyjoin)
library(datapasta)
library(readxl)  
library(janitor)
library(rvest) 
library(tidyverse)


# READ DATA ---------------------------------------------------------------


data_colnames <- c("COUNTIES","NAME","PLACES","CHANGE_NOTE")  

spd_untidy <- read_excel(here::here("wa-special-purpose-districts/data/spdcounty.xlsx"), 
                         sheet = "Special Districts by County", 
                         col_names = data_colnames, skip = 3) %>% 
  remove_empty("rows")


# TIDY DATA ---------------------------------------------------------------

spd_county <- spd_untidy %>% 
  transmute(COUNTY = case_when(str_detect(COUNTIES, "County") ~ str_extract(COUNTIES,".+(?=\\sCounty)"),
                               TRUE ~ NA_character_),
            COUNTIES_INCLUDED = str_replace_all(COUNTIES," County",""),
            DISTRICT_NAME = NAME,
            DISTRICT_NUMBER = str_extract(NAME,"(?<=No.\\s|No\\s)\\d+"),
            PLACES,
            CHANGE_NOTE
  ) %>% 
  separate(DISTRICT_NAME, c("DISTRICT_NAME","DISTRICT_NOTE"), sep = " - ") %>% 
  fill(COUNTY,.direction = "down")

clean_district_names <- function(x){
  county_names <- str_c(unique(spd_county$COUNTY),collapse = "|") 
  
  x %>% 
    str_replace_all(county_names,"") %>% 
    str_replace_all("and|of","") %>% 
    str_replace_all("No\\s\\d+|No\\.\\s\\d+", "") %>% 
    str_replace_all("County|[[:punct:]]+","") %>%  
    str_squish() %>% 
    str_trim("both")
  
}


spd_clean_names <- spd_county %>%  
    mutate(DISTRICT_NAME_CLEAN = map_chr(DISTRICT_NAME, clean_district_names))

# NOTE: consider using the types listed here: 
#  http://mrsc.org/Home/Explore-Topics/Governance/Forms-of-Government-and-Organization/Special-Purpose-Districts-in-Washington/Special-Purpose-Districts-Grouped-by-Function.aspx

explore_types <- function(){
  spd_clean_names %>% 
    transmute(DISTRICT_NAME,
              DISTRICT_NAME_CLEAN,
              TYPE_1 = str_extract(DISTRICT_NAME_CLEAN, "\\w+(?=\\sDistrict)"),
              TYPE_2 = str_extract(DISTRICT_NAME_CLEAN, "\\w+\\s\\w+(?=\\sDistrict)"),
              TYPE_3 = str_extract(DISTRICT_NAME_CLEAN, "\\w+\\s\\w+\\s\\w+(?=\\sDistrict)"),
              TYPE_4 = str_extract(DISTRICT_NAME_CLEAN, "\\w+\\s\\w+\\s\\w+\\s\\w+(?=\\sDistrict)"),
              TYPE_5 = str_extract(DISTRICT_NAME_CLEAN, "\\w+(?=\\s(Authority|Agency))")
              ) %>% 
    gather("NAME_LENGTH","NAME",TYPE_1:TYPE_5) %>% 
    mutate(NAME_LENGTH = factor(NAME_LENGTH) %>% fct_rev) %>% 
    group_by(NAME_LENGTH) %>% 
    count(NAME) %>% 
    drop_na() %>% 
    filter(n>2) %>% 
    arrange(NAME_LENGTH,desc(n)) %>% 
    ungroup  
}

# explore_types() %>% transmute(n,NAME,TYPE = ".") %>% dpasta()

create_district_types <- function(){
  tibble::tribble(
                                       ~n,                              ~NAME, ~TYPE,
                                       44L,                         "Housing",   "Housing Authority",
                                       6L,                              "Air",   "Clear Air",
                                       5L,                             "Fire",   "Fire Protection",
                                       5L,                          "Transit",   "Transportation",
                                       4L,                   "Transportation",   "Transportation",
                                      12L,               "Flood Control Zone",   "Flood Control",
                                       7L,  "Drainage Irrigation Improvement",   "Drainage/Irrigation",
                                       5L,       "Emergency Medical Services",   "Emergency Medical Services",
                                       4L,            "Joint Park Recreation",   "Parks",
                                       3L,  "Consolidated Diking Improvement",   "Dikes",
                                       3L,                 "Lake Water Sewer",   "Water/Sewer",
                                       3L,                  "Loon Lake Sewer",   "Sewer",
                                       3L,       "Regional Public Facilities",   "Public Facilities",
                                       3L,            "Rural Partial Library",   "Library",
                                     391L,                  "Fire Protection",   "Fire Protection",
                                      57L,                  "Public Hospital",   "Hospital",
                                      48L,                  "Park Recreation",   "Parks",
                                      47L,           "Transportation Benefit",   "Transportation",
                                      28L,                   "Public Utility",   "Public Utility",
                                      23L,                "Public Facilities",   "Public Facilities",
                                      21L,                      "Water Sewer",   "Water/Sewer",
                                      16L,                    "Valley School",   "School",
                                      14L,                    "Rural Library",   "Library",
                                      13L,                    "Flood Control",   "Flood Control",
                                      13L,                 "Mosquito Control",   "Mosquito Control",
                                      12L,                     "Control Zone",   NA_character_,
                                      12L,             "Drainage Improvement",   "Drainage",
                                      11L,                "Metropolitan Park",   "Parks",
                                      11L,                 "Parks Recreation",   "Parks",
                                       8L,                      "Lake School",   "School",
                                       7L,           "Irrigation Improvement",   "Irrigation",
                                       7L,                     "Valley Water",   "Water",
                                       6L,                      "Beach Water",   "Water",
                                       6L,                       "Lake Sewer",   "Sewer",
                                       5L,               "Diking Improvement",   "Dikes",
                                       5L,                 "Medical Services",   "Emergency Medical Services",
                                       4L,                       "Lake Water",   "Water",
                                       4L,             "Television Reception",   "Television Reception",
                                       4L,                "Valley Irrigation",   "Irrigation",
                                       3L,                 "Basin Irrigation",   "Irrigation",
                                       3L,            "Consolidated Drainage",   "Drainage",
                                       3L,              "Drainage Irrigation",   "Irrigation",
                                       3L,                     "Falls School",   "School",
                                       3L,                     "North School",   "School",
                                       3L,                  "Partial Library",   "Library",
                                       3L,                      "Point Water",   "Water",
                                       3L,                  "Public Facility",   "Public Facilities",
                                       3L,                      "Sewer Water",   "Water/Sewer",
                                       3L,                     "TV Reception",   "Television Reception",
                                     391L,                       "Protection",   NA_character_,
                                     294L,                           "School",   "School",
                                     141L,                            "Water",   "Water",
                                     103L,                         "Cemetery",   "Cemetery",
                                      90L,                       "Irrigation",   "Irrigation",
                                      61L,                       "Recreation",   "Parks",
                                      60L,                         "Hospital",   "Hospital",
                                      58L,                            "Sewer",   "Sewer",
                                      49L,                         "Drainage",   "Drainage",
                                      48L,                     "Conservation",   "Conservation",
                                      47L,                          "Benefit",   NA_character_,
                                      34L,                          "Utility",   "Public Utility",
                                      31L,                      "Improvement",   NA_character_,
                                      28L,                          "Library",   "Library",
                                      27L,                          "Control",   NA_character_,
                                      24L,                       "Facilities",    NA_character_,
                                      19L,                             "Dike",   "Dikes",
                                      19L,                           "Diking",   "Dikes",
                                      18L,                             "Fire",   "Fire Protection",
                                      16L,                             "Port",   "Port",
                                      12L,                             "Park",   "Parks",
                                      12L,                             "Zone",   NA_character_,
                                      11L,                           "Health",   "Health",
                                      10L,                             "Weed",   "Weed Control",
                                       7L,                        "Reception",   NA_character_,
                                       6L,                            "Drain",   "Drainage",
                                       5L,                         "Mosquito",   "Mosquito Control",
                                       5L,                      "Reclamation",   NA_character_,
                                       5L,                         "Services",   NA_character_,
                                       3L,                         "Facility",   NA_character_,
                                       3L,                          "Service",   NA_character_,
                                       3L,                       "Wastewater",   "Water/Sewer",
                                       3L,                       "WaterSewer",   "Water/Sewer"
                                     
                                     )
}

district_types <- create_district_types() %>% 
  select(NAME, TYPE)

first_not_na <- function (x) 
{
    if (all(sapply(x, is.na))) {
        as(NA, class(x))
    }
    else {
        x[!sapply(x, is.na)][1]
    }
}




spd_type <- spd_clean_names %>%  
  regex_left_join(district_types, by = c(DISTRICT_NAME_CLEAN = "NAME")) %>% 
  group_by(DISTRICT_NAME) %>% 
  summarise_all(first_not_na ) %>% 
  select(DISTRICT_NAME,
         DISTRICT_NUMBER,
         DISTRICT_NOTE,
         TYPE,
         COUNTY:CHANGE_NOTE) %>% 
  mutate(DISTRICT_NOTE = str_trim(DISTRICT_NOTE))

statuses <- c("disposition unknown",
              "dissolved",
              "merged",
              "consolidated",
              "inactive",
              "annexed",
              "assumed"
              ) %>% str_c(collapse = "|")

spd_status <- spd_type %>%  
  mutate(
    STATUS = case_when(str_detect(tolower(DISTRICT_NOTE), statuses) ~ str_extract(tolower(DISTRICT_NOTE), statuses), TRUE ~ "active"),
    STATUS = case_when(STATUS %in% "assumed" ~ "annexed", TRUE ~ STATUS),
    DISTRICT_NOTE = case_when(str_detect(tolower(DISTRICT_NOTE), statuses) ~ NA_character_, TRUE ~ DISTRICT_NOTE)
  ) %>%  
  transmute(DISTRICT_NAME,
            DISTRICT_NUMBER,
            TYPE,
            STATUS,
            COUNTY,
            COUNTIES_INCLUDED,
            PLACES,
            DISTRICT_NOTE,
            CHANGE_NOTE )  

spd_ready <- spd_status

# WRITE DATA ----

write_csv(spd_ready, here::here("wa-special-purpose-districts/data/wa-special-purpose-districts.csv"))
