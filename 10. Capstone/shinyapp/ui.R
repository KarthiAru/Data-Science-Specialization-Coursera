library(shiny)

shinyUI(
    fluidPage(
        theme = "main.css",
        fluidRow(
            column(8, offset = 2,
                   br(), br(),
                   h1("Type your phrase below... "), br(),br(),
                   p(textInput(inputId = "text",label = ""),
                     textOutput("prediction")),
                   #br(), em(strong("Note: "), span("orange", style = "color: #d16527;"), " indicates the autocomplete hints, ", span("blue", style = "color: #176de3;"), " indicates the predicted word", style = "color: #AAA"),
                   br(), br(),checkboxInput("details", "Details", TRUE),
                   conditionalPanel(
                       condition = "input.details == true",
                       wellPanel(
                           p(strong("Tokenized Phrase: "), textOutput("clean", inline = TRUE))
                           )
                   )
            )
        )))