library(httr)
library(rvest)
library(tibble)
library(dplyr)
library(glue)
library(stringr)
#library(arrow)
library(readr)
library(purrr)
reports_ids <- seq(1,100) # generate report ids e.g. https://www.rlwc2021.com/report/4

get_match_report <- function(id)
{
  return( read_html(paste0("http://www.rlwc2021.com/report/",id)))
  
}

all_pages <- map(reports_ids,get_match_report) # get all HTML PAGEs locally

all_pages %>% 
  discard(function(page) isTRUE(rvest::html_nodes(page,'h1') %>% html_text() == "404 Not found")) -> pages # keep only valid match reports


download_image_players <- function (image_url, folder = "C:\\WIP\\Personal\\web2\\MyYearInData\\images\\players\\")
{
  small_image_url <- image_url
  large_image_url <- str_replace(image_url,"150px","500px")
  large_image_url
  tryCatch(download.file(image_url,paste0(folder,str_replace(str_split_fixed(image_url,"/",6)[6],'/','-')),mode = "wb"),error = function(e) {})
  tryCatch(download.file(large_image_url,paste0(folder,str_replace(str_split_fixed(large_image_url,"/",6)[6],'/','-')),mode = "wb"),error = function(e) {})
}
#get player images
pages %>% 
  map (function(scrapping_page)
    append(
      scrapping_page %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="home"]/div/table') %>% html_elements("img") %>% html_attr('data-src'),
      scrapping_page %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="home"]/div/table') %>% html_elements("img") %>% html_attr('data-src'))
  ) %>% 
  flatten() %>% 
  unique() %>% 
  map(download_image_players)
     

# Download Team Image

download_image_team <- function (image_url, folder = "C:\\WIP\\Personal\\web2\\MyYearInData\\images\\teams\\")
{
  download.file(paste0("https://www.rlwc2021.com/",image_url),paste0(folder,str_split_fixed(image_url,"/",6)[6],'/'),mode = "wb")
}


pages %>% 
  map(function (p) 
    union(
        p %>% 
        html_node('.player-stats') %>% 
        html_node(xpath = '//*[@id="home"]/div/table') %>%
        html_table() %>%
        add_column(
          player_img = p %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="home"]/div/table') %>% html_elements("img") %>% html_attr('data-src'),
          game = p %>% rvest::html_nodes('.design-2') %>% html_node('.mb-2') %>%   html_text() %>% str_replace_all( "[[:punct:]]", ""), 
        #  referee = official,
          date = p %>% html_node('.mb-2+ .d-block') %>% html_text2(),
          team = p %>% html_node('.home') %>% html_text() %>% str_trim()
        ),
        p %>% 
          html_node('.player-stats') %>% 
          html_node(xpath = '//*[@id="away"]/div/table') %>%
          html_table() %>%
          add_column(
            player_img = p %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="away"]/div/table') %>% html_elements("img") %>% html_attr('data-src'),
            game = p %>% rvest::html_nodes('.design-2') %>% html_node('.mb-2') %>%   html_text() %>% str_replace_all( "[[:punct:]]", ""), 
            #  referee = official,
            date = p %>% html_node('.mb-2+ .d-block') %>% html_text2(),
            team = p %>% html_node('.away') %>% html_text() %>% str_trim()
          ) 
    
      ) %>%
      select(!"Player...1") %>% 
      rename("Player" = "Player...2" )
  ) %>%
  map(function(csv) 
    
    write_csv(csv, file = paste0("C:\\WIP\\Personal\\web2\\MyYearInData\\", str_trim(unique(csv$game)),str_trim(unique(csv$team)[1]),'-',str_trim(unique(csv$team)[2]),'.csv') ) 
    
    )
  
