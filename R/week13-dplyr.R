# Script Settings and Resources 
library(tidyverse)
library(DBI)
library(RPostgres)

# Data Import and Cleaning 

## Credentials (needed so username and password are not displayed when committing)
NEON_USER <- Sys.getenv("NEON_USER")
NEON_PW <- Sys.getenv("NEON_PW")

## Connecting to SQL server 
sql_connect <- dbConnect(
  
)
  