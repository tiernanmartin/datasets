# SETUP ----

library(tidytext)  
library(rvest) 
library(tidyverse)

# GET HTML DATA ---- 

abbreviation_page_url <- "https://web.archive.org/web/20180124023738/http://www.seattle.gov/pan/soup.htm"

abbreviation_page_html <- read_html(abbreviation_page_url)

abbreviations <- abbreviation_page_html %>% 
    html_node("#mainContent") %>% 
    html_nodes("ul") %>%   
    html_nodes("li") %>%  
    html_text() %>% 
    {tibble(ACR_ORIG = .)} %>% 
  separate(ACR_ORIG, into = c("ABBREVIATION","DEPT"),sep = " - ") %>% 
  mutate_all(str_trim)


department_page_url <- "http://www.seattle.gov/city-departments-and-agencies"

page_html <- read_html(department_page_url)

depts <- page_html %>% 
  html_nodes(".departmentAgency") %>% 
  html_nodes(".tileTitle") %>% 
  html_text() %>% 
  str_squish() %>% 
  {tibble(DEPT_ORIG = .)} %>% 
  mutate(BEFORE = replace_na(str_extract(DEPT_ORIG,"(?<=,\\s).+"),""),
         AFTER = replace_na(str_replace(DEPT_ORIG,",.+","")),"") %>%  
  transmute(DEPT = str_trim(str_c(BEFORE, AFTER, sep = " "))) %>% 
  arrange(DEPT)

# JOIN DATA ---- 

stops <- c("seattle","city","municipal","office","department",stopwords::stopwords())

stopwords <- tibble(TOKEN = stops) 

depts_join <- depts %>% 
  mutate(TOKEN = DEPT) %>% 
  unnest_tokens(TOKEN, TOKEN, token = "ngrams", n = 1, to_lower = TRUE) %>% 
  anti_join(stopwords) %>% 
  group_by(DEPT) %>%
  summarise(TOKEN = str_c(TOKEN, collapse = " ")) %>% 
  mutate(TOKEN_2 = TOKEN) %>% 
   unnest_tokens(TOKEN_2, TOKEN_2, token = "ngrams", n = 2, to_lower = TRUE) %>% 
  transmute(DEPT, 
            TOKEN = if_else(is.na(TOKEN_2),TOKEN,TOKEN_2))
  

abbreviations_join <- abbreviations %>% 
  mutate(TOKEN = DEPT) %>% 
  unnest_tokens(TOKEN, TOKEN, token = "ngrams", n = 1, to_lower = TRUE) %>% 
  anti_join(stopwords) %>% 
  group_by(DEPT) %>%
  summarise(ABBREVIATION = first(ABBREVIATION),
    TOKEN = str_c(TOKEN, collapse = " ")) %>% 
  mutate(TOKEN_2 = TOKEN) %>% 
   unnest_tokens(TOKEN_2, TOKEN_2, token = "ngrams", n = 2, to_lower = TRUE) %>% 
  transmute(DEPT, 
            ABBREVIATION,
            TOKEN = if_else(is.na(TOKEN_2),TOKEN,TOKEN_2))

depts_abbreviations <- left_join(depts_join, abbreviations_join, by = "TOKEN") %>% 
  arrange(ABBREVIATION) %>% 
  group_by(DEPT.x) %>% 
  slice(1) %>% 
  ungroup %>% 
  arrange(ABBREVIATION) %>% 
  select(DEPT = DEPT.x,
         ABBREVIATION)

# RECODE DATA ---- 

depts_abbreviations_final <- depts_abbreviations %>% 
  mutate(ABBREVIATION = case_when(
    DEPT %in% "Office of Planning and Community Development" ~ "OPCD",
    DEPT %in% "Department of Construction and Inspections" ~ "SDCI",
    DEPT %in% "Department of Education and Early Learning" ~ "DEEL",
    DEPT %in% "Department of Finance and Administrative Services" ~ "FAS",
    DEPT %in% "Office of Arts & Culture" ~ "ARTS",
    DEPT %in% "Office of Film and Music" ~ "OFM",
    DEPT %in% "Office of Immigrant and Refugee Affairs" ~ "OIRA",
    DEPT %in% "Office of Labor Standards" ~ "OLS",
    DEPT %in% "Office of Police Accountability" ~ "OPA",
    DEPT %in% "Office of Waterfront" ~ "OW",
    DEPT %in% "Retirement Office" ~ "SCERS",
    DEPT %in% "Seattle Center" ~ "SC",
    DEPT %in% "Seattle Department of Human Resources" ~ "SDHR",
    DEPT %in% "Seattle Municipal Archives" ~ "SMA",
    DEPT %in% "Seattle Municipal Court" ~ "SMC",
    DEPT %in% "Seattle Parks and Recreation" ~ "SPR", 
    TRUE ~ ABBREVIATION
  )) %>% 
  rename(DEPARTMENT = DEPT) %>% 
  arrange(ABBREVIATION)
 
 
# WRITE DATA ----

write_csv(depts_abbreviations_final, here::here("seattle-bureaucracy/data/seattle-bureaucracy.csv"))
