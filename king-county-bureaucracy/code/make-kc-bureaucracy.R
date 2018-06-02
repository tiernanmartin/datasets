# SETUP ----
library(snakecase)
library(drake)
library(googlesheets)
library(googledrive)
library(tidyverse)

# HELPER FUNCTIONS ----

drive_get_datetime_modified <- function(dr_id_string){
  
  dr_id <- as_id(dr_id_string)
  
  datetime_modified <- dr_id %>% 
    drive_get %>% 
    mutate(modified = lubridate::as_datetime(map_chr(drive_resource, "modifiedTime"))) %>% 
    pull
  
  return(datetime_modified)
}


# COMMANDS ----

make_drive_id_string <- function(){
  id <- "1rjsPCbt98B4WJVuGITYBH32OUkkEAaNN8YyWU_Hipp4"
  
  return(id)
}

make_kc_bureaucracy_socrata <- function(...){
  
  url <- "https://data.kingcounty.gov/resource/es38-6nrz.csv"
  
  kc_bureaucracy_socrata <- read_csv(url) %>% 
    rename_all(to_screaming_snake_case) %>% 
    mutate_all(funs(iconv(.,'utf-8', 'ascii', sub='')))
  
  return(kc_bureaucracy_socrata)
}

upload_kc_bureaucracy_google_drive <- function(drive_id_string, trigger_kc_bureaucracy_google_drive, kc_bureaucracy_socrata){
  
  sheet_key <- as_id(drive_id_string)
  
  kc_bureaucracy_ss <- gs_key(sheet_key, lookup = NULL, visibility = NULL, verbose = TRUE)

  gs_edit_cells(kc_bureaucracy_ss, 
              ws = "UPLOAD_TARGET", 
              input = kc_bureaucracy_socrata, 
              anchor = "A1", 
              byrow = FALSE,
              col_names = TRUE, 
              trim = FALSE, 
              verbose = TRUE) 
  
  return(kc_bureaucracy_ss)
}

make_kc_bureaucracy <- function(trigger_kc_bureaucracy_google_drive, kc_bureaucracy_drive){
  
  trigger <- trigger_kc_bureaucracy_google_drive
  
  kc_bureaucracy_drive_edited <- gs_read(kc_bureaucracy_drive, ws = "EDITING_COPY")
  
  kc_bureaucracy <- kc_bureaucracy_drive_edited
  
  return(kc_bureaucracy)
  
}

# PLANS ----

kc_bureaucracy_plan <- drake_plan(
  drive_id_string = make_drive_id_string(),
  trigger_kc_bureaucracy_google_drive = drive_get_datetime_modified(drive_id_string),
  kc_bureaucracy_socrata = make_kc_bureaucracy_socrata(),
  kc_bureaucracy_drive = upload_kc_bureaucracy_google_drive(drive_id_string, trigger_kc_bureaucracy_google_drive, kc_bureaucracy_socrata),
  kc_bureaucracy = make_kc_bureaucracy(trigger_kc_bureaucracy_google_drive, kc_bureaucracy_drive),
  strings_in_dots = "literals"
) %>% 
  mutate(trigger = if_else(str_detect(target, "trigger"),
                           "always",
                           drake::default_trigger()))


# MAKE PLANS ----

make(kc_bureaucracy_plan)
