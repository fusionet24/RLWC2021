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
  map (function(page)
    append(
      page %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="home"]/div/table') %>% html_elements("img") %>% html_attr('data-src'),
      page %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="home"]/div/table') %>% html_elements("img") %>% html_attr('data-src'))
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
  map(function (page) 
    union(
        page %>% 
        html_node('.player-stats') %>% 
        html_node(xpath = '//*[@id="home"]/div/table') %>%
        html_table() %>%
        add_column(
          player_img = page %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="home"]/div/table') %>% html_elements("img") %>% html_attr('data-src'),
          game = page %>% rvest::html_nodes('.design-2') %>% html_node('.mb-2') %>%   html_text() %>% str_replace_all( "[[:punct:]]", ""), 
        #  referee = official,
          date = page %>% html_node('.mb-2+ .d-block') %>% html_text2(),
          team = page %>% html_node('.home') %>% html_text() %>% str_trim()
        ),
        page %>% 
          html_node('.player-stats') %>% 
          html_node(xpath = '//*[@id="away"]/div/table') %>%
          html_table() %>%
          add_column(
            player_img = page %>% html_node('.player-stats') %>%  html_node(xpath = '//*[@id="away"]/div/table') %>% html_elements("img") %>% html_attr('data-src'),
            game = page %>% rvest::html_nodes('.design-2') %>% html_node('.mb-2') %>%   html_text() %>% str_replace_all( "[[:punct:]]", ""), 
            #  referee = official,
            date = page %>% html_node('.mb-2+ .d-block') %>% html_text2(),
            team = page %>% html_node('.away') %>% html_text() %>% str_trim()
          ) 
    
      ) %>%
      select(!"Player...1") %>% 
      rename("Player" = "Player...2" )
  ) %>%
  map(function(csv) 
    
    write_csv(csv, file = paste0("C:\\WIP\\Personal\\web2\\MyYearInData\\data\\player stats\\", str_trim(unique(csv$game)),str_trim(unique(csv$team)[1]),'-',str_trim(unique(csv$team)[2]),'.csv') ) 
    
    )
  


#team stats
## This could be much neater, to much repative code but meh it's a one time thing!

#meters gained
pages %>% 
  map(function(page)
  union(
  tibble_row(
    team = page %>% html_node('.home') %>% html_text() %>% str_trim(),
    meters_gained = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(1) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Passes = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(2) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Possession = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div.data-container > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Completed_Sets = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(4) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Offloads = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(5) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Errors =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(6) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Incomplete_Sets =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(7) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Penalties_Conceded =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(7) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text(),
    Goals_Missed =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(8) > div.stats-holder") %>% 
      html_node('div.home-stat')%>%
      html_text()
    
  ),
  
  tibble_row(
    team = page %>% html_node('.away') %>% html_text() %>% str_trim(),
    meters_gained = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(1) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Passes = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(2) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Possession = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div.data-container > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Completed_Sets = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(4) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Offloads = page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(5) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Errors =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(6) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Incomplete_Sets =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(7) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Penalties_Conceded =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(7) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text(),
    Goals_Missed =  page %>% 
      html_node('#team-stat > div > div > div') %>% 
      html_nodes("div:nth-child(8) > div.stats-holder") %>% 
      html_node('div.away-stat')%>%
      html_text()
    
  )
  
  )
)



page %>% 
  html_node(xpath = '//*[@id="lineup"]') %>%
  html_node(xpath = '//*[@id="matchreport-lineup"]/div') %>%  
  html_nodes('.name-holder') %>% html_text2()

page %>% 
  html_node(xpath = '//*[@id="lineup"]') %>%
  html_node(xpath = '//*[@id="matchreport-lineup"]/div') %>%  
  html_nodes('.shirt-num.mr-2') %>% html_text2()

page %>% 
  html_node(xpath = '//*[@id="lineup"]') %>%
  html_node(xpath = '//*[@id="matchreport-lineup"]/div') %>%  
  html_nodes('.col-6.col-sm-6.col-md-6.home') %>%  html_nodes('li') %>% html_text2()


#get commentary images
page %>% 
  html_node('#commentary > div > div > div') %>% 
  html_nodes("div.col-6.col-md-3.image > div > img") %>% 
  html_attr('data-src')


page %>% 
  html_node('#commentary > div > div > div') -> commentary_page

# comentary events
commentary_page %>% 
  html_nodes("div.col-6.col-md-5.time.align-items-center > p.mins.mb-1 ") %>% 
  html_elements('span') %>% html_text()

#event details
commentary_page %>% 
  html_nodes("div.col-12.col-md-4.detail > div ") %>% 
  html_elements('p') %>% html_text()

#current score during events

commentary_page %>% 
  html_nodes("div.col-6.col-md-5.time.align-items-center > p:nth-child(3)") %>% html_text()


