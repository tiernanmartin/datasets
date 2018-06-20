# SETUP ----
 
library(rvest) 
library(tidyverse)

# GET HTML DATA ---- 

hous_auth_page_url <- "http://www.awha.org/contact.html"

hous_auth_page_html <- read_html(hous_auth_page_url)

hous_auth_items <- hous_auth_page_html %>% 
  html_nodes("li") 

get_names <- function(x){
  x %>% 
    html_nodes(".hainfo") %>% 
    html_text() %>% 
    str_trim("both") %>% 
    str_extract(".+?(?=\\n|,)")
  
}

get_counties_served <- function(x){
  x %>% 
    html_nodes(".hanums") %>% 
    html_text() %>%  
    str_extract("(?<=Serving\\sCounties:\\s).+?(?=Phone)") %>% 
    str_replace("and",",")
  
}


hous_auth_names <- tibble(NAME = get_names(hous_auth_items),
                          COUNTIES_SERVED = get_counties_served(hous_auth_items))

# WRITE DATA ----

write_csv(hous_auth_names, here::here("wa-housing-authorities/data/wa-housing-authorities.csv"))
