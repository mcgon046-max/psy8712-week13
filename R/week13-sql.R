# Script Settings and Resources 
# library(tidyverse) don't need tidyverse because we're not using any dplyr calls
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

### Reused code from Dplyr R file!

# Analysis 

## 1. Managers total 
dbGetQuery(sql_connect, "
  SELECT COUNT(*) AS total_managers 
  FROM datascience_employees e
  INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id;
")  # SELECT to to tell the database what to data to return, COUNT(*) counts all the rows, FROM to choose the table, INNER JOIN to make sure that all rows have test scores, "e." and "t." are table aliases  

### Output: 
# total_managers
# 1            549

## 2. Unique managers 
dbGetQuery(sql_connect, "
  SELECT COUNT(DISTINCT e.employee_id) AS unique_managers
  FROM datascience_employees e
  INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id;
") # Distinct in here to remove duplicate IDS

### Output: 
# unique_managers
# 1             549

## 3. Managers not originally hired as such, grouped by location 
dbGetQuery(sql_connect, "
  SELECT e.city, COUNT(*) AS manager_count
  FROM datascience_employees e
  INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
  WHERE e.manager_hire = 'N'
  GROUP BY e.city;
") # selects based on city, FROM the datascience employee table, WHERE the managers are not hired as such, GROUPed BY city. 

### Output: 
# city manager_count
# 1       Houston            20
# 2       Orlando            20
# 3       Toronto           189
# 4 San Francisco            48
# 5       Chicago            61
# 6      New York           183

