library(shiny)


shinyUI(navbarPage("Normal Distribution",
                   tabPanel("Plot",
                            sidebarPanel(
                                    uiOutput("mean"),
                                    uiOutput("sd"),
                                    uiOutput("num"),
                                    helpText("Model:"),
                                    div(textOutput("model"),style="text-indent:20px;font-size:125%;"),
                                    uiOutput("tail"),
                                    uiOutput("a"),
                                    uiOutput("b")
                                    ),
                            mainPanel(
                                    plotOutput("plot"),
                                    div(textOutput("area"), align = "center", style="font-size:150%;")
                                  )
                            ),
                   tabPanel("About",
                            mainPanel(
                                htmlOutput("about")
                            )
                   )
))