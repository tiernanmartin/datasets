# SETUP ----

library(snakecase) 
library(operator.tools)
library(tictoc)
library(rvest) 
library(tidyverse)

# GET HTML DATA ---- 

base_url <- "http://directory.kingcounty.gov/"

group_search_url <- "http://directory.kingcounty.gov/GroupSearch.asp"

dept_hrefs <- group_search_url %>% 
  read_html() %>% 
  html_node("#tblMain table") %>% 
  xml_child(3) %>%  
  xml_child(1) %>% 
  xml_child(1) %>% 
  xml_child(1) %>% 
  xml_child(1) %>% 
  xml_child(2) %>% 
  xml_child(2) %>% 
  xml_child(1) %>% 
  html_nodes("a") %>% 
  html_attr('href') 

dept_urls <- str_c(base_url, dept_hrefs)

dept_ids <- str_extract(dept_urls, "(?<==)\\d+")

# CREAT SCRAPING FUNCTIONS ----

# Funs for collecting the urls

get_url_subs <- function(url){  
  
  page_html <- read_html(url)
  
  table_names <- page_html %>%  
    html_nodes("p.titlecell") %>% 
    html_nodes("a") %>% 
    html_attrs()  
    
  if("groups" %!in% table_names){return(character(0))}
  
  urls <- page_html %>% 
    html_node("body") %>% 
    html_nodes("table") %>%  
    pluck(6) %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    purrr::keep(~str_detect(.x,"GroupDetail")) %>% 
    {str_c(base_url,.)}
  
  return(urls)
  
} 

get_all_urls <- function(dept_urls){
  
  # browser()
  
  sub_urls <- NA_character_

  target_urls <- dept_urls

while(length(target_urls) > 0){
  
  new_urls <- target_urls %>%  
    map(get_url_subs) %>%  
    flatten_chr() %>% 
    discard(~ .x %in% sub_urls)
  
  sub_urls <- c(sub_urls, new_urls) %>% 
    discard(is.na)
  
  target_urls <- new_urls
}

  all_urls <- c(dept_urls, sub_urls)
  
return(all_urls)

}


# Funs for creating the table

get_url_table <- function(target_url){
  target_url %>% 
    read_html() %>% 
    html_nodes("table") %>% 
    pluck(3) 
  }

get_url_col <- function(url_table, col = "name"){
  
  cols <- c("name" = 3, 
            "desc" = 4,
            "parent" = 5)
  
  url_table %>% 
    xml_child(cols[col]) %>% 
    xml_child(2) %>% 
    html_node("font") %>% 
    html_text() %>%  
    str_trim("both")
    
}

get_parent_url <- safely(function(target_url){
  
  url <- target_url %>% 
      read_html() %>% 
      html_nodes("table") %>% 
      pluck(3) %>% 
      xml_child(5) %>% 
      xml_child(2) %>% 
      html_node("font") %>% 
      html_nodes("a") %>% 
      html_attr('href') 
  
  return(url)
  
})

get_dept_table <- function(target_url, hrefs = dept_hrefs){ 
  
  url_table <- get_url_table(target_url)
  
  href <- str_remove(target_url, base_url)
  
  url_depth <- 1 
  
  while(href %!in% dept_hrefs){
    
    href <- get_parent_url(target_url) %>% pluck("result") 
     
    if(is.null(href)){break}
    
    url_depth <- url_depth + 1 
    
    target_url <- str_c(base_url, href) 
    
  }
  
  tbl <- tibble(
    NAME = get_url_col(url_table, "name"),
    DESCRIPTION = get_url_col(url_table, "desc"),
    PARENT = get_url_col(url_table, "parent"),
    DEPTH = url_depth
  )
  
}


# GET DATA ----

all_urls <- get_all_urls(dept_urls) %>% 
  unique() %>%  # DADJ has two parents: Operations and Superio Court
  discard(~ !str_detect(.x,"GroupDetail"))  # get rid of the url with only the base_url

# ~8 min. operation
dept_tbl <- map_dfr(all_urls, get_dept_table, hrefs = dept_hrefs)

# CLEAN DATA ----

# acronym patterns (for testing)

caps_bs_parens <- "DNRP/SWD - Enterprise Services (ES)" 
caps_none_parens <- "PAO - Family Support Division (FSD)"
caps_none_none <- "ELECTIONS - Technical Services"
caps_bs_none <- "DNRP/WTD/PPD/ETR - Mechanical Engineering & Technical Staff"
none_none_none <- "The Electorate of King County"

pattern_paren <- "(?<=\\()[[:upper:]]{2,}"
pattern_abbr <- "[[:upper:]]{2,}(?=\\s-)|(?<=/)[[:upper:]]{2,}|[[:upper:]]{2,}(?=/)|(?<=\\()[[:upper:]]{2,}"

str_extract_abbr <- function(x, paren = pattern_paren, abbr = pattern_abbr){ 
  
  # browser()
  
  new_string <- str_extract_all(string = x, pattern = abbr) %>% 
      flatten_chr() %>% 
      str_c(collapse = " ") %>% 
      toupper()
  
  if(!str_detect(string = x, pattern = paren)){
    NA_character_}else if(length(new_string) ==0){
      NA_character_} else {
        new_string
        }
  
  
}

get_dept <- function(name, parent, depth, df){  
  while(depth > 1){
    
    new_row <- df %>% 
      filter(NAME %in% parent)
    
    name <- pluck(new_row, "NAME")
    
    parent <- pluck(new_row, "PARENT")
    
    depth <- pluck(new_row, "DEPTH") 
  }
  
  return(name)
}
  
  official_names_kc <- names_kc_load %>%  
  mutate(DF = list(.),
         DEPARTMENT = pmap_chr(list(name = NAME,parent = PARENT,depth = DEPTH, df = DF), get_dept)) %>% 
    select(-DF) 

  
dept_tbl_ready <- dept_tbl %>%  
  transmute(NAME = str_trim(NAME, "both"),
            ABBREVIATION = map_chr(NAME, str_extract_abbr),
            DESCRIPTION,
            PARENT,
            DEPTH
            ) %>%
   mutate(DF = list(.),
         DEPARTMENT = pmap_chr(list(name = NAME,parent = PARENT,depth = DEPTH, df = DF), get_dept)) %>% 
    select(-DF) 

# WRITE DATA ----

write_csv(dept_tbl_ready,here::here("king-county-bureaucracy/data/kc-bureaucracy.csv"))


