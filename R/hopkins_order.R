library(ggplot2)


# Sourcing Data Files -----------------------------------------------------

source(here::here("R","covid_source_file.R"))

# Graphing Data -----------------------------------------------------------

#Graph of all states colored by party
election_state_graph <-
  ggplot(state_longer_elections,
         aes(
           daycount,
           scaled_deaths,
           color = factor(party, c("republican", "democrat")),
           group = state
         )) +
  geom_line() +
  theme(legend.title = element_blank()) +
  labs(
    title = "Deaths of COVID-19 from Janurary 1 to April 11 by State" ,
    subtitle = "Scaled to population of state - Colored by vote in 2016 Election (Popular)",
    x = "Day Count",
    y = "Scaled Count"
  )
election_state_graph


facet_election_graph <-
  election_state_graph +
  facet_grid(~party)
facet_election_graph

#Creates a subset for republican states
state_longer_rep <-
  state_longer_elections %>%
  filter(party == "republican")

#Graphs subset
rep_state_graph <-
  ggplot(state_longer_rep,
         aes(daycount, scaled_deaths, color = state, group = state)) +
  geom_line() +
  theme(legend.title = element_blank()) +
  labs(
    title = "Deaths of COVID-19 from Janurary 1 to April 11 - Republican States" ,
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
         aes(daycount, scaled_deaths, color = state, group = state)) +
  geom_line() +
  theme(legend.title = element_blank()) +
  labs(
    title = "Deaths of COVID-19 from Janurary 1 to April 11 - Democratic States" ,
    subtitle = "Scaled to population of state - Colored by State",
    x = "Day Count",
    y = "Scaled Count"
  )


dem_state_graph




