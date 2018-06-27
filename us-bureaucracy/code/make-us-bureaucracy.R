# SETUP ----

library(tidytext)  
library(rvest) 
library(tidyverse)

# GET HTML DATA ---- 

dept_page_url <- "https://www.usa.gov/executive-departments"

ind_agency_page_url <- "https://www.usa.gov/independent-agencies"

dept_page_html <- read_html(dept_page_url)

ind_agency_page_html <- read_html(ind_agency_page_url)

dept_names <- dept_page_html %>%  
    html_nodes("span.field-content") %>% 
  html_nodes("a") %>% 
  html_text()

ind_agency_names <- ind_agency_page_html %>%  
    html_nodes("span.field-content") %>% 
  html_nodes("a") %>% 
  html_text()

dept_urls <- dept_page_html %>%  
    html_nodes("span.field-content") %>% 
  html_nodes("a") %>% 
  html_attr("href") %>% 
  map_chr(~str_c("https://www.usa.gov",.x,sep = "")) 

ind_agency_urls <- ind_agency_page_html %>%  
    html_nodes("span.field-content") %>% 
  html_nodes("a") %>% 
  html_attr("href") %>% 
  map_chr(~str_c("https://www.usa.gov",.x,sep = "")) 


get_abbr <- function(x){
  
  table_text <- read_html(x) %>% 
  html_nodes("section.otln") %>% 
  html_text

if(any(str_detect(table_text,"Acronym"))){
  acronym <- table_text %>% 
    purrr::keep(.p = ~ str_detect(.x, "Acronym")) %>% 
    str_squish() %>% 
    str_extract("(?<=Acronym:\\s).+")
  return(acronym)
}else{return(NA_character_)}
}

us_dept_abbr <- tibble(DEPT = c(dept_names,ind_agency_names),
                       URL = c(dept_urls,ind_agency_urls)
                       ) %>% 
  transmute(DEPT,
            ABBR = map_chr(URL, get_abbr)) %>% 
  mutate(ABBR = case_when(
    str_detect(DEPT, "Treasury") ~ "USDT",
    TRUE ~ ABBR
  )) %>% 
  rename(DEPARTMENT = DEPT,
         ABBREVIATION = ABBR)
 
# WRITE DATA ----

write_csv(us_dept_abbr, here::here("us-bureaucracy/data/us-bureaucracy.csv"))
