#function to predict the next word

predict_word <- function(text, ends, k=3){
    token <- unlist(strsplit(clean(text), " ", fixed=T))
    j <- length(token)
    starts <- data.table(word=c('I','The','It','This','We'))
    ends <- ''
    if (j>0) ends <- substr(text,nchar(text),nchar(text))
    #Sentence starters
    if(ends %in% c('.','!','?',';')) result <- starts$word[1:k]
    else{
        if(j == 0) result <- starts$word[1:k]
        else if(j == 1){
            result <- c(bigram[token[j], nomatch=0][order(-p)]$word[1:k],
                        unigram[order(-n)]$word[1:k])
        }else if (j == 2){
            result <- c(rbind(trigram[paste(token[j-1], token[j],sep=" "), nomatch=0][order(-p)],
                        bigram[token[j], nomatch=0][order(-p)])[order(-p)]$word[1:(k*2)],
                        unigram[order(-n)]$word[1:k])
        }else if (j == 3){
            result <- c(rbind(fourgram[paste(token[j-2], token[j-1], token[j], sep=" "), nomatch=0][order(-p)],
                        trigram[paste(token[j-1], token[j], sep = " "), nomatch=0][order(-p)],
                        bigram[token[j], nomatch=0][order(-p)])[order(-p)]$word[1:(k*2)],
                        unigram[order(-n)]$uni[1:k])
        }else{
            result <- c(rbind(fivegram[paste(token[j-3],token[j-2], token[j-1], token[j], sep=" "), nomatch=0][order(-p)],
                        fourgram[paste(token[j-2], token[j-1], token[j], sep=" "), nomatch=0][order(-p)],
                        trigram[paste(token[j-1], token[j], sep = " "), nomatch=0][order(-p)],
                        bigram[token[j], nomatch=0][order(-p)])[order(-p)]$word[1:(k*2)],
                        unigram[order(-n)]$uni[1:k])
        }
    }
    
    result <- unique(result[!is.na(result)])[1:k]
    return (result[!is.na(result)])
}

