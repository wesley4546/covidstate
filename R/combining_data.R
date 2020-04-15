#Combining tables

library(tidyverse)
library(lubridate)
library(janitor)
library(tsibble)

# Reading in data ---------------------------------------------------------

population_data <- read.csv(here::here("data","raw","state_population_data.csv"), stringsAsFactors = FALSE)
coronavirus_time_data <- read.csv(here::here("data","raw","time_series_covid19_confirmed_US.csv"), stringsAsFactors = FALSE)
state_order_data <- read.csv(here::here("data","raw","state_order.csv"), stringsAsFactors = FALSE)
main_data <- read.csv(here::here("data","raw","pdf_covid_data_election.csv"), stringsAsFactors = FALSE)

# Cleaning order data -----------------------------------------------------------

state_order_data_cleaned <-
  state_order_data %>% 
  clean_names() %>% 
  rename(state = i_state) %>%  #Removes a i character
  mutate(order = mdy(order))

# Cleaning population data ------------------------------------------------


population_cleaned <-
  population_data %>% 
  clean_names() %>% 
  select(state, pop) %>% 
  rename(population = pop)

# Cleaning corona time data ------------------------------------------------

coronavirus_time_cleaned <-
  coronavirus_time_data %>% 
  clean_names() %>% 
  filter(iso3 == "USA") %>% 
  select(-c(uid,iso2,iso3,code3,fips,admin2,country_region,lat,long,combined_key)) %>% 
  rename(state = province_state)

coronavirus_time_cleaned <- coronavirus_time_cleaned[,-2:-75] #Removes a chunk of days I dont need

#I tried to look a solution on how to do this an easier way for about an hour and couldn't find anything :(

x4_5_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_5_20 = sum(x4_5_20))


x4_6_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_6_20 = sum(x4_6_20))

x4_7_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_7_20 = sum(x4_7_20))

x4_8_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_8_20 = sum(x4_8_20))

x4_9_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_9_20 = sum(x4_9_20))

x4_10_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_10_20 = sum(x4_10_20))

x4_11_20 <- 
  coronavirus_time_cleaned %>%  
  group_by(state) %>% 
  summarise(x4_11_20 = sum(x4_11_20))

#Same here :(

date_data <- 
  x4_5_20 %>% 
  left_join(x4_6_20, by = "state") %>% 
  left_join(x4_7_20, by = "state") %>% 
  left_join(x4_8_20, by = "state") %>% 
  left_join(x4_9_20, by = "state") %>% 
  left_join(x4_10_20, by = "state") %>% 
  left_join(x4_11_20, by = "state")

date_data <- date_data[-9,]
date_data <- date_data[-12,]

date_data <- 
  rowwise(date_data) %>% 
  mutate(corona_mean = mean(x4_5_20:x4_11_20))

date_data_mean <-
  date_data %>% 
  select(state, corona_mean)




# Combining Tables --------------------------------------------------------

main_data <- 
  main_data %>% 
  clean_names() %>% 
  left_join(population_cleaned, by = "state") %>% 
  left_join(state_order_data_cleaned, by = "state") %>% 
  left_join(date_data_mean, by = "state") %>% 
  mutate(mean_divided_population = corona_mean/population)

#write_csv(main_data, here::here("main_covid_data.csv"))




