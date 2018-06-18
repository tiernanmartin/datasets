# SETUP ----

library(tidytext)  
library(rvest) 
library(tidyverse)

# GET HTML DATA ---- 

tribes_page_url <- "http://www.washingtontribes.org/tribes-map"

tribes_page_html <- read_html(tribes_page_url)

tribes_names <- tribes_page_html %>% 
  html_nodes("span.map-point") %>% 
  html_attr("data-tribe") %>% 
  {tibble(NAME = .)}

 
# WRITE DATA ----

write_csv(tribes_names, here::here("wa-tribes/data/wa-tribes.csv"))
