# This script is used to make functions that can be used in other scripts that need to have specific cleaning for
# different types of visualization.

library(tidyverse)
library(janitor)

# Declaring variables -----------------------------------------------------

#URL's to the john hopkinds GitHub
url_to_covidgithub_cases <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
url_to_covidgithub_deaths <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"

#read_csv's the files in data
time_data <- read_csv(url_to_covidgithub_cases)
state_order <- read_csv(here::here("data", "raw", "state_order.csv"))
pop_data <- read_csv(here::here("data", "raw", "state_population_data.csv"))
election_data <- read_csv(here::here("data", "raw", "pdf_covid_data_election.csv"))
county_pop_data <- read_csv(here::here("data","raw","county_population_data.csv"))




# Functions ---------------------------------------------------------------

#The functions to get the data and semi-clean them

# get function to get the case data from github and clean it up
get_covid_cases <- function() {
  cases_data <- read_csv(url_to_covidgithub_cases)
  
  cases_data %>%
    clean_names() %>%
    filter(country_region == "US") %>% #Filters only US
    select(province_state, x1_22_20:ncol(time_data)) %>% #Selects the day columns
    rename(state = province_state) %>% # changes name
    filter( #This gets rid of all the random variables found in the dataset from Github
      !state %in% c(
        "American Samoa",
        "Guam",
        "Northern Mariana Islands",
        "Puerto Rico",
        "Virgin Islands",
        "Diamond Princess",
        "Grand Princess",
        "Veteran Hospitals",
        "Federal Bureau of Prisons",
        "US Military"
      )
    )
  
  return(cases_data)
  
}

# get function to get the death data from github and clean it up
get_covid_deaths <- function() {
  cases_data <- read_csv(url_to_covidgithub_deaths)
  
  cases_data %>%
    clean_names() %>%
    filter(country_region == "US") %>% #Filters only US
    select(province_state, x1_22_20:ncol(time_data)) %>% #Selects the day columns
    rename(state = province_state) %>% # changes name
    filter( #This gets rid of all the random variables found in the dataset from Github
      !state %in% c(
        "American Samoa",
        "Guam",
        "Northern Mariana Islands",
        "Puerto Rico",
        "Virgin Islands",
        "Diamond Princess",
        "Grand Princess",
        "Veteran Hospitals",
        "Federal Bureau of Prisons",
        "US Military"
      )
    )
  
  return(cases_data)
  
}

get_pop_data <- function(){
  
  #cleans pop_data
  pop_data_c <- pop_data %>% clean_names()
  
  #cleans the county data
  county_pop_data_c <- 
    county_pop_data %>%  
    clean_names() %>% 
    select(stname,ctyname,popestimate2019) %>% 
    rename(state = stname) %>% 
    rename(county = ctyname) %>% 
    rename(county_population = popestimate2019) %>% 
    mutate(county = str_remove(county, " County")) %>% 
    filter(!county == state) #removes the duplicate state row
  
  #left_joins by state and selects only interesting ones
  combined_data <-
    pop_data_c %>% 
    left_join(county_pop_data_c, by = "state") %>% 
    select(state, pop, density, county, county_population,)
  
  
  return(combined_data)
  
}






