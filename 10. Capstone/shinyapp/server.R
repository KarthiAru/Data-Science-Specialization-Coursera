#-----------------------------------Initialize libraries-----------------------------------
library(shiny) # Web Application Framework for R
library(data.table) #enhanced data.frame for fast subset, grouping and update to store the ngrams
library(magrittr)
library(stringi) #string processing package for iconv, stri_trans_general, stri_replace_all, stri_split

shinyServer(function(input, output) {
    
    observe({
        
        output$prediction <- renderText({
            
            k<-5 # number of results
            
            ends <- substr(input$text,nchar(input$text),nchar(input$text))
            last <- tail(unlist(stri_split(input$text, regex = "\\b", omit_empty = T)), n = 1)
            
            if(ends == " " | ends == "" | ends %in% c('.','!','?',';')){
                if(length(ends) > 0) token <- parse(input$text)
                else token <- input$text
                prediction <- predict_word(token, ends, k)
            }else{
                prediction <- unigram[order(-n)][, head(grep(paste0("^", last), word, value = T), n=k)]
            }
            return(prediction)
        })
        
        output$clean <- renderText({
            text <- clean(input$text)
            return(text)
        })
        
    })
})
