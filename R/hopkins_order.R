library(tidyverse)
library(ggplot2)
library(janitor)
library(lubridate)
library(stringr)
library(patchwork)
#Reads in data
time_data <-
  read_csv(here::here("data", "raw", "time_series_covid19_confirmed_US.csv"))
state_order <- read_csv(here::here("data", "raw", "state_order.csv"))
pop_data <-
  read_csv(here::here("data", "raw", "state_population_data.csv"))
election_data <-
  read_csv(here::here("data", "raw", "pdf_covid_data_election.csv"))


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
      "Grand Princess"
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
  pivot_longer(cols = x1_22_20:x4_11_20,
               names_to = "day",
               values_to = "cases") %>%
  group_by(state) %>%
  mutate(daycount = 1:81) #Number of days

#Filters out when cases are 0, adds the population data, creates a column for scaled_cases
state_longer <-
  state_longer %>%
  filter(cases >= 1) %>%
  left_join(pop_data, by = "state") %>%
  select(state, day, cases, daycount, pop) %>%
  mutate(scaled_case = cases / pop)

#Adds the election data from 2016
state_longer_elections <-
  state_longer %>%
  left_join(election_data, by = "state") %>% 
  select(!7:12)



# Graphing Data -----------------------------------------------------------

#Graph of all states colored by party
election_state_graph <-
  ggplot(state_longer_elections,
         aes(
           daycount,
           scaled_case,
           color = factor(party, c("republican", "democrat")),
           group = state
         )) +
  geom_line() +
  theme(legend.title = element_blank()) +
  labs(
    title = "Cases of COVID-19 from Janurary 1 to April 11 by State" ,
    subtitle = "Scaled to population of state - Colored by vote in 2016 Election (Popular)",
    x = "Day Count",
    y = "Scaled Count"
  )
election_state_graph


facet_election_graph <-
  election_state_graph +
  facet_grid(~party)


#Creates a subset for republican states
state_longer_rep <-
  state_longer_elections %>%
  filter(party == "republican")

#Graphs subset
rep_state_graph <-
  ggplot(state_longer_rep,
         aes(daycount, scaled_case, color = state, group = state)) +
  geom_line() +
  theme(legend.title = element_blank()) +
  labs(
    title = "Cases of COVID-19 from Janurary 1 to April 11 - Republican States" ,
    subtitle = "Scaled to population of state - Colored by State",
    x = "Day Count",
    y = "Scaled Count"
  )
rep_state_graph

#Creates subset for Democratic States
state_longer_dem <-
  state_longer_elections %>%
  filter(party == "democrat")

#Graphs Subset
dem_state_graph <-
  ggplot(state_longer_dem,
         aes(daycount, scaled_case, color = state, group = state)) +
  geom_line() +
  theme(legend.title = element_blank()) +
  labs(
    title = "Cases of COVID-19 from Janurary 1 to April 11 - Democratic States" ,
    subtitle = "Scaled to population of state - Colored by State",
    x = "Day Count",
    y = "Scaled Count"
  )
dem_state_graph





# group_sum <-
#   state_longer %>%
#   group_by(day) %>%
#   select(-state) %>%
#   summarise_all(funs(sum))%>%
#   mutate(daycount = 1:81)
#
# state_specific <- "Florida"
#
# state_case <-
#   state_longer %>%
#   filter(state == state_specific) %>%
#   mutate(daycount = 1:nrow(.)) %>%
#   filter(cases >= 1)
#
# library(caTools)
#
# split <- sample.split(state_longer$scaled_case, SplitRatio = .8)
# train_new <- subset(state_longer, split == TRUE)
# test_new <- subset(state_longer, split == FALSE)
#
# glm_model <- loess(log(scaled_case) ~ daycount, data = train_new)
#
# glm_predict <- predict(glm_model, test_new)
#
# confmatrix <- table(glm_predict, test_new$scaled_case)
#
# totalcorrect <- confmatrix[1,1] + confmatrix[2,2]
# total <- nrow(test_new)
# (percentage <- totalcorrect / total)
