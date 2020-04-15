library(tidyverse)
library(ggplot2)
library(janitor)
library(lubridate)
library(stringr)

time_data <- read_csv(here::here("data","raw","time_series_covid19_confirmed_US.csv"))
state_order <- read_csv(here::here("data","raw","state_order.csv"))


time_data <- 
  time_data %>% 
  clean_names() %>% 
  filter(country_region == "US") %>% 
  select(province_state, x1_22_20:ncol(time_data)) %>% 
  rename(state = province_state)


state_time <- 
  time_data %>% 
  left_join(state_order, by = "state") %>% 
  select(state, order, everything()) %>% 
  mutate(order = mdy(order)) 

state_time_sum <- 
  state_time %>% 
  group_by(state) %>% 
  summarize(day1 = sum(x1_22_20))


state_combined <-
  state_time %>% 
  select(-order) %>% 
  group_by(state) %>% 
  summarise_all(funs(sum))

state_longer <-
  state_combined %>% 
  pivot_longer(cols = x1_22_20:x4_11_20,
               names_to = "day",
               values_to = "cases") 
new_york <-
  state_longer %>% 
  filter(state == "Florida") %>% 
  mutate(daycount = 1:nrow(.))

ggplot(new_york, aes(daycount,cases)) +
  geom_point() 
