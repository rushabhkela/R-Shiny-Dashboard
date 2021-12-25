# UI for Dashboard
library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
    dashboardHeader(title = "RUSHABH KELA"),
    dashboardSidebar(
        dateRangeInput("daterange", "CORONAVIRUS STATISTICS GLOBALLY - Date Range: ", start = "2020-01-23", end="2021-07-31"),
        selectInput("topN", "ACTIVE CORONAVIRUS CASES OF TOP COUNTRIES (Pie - Chart) - Select Number of Countries: ",
                    c("1" = 1, "2" = 2,"3" = 3,"4" = 4,"5" = 5,"6" = 6,"7" = 7,"8" = 8,"9" = 9, "10" = 10)
        ),
        
        selectInput("topCnt", "COVID-19 DATA - Select a country :",
                    c("India" = "India", 
                      "USA" = "US",
                      "China" = "China",
                      "France" = "France",
                      "United Kingdom" = "United Kingdom")
        ),
        radioButtons("btns", "Select Data: ",
                     c("Confirmed" = "Confirmed",
                       "Active" = "Active",
                       "Deaths" = "Deaths",
                       "Recovered" = "Recovered"))
    ),
    dashboardBody(
        h1("COVID-19. The pandemic that shook the world. #StaySafe"),
        fluidRow(
            infoBoxOutput("cnfBox"),
            infoBoxOutput("recBox"),
            infoBoxOutput("deathBox")
        ),
        fluidRow(
            plotlyOutput("globalCases")
        ),
        fluidRow(
            splitLayout(cellWidths = c("50%", "50%"), plotOutput("wordCloud"), plotlyOutput("topPieChart"))
        ),
        fluidRow(
            plotlyOutput(outputId = "cntPlots")
        )
    )
)
