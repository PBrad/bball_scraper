##############
# Main
##############

# Other resources:
# https://rdrr.io/github/jflancer/bigballR/man/get_team_roster.html

# https://github.com/lbenz730/ncaahoopR

# Runs the collection and analysis scripts in
# succession.

# Packages ----------------------------------------------------------------

PACKAGES <- c("rvest", "tidyverse", "beepr")

for(pkg in PACKAGES){
  library(pkg, character.only = TRUE)
}

# Scrape ------------------------------------------------------------------

# Don't run unless you want to re-scrape
# source("scripts/1 - scrape.R")
