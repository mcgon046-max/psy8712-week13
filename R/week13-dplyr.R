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

## 1: Managers 
week13_tbl |>
  count()

### Output: 549
#### NOTE: I originally filtered for those who were hired as managers, but after thinking about it, it seems that this entire data set is of managers, thus, every row is a manager. 


## 2: Unique Managers 
week13_tbl |>
  distinct(employee_id) |> # Distinct is a function that deletes duplicate rows, in this case based on employee ID
  count()

### Output: 549, seems that there weren't duplicatesn 

## 3. Managers not originally hired as such, grouped by location 
week13_tbl |>
  filter(manager_hire == "N") |> # Filtering on those who were not hired as managers
  group_by(city) |> # Groups by location, in this case city 
  count() # Gives counts 

### Output: 
# Groups:   city [6]
# city              n
# <chr>         <int>
#   1 Chicago          61
# 2 Houston          20
# 3 New York        183
# 4 Orlando          20
# 5 San Francisco    48
# 6 Toronto         189

## 4. mean and sd of number of years split by performance level 
week13_tbl |>
  mutate(
    factor(
      performance_group, 
      levels = c("Bottom", "Middle", "Top")
      ) # Turns this variable into a factor to group the further analysis 
  ) |>
  group_by(performance_group) |> # actually groups everything 
  summarize(
    mean_years = mean(yrs_employed), # mean call to get the average years
    sd_years = sd(yrs_employed) # sd call for standard deviation 
  ) # Summarize here to output a nice tibble with these variables defined 
  
### Output: 
# A tibble: 3 × 3
# performance_group mean_years sd_years
# <chr>                  <dbl>    <dbl>
# 1 Bottom                  4.74    0.537
# 2 Middle                  4.58    0.509
# 3 Top                     4.33    0.604

## 5. Location classification of managers, Id, Test, alphabetical order by location type
week13_tbl |>
  select(
    employee_id, 
    office_type, 
    test_score
  ) |> # selects the relevant variables
  arrange(office_type, desc(test_score))  # Arranges office type alphabetically (suburban on top), and tests in descending order by score. 


  