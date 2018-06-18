# SETUP ----

library(tidytext)  
library(rvest) 
library(tidyverse)

# GET HTML DATA ---- 

usa_page_url <- "https://www.usa.gov/executive-departments"

abbreviation_page_html <- read_html(usa_page_url)

dept_names <- abbreviation_page_html %>%  
    html_nodes("span.field-content") %>% 
  html_nodes("a") %>% 
  html_text()

dept_urls <- abbreviation_page_html %>%  
    html_nodes("span.field-content") %>% 
  html_nodes("a") %>% 
  html_attr("href") %>% 
  map_chr(~str_c("https://www.usa.gov",.x,sep = "")) 

get_abbr <- function(x){
  
  abbr <-  x %>% 
  read_html() %>% 
  html_nodes("section.otln") %>% 
  pluck(1) %>% 
  html_node("p") %>% 
  html_text()
}

us_dept_abbr <- tibble(DEPT = dept_names,
                       URL = dept_urls) %>% 
  transmute(DEPT,
            ABBR = map_chr(URL, get_abbr)) %>% 
  mutate(ABBR = case_when(
    str_detect(DEPT, "Treasury") ~ "USDT",
    TRUE ~ ABBR
  ))

 
# WRITE DATA ----

write_csv(us_dept_abbr, here::here("us-bureaucracy/data/us-bureaucracy.csv"))
