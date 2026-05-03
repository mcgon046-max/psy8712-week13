# Script Settings and Resources 
library(tidyverse)
library(DBI)
library(RPostgres)

# Data Import and Cleaning 

## Credentials (needed so username and password are not displayed when committing)
NEON_USER <- Sys.getenv("NEON_USER")
NEON_PW <- Sys.getenv("NEON_PW")

## Connecting to SQL server (PostgreSQL database)
sql_connect <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = "neondb", # Database name
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech", # Host from string in assignment 
  port = 5432, # port from string in assignment 
  user = NEON_USER, # Defined above
  password = NEON_PW, # defined above 
  sslmode = "require" # Requires SSL 
)

## Found correct tables from "dbListTables()
# [1] "datascience_employees"  "datascience_offices"   
# [3] "datascience_testscores" "participant_scores" 

## employees
employees_tbl <- tbl(sql_connect, "datascience_employees") |> 
  collect() # Collect in order to make it a tibble for csv output 

### writing "employees" csv into data folder 
employees_tbl |>
  write_csv("data/employees.csv")

## Test scores 
testscores_tbl <- tbl(sql_connect, "datascience_testscores") |>
  collect() # explained above 

### writing csv into data
testscores_tbl |>
  write_csv("data/testscores.csv")


