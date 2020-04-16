library(tidyverse)
library(broom)
library(patchwork)
library(ggthemes)
#Reading in the data (Sorry for the filepath)
data <- read.csv(here::here("data","raw","pdf_covid_data_election.csv"))                 

#Cleaning up the names
data <- 
  data %>% 
  mutate(state = as.character(state)) %>% 
  janitor::clean_names()

data$party <- factor(data$party, levels = c("republican","democrat"))


#Creating a republican filtered dataset
rep_data <- 
  data %>% 
  filter(party == "republican")


#Creating a democratic filtered 
dem_data <- 
  data %>% 
  filter(party == "democrat")


# Data manipulation for t-test --------------------------------------------


rep_mean <-
  rep_data %>% 
  select(2:7) %>% 
  map(~ mean(.x)) %>% 
  as_tibble()

dem_mean <-
  dem_data %>% 
  select(2:7) %>% 
  map(~ mean(.x)) %>% 
  as_tibble()


# t-testing ---------------------------------------------------------------

#Hypothesis: Democratic states will move around less than republican states.
#Null : Democratic states will move the same as republican states.


#Creates tests for every activity
retail_ttest <- t.test(dem_data$retail_and_recreation, 
                       mu = rep_mean$retail_and_recreation[1], #Mean of republican States
                       alternative = "less", 
                       conf.level = 0.95)

groc_ttest <- t.test(dem_data$grocery_and_pharmacy, 
                     mu = rep_mean$grocery_and_pharmacy[1], #Mean of republican State
                     alternative = "less", 
                     conf.level = 0.95)

parks_ttest <- t.test(dem_data$parks, 
                      mu = rep_mean$parks[1], #Mean of republican State
                      alternative = "less", 
                      conf.level = 0.95)

transit_ttest <- t.test(dem_data$transit_stations, 
                        mu = rep_mean$transit_stations[1]	, #Mean of republican State
                        alternative = "less", 
                        conf.level = 0.95)

work_ttest <- t.test(dem_data$workplace, 
                     mu = rep_mean$workplace[1]	, #Mean of republican State
                     alternative = "less", 
                     conf.level = 0.95)

residential_ttest1 <- t.test(dem_data$residential, 
                             mu = rep_mean$residential[1]	, #Mean of republican State
                             alternative = "less",
                             conf.level = 0.95) 

residential_ttest2 <- t.test(dem_data$residential, 
                             mu = rep_mean$residential[1]	, #Mean of republican State
                             alternative = "two.sided",
                             conf.level = 0.95) 
#Creates a table for output
ttest <- tibble()
ttest <- 
  ttest %>% 
  rbind(tidy(retail_ttest)) %>% 
  rbind(tidy(groc_ttest)) %>% 
  rbind(tidy(parks_ttest)) %>% 
  rbind(tidy(transit_ttest)) %>% 
  rbind(tidy(work_ttest)) %>% 
  rbind(tidy(residential_ttest1)) %>% 
  rbind(tidy(residential_ttest2))

#Adds labels
ttest$activity = c("retail","groc","parks","transit","work","residential1","residential2")

#Cleans it up a little.
ttest <- 
  ttest %>% 
  select(activity, everything())


# Data manipulation for Plotting ------------------------------------------


data_pivot <- 
  data %>% 
  pivot_longer(cols = c("retail_and_recreation","grocery_and_pharmacy","parks",
                        "transit_stations","workplace","residential"),
               names_to = "activity",
               values_to = "change")


data_pivot_mean <-
  data_pivot %>% 
  group_by(party, activity) %>% 
  summarise(mean = mean(change))

data_pivot_state<-
  data_pivot %>% 
  group_by(party, state) %>% 
  summarise(mean = mean(change))

#using the stat_summary to test things
 test <- ggplot(data_pivot, aes(x = state, y = change, fill = party)) +
   stat_summary(fun = mean, geom = "bar") +
   facet_grid(. ~ activity)

# Plotting ----------------------------------------------------------------



(overall_plot <- ggplot(data_pivot_mean, aes(party,mean, fill = party)) +
    geom_col()+
    labs(
      title = "Overall Change by party",
      x =""
    ))

(facet_plot <- ggplot(data_pivot_mean, aes(party,mean, fill = party)) +
    geom_col() +
    labs(
      title = "Mean of Change of Activity",
      x = ""
    ) +
    facet_grid(~ activity))

 (
   state_plot <-
     ggplot(data_pivot_state, aes(reorder(state, mean), mean, fill = party)) +
     geom_col() +
     scale_x_discrete(label = abbreviate) +
     labs(title = "Average Change of Activity",
          subtitle ="Colored by 2016 Election Results (Popular)",
          x = "State",
          y = "Mean change",
          fill = "Party") +
     theme(
       axis.text.x = element_blank(),
       axis.ticks.x = element_blank()
     )
   # +
   # coord_fixed(.2)
 )
