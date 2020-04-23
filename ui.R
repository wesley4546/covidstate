library(shiny)

#Sources data file
source("R/covid_source_file.R", local = TRUE)

ui <- fluidPage(
  
  # Header ------------------------------------------------------------------
  h1("COVID-19 | Deaths Over Time in the U.S."),
  # sidebarLayout ----------------------------------------------------------
  sidebarLayout(
    sidebarPanel(
      h4("Control Panel"),
      hr(),
      h5("Filter by:"),
      # Creates checkboxes for state filter
      checkboxGroupInput(
        inputId = "state_filter",
        label ="State",
        choices = unique(state_longer_elections$state),
        selected = c("Florida", "New York"),
        inline = TRUE
      ),
      hr(),
      h5("Options:"),
      # creates checkbox for labels of states
      checkboxInput(inputId = "label_button",
                    label = "Label States",
                    value = TRUE
                    ),
      checkboxInput(inputId = "facet_button",
                    label = "Facet by Party",
                    value = FALSE
      ),
      # sidebarPanel Buttons -----------------------------------------------------------------
      
      # reset_button
      actionButton(inputId = "reset_button", "Reset Filter"),
      
      # all_democrat_button
      actionButton(inputId = "all_democrat_button", "Select All Democrat"),
      
      # all_republican_button
      actionButton(inputId = "all_republican_button", "Select All Republican"),
      
      # all_state_button
      actionButton(inputId = "all_state_button", "Select All"),
      
      h5(paste(
        "Updated:", format(Sys.time(), "%A %B %d, %Y")
      )),
      ),
    
    mainPanel(plotOutput("lineplot"), )
  ))
