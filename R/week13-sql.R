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

## 4. mean and sd of number of years split by performance level 

dbGetQuery(sql_connect, "
  SELECT e.performance_group, 
         AVG(e.yrs_employed) AS mean_years, 
         STDDEV(e.yrs_employed) AS sd_years
  FROM datascience_employees e
  INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
  GROUP BY e.performance_group
  ORDER BY CASE e.performance_group 
             WHEN 'Bottom' THEN 1 
             WHEN 'Middle' THEN 2 
             WHEN 'Top' THEN 3 
           END;
") # AVG and STDDEV are the SQL built in functions for mean and stadard deviation, GROUPs BY the performance group and numerated, the ORDER BY CASE is used to sort the output by the Bottm, middle, and top in that order. 

### Output:
# performance_group mean_years  sd_years
# 1            Bottom   4.742063 0.5370070
# 2            Middle   4.580609 0.5089866
# 3               Top   4.325806 0.6037955


## 5. Location classification of managers, Id, Test, alphabetical order by location type
dbGetQuery(sql_connect, "
  SELECT o.office_type, e.employee_id, t.test_score
  FROM datascience_employees e
  INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
  INNER JOIN datascience_offices o ON e.city = o.office
  ORDER BY o.office_type ASC, t.test_score DESC;
") # SELECTs the relevant columns FROM the right table, JOINS based on employee ID and city, ORDERs it all BY suburban (alphabetical) and sorts scores by Descending order. 