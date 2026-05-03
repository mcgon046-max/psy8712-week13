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

## employees tibble creation 
employees_tbl <- tbl(sql_connect, "datascience_employees") |> 
  collect() # Collect in order to make it a tibble for csv output 

### writing "employees" csv into data folder 
employees_tbl |>
  write_csv("data/employees.csv")

## Test scores 
testscores_tbl <- tbl(sql_connect, "datascience_testscores") |>
  collect() # explained above 

### writing "test scores" csv into data
testscores_tbl |>
  write_csv("data/testscores.csv")

## offices tibble download 
offices_tbl <- tbl(sql_connect, "datascience_offices") |>
  collect()

### writing csv for "offices"
offices_tbl |>
  write_csv("data/offices.csv")

## Week13_tbl creation using inner joins 
week13_tbl <- employees_tbl |>
  inner_join(
    testscores_tbl,
    by = "employee_id" # this is the shared row 
    ) |> # Inner join in order to only retain rows where there is a match in both tables 
  inner_join(
    offices_tbl, 
    by = join_by(city == office) # the "city" column in the other tibbles are matches to the "office" column in the offces_tbl 
  )

## Write csv for week13_tbl 
week13_tbl |>
  write_csv("data/week13.csv")

# Analysis 

## Managers 
week13_tbl |>
  filter(manager_hire == "Y")
