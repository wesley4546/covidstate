library(shiny)

#Sources data file
source("R/covid_source_file.R", local = TRUE)

ui <- fluidPage(
  # Header ------------------------------------------------------------------
  titlePanel("COVID-19 | Deaths Over Time in the U.S."),
  
  # Body --------------------------------------------------------------------
  h3("Overview"),
  p("
    This is a ShinyApp that is made to interact with the COVID-19's deaths per 100,000 people in the U.S by state colored by results
    of the 2016 Presidential Election results by popular vote.
    "),
  br(),
  p("Feel free to raise an issue on Github:", a(href="https://github.com/wesley4546/covidstate",target="_blank", "https://github.com/wesley4546/covidstate")),
  p("Or email me at wesley.gardiner4546@gmail.com with any questions/comments/concerns"),
  
  
  
  
  hr(),
  # sidebarLayout ----------------------------------------------------------
  h4("Control Panel"),
  sidebarLayout(
    
    sidebarPanel(
      
      # Filter by section -------------------------------------------------------
      
      p("Filter by"),
      # Creates checkboxes for state filter
      checkboxGroupInput(
        inputId = "state_filter",
        label ="State",
        choices = unique(state_longer_elections$state),
        selected = c("Florida", "New York"),
        inline = TRUE
      ),
      
      
      # Options section ---------------------------------------------------------
      
      hr("Options"),
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
      
      
      # Download Section --------------------------------------------------------
      hr(),
      #Download button for data
      downloadButton("downloadData", "Download Full Dataset (.csv)"),
      #updated text
      h5(paste("Updated:", format(Sys.time(), "%A %B %d, %Y"))),
      
    ), #End of sidebarPanel
    
    
    # Main Panel --------------------------------------------------------------
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("lineplot")),
        tabPanel("Summary", verbatimTextOutput("summary")),
        tabPanel("Table", tableOutput("table"))
      )
    )
    
  ), #End of sidebarLayout
  
  # Reference Section --------------------------------------------------------  
  hr(),
  h4("Where I got my data"),
  p("COVID-19 Data:", a(href="https://github.com/CSSEGISandData/COVID-19",target="_blank","https://github.com/CSSEGISandData/COVID-19")),
  
  p("State Population Data:", a(href="https://worldpopulationreview.com/states/",target="_blank","https://worldpopulationreview.com/states/")),
  
)
