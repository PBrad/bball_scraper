# Setup -------------------------------------------------------------------

library(dplyr)
library(stringr)
library(readr)

# Compile -----------------------------------------------------------------

df = tibble()

file_list <- list.files('working')

for (file_nm in file_list){
  
  tmp_df <- read_csv(paste0('working/', file_nm))
  
  df = bind_rows(df, tmp_df)
  
}

# Inspect -----------------------------------------------------------------

head(df)
str(df)

count(df, team)
count(df, name)
count(df, header)
count(df, bio)

# Clean bio ---------------------------------------------------------------

count(df, bio)
View(df)

# Different patterns for different schools - will require conditional cleaning
df <- df %>% 
  mutate(bio_clean = 
           gsub("(.*)window\\.sidearmComponents\\.push\\(obj\\)\\;", "", bio)) 

df %>% 
  mutate(bio_clean = 
           gsub("There is no related content available(.*)", "", bio)) %>% 
  View()

df %>% 
  filter(name == "Jacob Gilyard 2017-18Freshman 2018-19Sophomore 2019-20Junior 2020-21Senior") %>% 
  select("bio")



