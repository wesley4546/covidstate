#Data File
library(tidyverse)
library(janitor)
library(lubridate)
library(stringr)
library(patchwork)
library(ggplot2)
library(grid)

# Importing Data ----------------------------------------------------------

#Reads from the COVID github
url_to_covidgithub_cases <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
url_to_covidgithub_deaths <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"

#read_csv's the files in data
time_data <- read_csv(url_to_covidgithub_deaths)
state_order <- read_csv(here::here("data", "raw", "state_order.csv"))
pop_data <- read_csv(here::here("data", "raw", "state_population_data.csv"))
election_data <- read_csv(here::here("data", "raw", "pdf_covid_data_election.csv"))

# Cleaning Data -----------------------------------------------------------

#cleans up data - removes things I don't need
time_data <-
  time_data %>%
  clean_names() %>%
  filter(country_region == "US") %>%
  select(province_state, x1_22_20:ncol(time_data)) %>%
  rename(state = province_state) %>%
  filter(
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

pop_data <- pop_data %>% clean_names()

#Add's order variable from state_order
state_time <-
  time_data %>%
  left_join(state_order, by = "state") %>%
  select(state, order, everything()) %>%
  mutate(order = mdy(order))

#Consolidates all states into one state
state_combined <-
  state_time %>%
  select(-order) %>%
  group_by(state) %>%
  summarise_all(funs(sum))

#Creates a longer data set and adds a day count column
state_longer <-
  state_combined %>%
  pivot_longer(cols = x1_22_20:ncol(state_combined),
               names_to = "day",
               values_to = "deaths") %>%
  group_by(state) %>%
  mutate(daycount = 2:ncol(state_combined)) %>% #Number of days
  mutate(daycount = daycount - 1) #Have to make it actually the day (I dont know a better way)

#Filters out when cases are 0, adds the population data, creates a column for scaled_deaths
state_longer <-
  state_longer %>%
  filter(deaths >= 1) %>%
  left_join(pop_data, by = "state") %>%
  select(state, day, deaths, daycount, pop) %>%
  mutate(scaled_deaths= deaths / pop)

#Adds the election data from 2016
state_longer_elections <-
  state_longer %>%
  left_join(election_data, by = "state") %>% 
  select(!7:12)

#Add's a scaled_deaths_per_unit column
state_longer_elections <- 
  state_longer_elections %>% 
  mutate(scaled_deaths_per_unit = scaled_deaths * 100000)

#formats date into date objects
state_longer_elections <-
  state_longer_elections %>% 
  mutate(day = str_remove(day , "x"))

