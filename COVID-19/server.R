# Server for Dashboard
# Shiny Dashboard 
library(shinydashboard)
# To load and analyze updated time series worldwide data of reported cases for the COVID-19 disease
library(covid19.analytics)

# Text Data Visualisation
library(readr)
library(dplyr)
library(e1071)
library(mlbench)
# Text Mining Packages
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)

# Creating Interactive Plots
library(plotly)
# Package to work with date and time options
library(lubridate)

# WORD CLOUD of COVID-19 tweets dataset
t1 <- read_csv("corona_text.csv")
corpus = Corpus(VectorSource(t1$`OriginalTweet`))
corpus = tm_map(corpus, PlainTextDocument)
corpus = tm_map(corpus, tolower)
corpus = tm_map(corpus, removePunctuation)
corpus = tm_map(corpus, removeWords, c("cloth", stopwords("english")))
corpus = tm_map(corpus, stemDocument)
corpus = tm_map(corpus, stripWhitespace)
DTM <- TermDocumentMatrix(corpus)
mat <- as.matrix(DTM)
f <- sort(rowSums(mat),decreasing=TRUE)
dat <- data.frame(word = names(f),freq=f)
head(dat, 5)
set.seed(100)

# Getting COVID - 19 data using the covid19.analytics package
data <- covid19.data()

server <- function(input, output) {
    output$cnfBox <- renderInfoBox({
        infoBox(
            "CONFIRMED", paste0(sum(data["Confirmed"])), icon = icon("virus"),
            color = "green", fill = TRUE
        )
    })
    output$recBox <- renderInfoBox({
        infoBox(
            "RECOVERED", paste0(sum(data["Recovered"], na.rm=TRUE)), icon = icon("hand-holding-medical"),
            color = "purple", fill = TRUE
        )
    })
    output$deathBox <- renderInfoBox({
        infoBox(
            "DEATHS", paste0(sum(data["Deaths"])), icon = icon("skull-crossbones"),
            color = "yellow", fill = TRUE
        )
    })
    
    output$globalCases <- renderPlotly({
        data <- read.csv("https://raw.githubusercontent.com/laxmimerit/Covid-19-Preprocessed-Dataset/master/preprocessed/daywise.csv")
        data$Date <- ymd(data$Date)
        data <- arrange(data, Date)
        data <- data %>% mutate(Date = as.POSIXct(Date), 
                                update = ifelse(Date > as.POSIXct(input$daterange[1]) & Date < as.POSIXct(input$daterange[2]) , 'Yes', 'No'))
        data <- filter(data, update == "Yes")
        fig <- plot_ly(data, x=~Date)
        fig <- fig %>% add_trace(y=~Confirmed, name="Confirmed", type="scatter", mode="lines", line = list(color = "#893ea6", width="4"))
        fig <- fig %>% add_trace(y=~Recovered, name="Recovered", type="scatter", mode="lines", line = list(color = "#ff2e63", width="4"))
        fig <- fig %>% add_trace(y=~Deaths, name="Deaths", type="scatter", mode="lines", line = list(color = "#21bf73", width="4"))
        fig <- fig %>% layout(title = "TOTAL CORONAVIRUS CASES GLOBALLY",
                              xaxis = list(title="Date"),
                              yaxis = list(title="Total Cases")
        )
        fig
    })
    
    output$wordCloud <- renderPlot({
        wordcloud(words = dat$word, freq = dat$freq, min.freq = 3, max.words=250, random.order=FALSE, rot.per=0.30, colors=brewer.pal(8, "Dark2"))
    })
    
    output$topPieChart <- renderPlotly({
        countries <- read.csv("https://raw.githubusercontent.com/laxmimerit/Covid-19-Preprocessed-Dataset/master/preprocessed/countrywise.csv")
        attach(countries)
        countries <- countries[order(-Active),]
        data <- countries[1:input$topN,c(1,5)]
        
        plot_ly(data, labels = ~Country, values = ~Active, type = 'pie') %>% 
            layout(title = 'Top Countries with Active COVID-19 cases')
    })
    
    output$cntPlots <- renderPlotly({
        dt <- read.csv("https://raw.githubusercontent.com/laxmimerit/Covid-19-Preprocessed-Dataset/master/preprocessed/country_daywise.csv")
        dt <- dt %>% filter(Country == input$topCnt)
        dt$Date <- ymd(dt$Date)
        dt <- arrange(dt, Date)
        if(input$btns == "Confirmed") {
            y = ~Confirmed
        } else if (input$btns == "Active") {
            y = ~Active
        } else if (input$btns == "Recovered") {
            y = ~Recovered
        } else {
            y = ~Deaths
        }
        plot_ly(
            data = dt,
            x = ~Date,
            y = y,
            type = "scatter",
            mode = "lines",
            fill = "tozeroy"
        ) %>% layout(title = paste("COVID - 19 STATISTICS - ", input$topCnt),
                     xaxis = list(title="Date"),
                     yaxis = list(title="Total Cases"))
    })
}
