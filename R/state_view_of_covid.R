library(ggplot2)
library(plotly)
library(lubridate)
library(stringr)
library(patchwork)


source(here::here("R", "covid_data_functions.R"))

#creates a function that cleans and tidys the data
narrow_covid_data <- function(covid_dataset) {
  #Defines the columns we need
  columns_needed <- c("iso2", "admin2", "province_state",
                      "lat", "long")
  
  #Cleans the data set
  dataset_c <-
    covid_dataset %>%
    clean_names() %>%
    filter(iso2 == "US") %>% #Filters for US
    select(all_of(columns_needed), x1_22_20:ncol(covid_dataset)) %>% #selects columns
    rename(country = iso2) %>%
    rename(county = admin2) %>%
    rename(state = province_state) %>%
    select(country, state, everything()) #rearranges for intuiton
  
  return(dataset_c)
}


# actual coding -----------------------------------------------------------

#Grabs population data

population_data <- get_pop_data()

#Grabs the cases and cleans them
covid_cases <-
  get_covid_cases() %>%
  narrow_covid_data()

#Grabs the deaths and cleans them
covid_deaths <-
  get_covid_deaths() %>%
  narrow_covid_data()




# cases data ----------------------------------------------------


cases_data <- 
  covid_cases %>% 
  pivot_longer(cols = x1_22_20:ncol(covid_cases),
               names_to = "date",
               values_to = "cases") %>% 
  mutate(date = mdy(str_remove(date,"x"))) %>% 
  left_join(population_data, by = c("state","county")) %>% 
  mutate(scaled_county_cases = cases / county_population)



# death data --------------------------------------------------------------


deaths_data <- 
  covid_deaths %>% 
  pivot_longer(cols = x1_22_20:ncol(covid_deaths),
               names_to = "date",
               values_to = "deaths") %>% 
  mutate(date = mdy(str_remove(date,"x"))) %>% 
  left_join(population_data, by = c("state","county")) %>% 
  mutate(scaled_county_deaths = deaths / county_population)





# main_combined_dataset ---------------------------------------------------

main_combined_dataset <-
  cases_data %>% 
  left_join(deaths_data)


state_specific <- c("Florida")

florida_data <-
  main_combined_dataset %>%
  filter(state == state_specific) %>% 
  filter(!county %in% c("Unassigned","Out of FL"))




p <- 
  main_combined_dataset %>% 
  filter(state == state_specific) %>% 
  ggplot(aes(x = date)) +
  geom_line(aes(y = scaled_county_cases, group = county), color = "orange") +
  geom_line(aes(y = scaled_county_deaths, group = county), color = "darkgrey") +
  labs(title = state_specific)

p %>% ggplotly()



barchart_cases <-
  florida_data %>% 
  filter(date == Sys.Date() -1 ) %>% 
  mutate(county = fct_reorder(county, scaled_county_cases)) %>%
  ggplot(aes(county,scaled_county_cases)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Confirmed Cases",
    y = "Scaled Cases",
    x = "County"
  ) +
  theme(
    legend.position = "none"
  )
barchart_cases 

barchart_deaths <-
  florida_data %>% 
  filter(date == Sys.Date() -1 ) %>% 
  mutate(county = fct_reorder(county, scaled_county_cases)) %>% 
  ggplot(aes(county,scaled_county_deaths)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Confirmed Deaths",
    y = "Scaled Deaths",
    x = "County"
  ) +
  theme(
    legend.position = "none"
  )
barchart_deaths


average_CFR <-
  florida_data %>% 
  filter(date == Sys.Date() -1 ) %>% 
  mutate(CFR = (deaths / cases)* 100) %>% 
  filter(!CFR == 0) %>% 
  mutate(avg_CFR = mean(CFR)) 

average_CFR_plot<-
  average_CFR %>% 
  mutate(county = fct_reorder(county, scaled_county_cases)) %>% 
  ggplot(aes(x = county, y = CFR)) +
  geom_col() +
  coord_flip()

average_CFR_plot <-
  average_CFR_plot +
  geom_hline(yintercept = average_CFR$avg_CFR, linetype = "dashed", color = "#2f4f24") +
  labs(
    title = "Average CFR",
    x = "County"
  )


tri_plot <- barchart_cases + barchart_deaths + average_CFR_plot
tri_plot
