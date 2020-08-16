##############
# Scrape Test
##############

# Scraping college basketball rosters from sidearm (format) sites.
# All reviewed robots.txt files appear to allow this, specifying a 
# 30 second crawl delay

# I'm also using the SelectorGadget tool to identify html nodes, attributes, etc.
# https://selectorgadget.com/

# Setup -------------------------------------------------------------------

library(rvest)
library(tidyverse)
library(stringr)

# Get links ---------------------------------------------------------------

# Specify the team name
team_nm <- "Richmond University"

# Specify the url of the site you want to scrape
url <- "https://richmondspiders.com/sports/mens-basketball/roster"
partial_url <- gsub("sports/(.*)", "", url)

# Read the html from the site
site <- read_html(url)

# Make a list of all the links on the site
link_list <- site %>% 
  html_nodes("a") %>% # according to selector gadget
  html_attr("href")

length(link_list) # 310 links - lots of duplicates and not all player/coaches

# de-dup
link_list <- unique(link_list)

player_links <- link_list[grepl("roster/", link_list, fixed = TRUE)]
player_links <- player_links[!grepl('coaches|staff', player_links)]

coach_links <- link_list[grepl("roster/", link_list, fixed = TRUE)]
coach_links <- coach_links[grepl('coaches|staff', coach_links)]

# Scrape ------------------------------------------------------------------

# Loop and scrape players
df_results <- tibble()

for (link in player_links){
  
  print(link)
  
  url <- paste0(partial_url, link)
  
  # Read the html from the site
  site <- read_html(url)
  
  # This seems to pick up more of the player's info - use this
  tmp_bio <- site %>% 
    html_nodes(".pad") %>% 
    html_text() %>% 
    paste(collapse = ' ')
  
  # Position / height / weight / class / etc.
  tmp_char <- site %>% 
    html_nodes(".sidearm-roster-player-header-details") %>% 
    html_text() %>% 
    paste(collapse = ' ')
  
  # Name
  tmp_name <- site %>% 
    html_nodes(".sidearm-roster-player-name") %>% 
    html_text() %>% 
    paste(collapse = ' ')
  
  tmp_df <- tribble(
    ~name,       ~header,          ~bio,      ~link,
    tmp_name[1], tmp_char[1],      tmp_bio[1], url
  )
  
  df_results <- bind_rows(df_results, tmp_df)
  
  Sys.sleep(31) # play nicely
  
}

# Loop and scrape coaches
for (link in coach_links){
  
  print(link)
  
  url <- paste0(partial_url, link)
  
  # Read the html from the site
  site <- read_html(url)
  
  # This seems to pick up more of the coach's info - use this
  tmp_bio <- site %>% 
    html_nodes("p") %>% 
    html_text() %>% 
    paste(collapse = ' ')
  
  if(tmp_bio == ""){
    
    tmp_bio <- site %>% 
      html_nodes(".sidearm-common-bio-full") %>% 
      html_text() %>% 
      paste(collapse = ' ')
    
  }
  
  # Position / height / weight / class / etc.
  tmp_char <- site %>% 
    html_nodes(".sidearm-common-bio-details") %>% 
    html_text() %>% 
    paste(collapse = ' ')
  
  # Name
  tmp_name <- site %>% 
    html_nodes(".sidearm-common-bio-name") %>% 
    html_text() %>% 
    paste(collapse = ' ')
  
  tmp_df <- tribble(
    ~name,       ~header,          ~bio,      ~link,
    tmp_name[1], tmp_char[1],      tmp_bio[1], url
  )
  
  df_results <- bind_rows(df_results, tmp_df)
  
  Sys.sleep(31) # play nicely
  
}


# Cleanup -----------------------------------------------------------------

df_results <- df_results %>% 
  mutate_all(str_squish) %>% 
  mutate(type = ifelse(grepl("coach", link), "coach", "player")) %>%
  mutate(type = ifelse(grepl("staff", link), "staff", type)) %>% 
  mutate(team = team_nm)

# Reorder
df_results <- df_results %>% 
  select(team, type, everything())

# Save --------------------------------------------------------------------

# Write to disk
write_csv(df_results, paste0("working/", team_nm, " roster.csv"))
