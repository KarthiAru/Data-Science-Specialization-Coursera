

#----------------------------------- Folder Structure ----------------------------------- 


#----------------------------------- 1. Set folder path & options -----------------------------------
setwd("~/Documents/MOOC/Coursera/DSS/10. Capstone/milestone")
options("scipen"=7) #fixed notation over exponential notation for significant digits upto a maximum difference of 7 digits

#----------------------------------- 2. Initialize libraries -----------------------------------
library(data.table) # enhanced data.frame for fast subset, grouping and update to store the ngrams
library(stringi) # string processing package for iconv, stri_trans_general, stri_replace_all
library(magrittr) # %>% operator to improve the code by avoiding local variables and nested function calls
library(ngram) # convert input string to ngrams
library(ggplot2) # for plots
library(stringr)
#----------------------------------- 3. Download data & Save to .RDS -----------------------------

#---------- download the data ---------- 
#if(!file.exists("Coursera-SwiftKey.zip")) {
#    download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera#-SwiftKey.zip", destfile = "data/Coursera-SwiftKey.zip", method = "auto", mode = "wb")
#}

#---------- unzip the data files ---------- 
#if(!file.exists("data/final/en_US/en_US.blogs.txt")|
#   !file.exists("data/final/en_US/en_US.twitter.txt")|
#   !file.exists("data/final/en_US/en_US.news.txt")) {
#    unzip("Coursera-SwiftKey.zip")
#}

#---------- import files ---------- 
# con <- file("data/final/en_US/en_US.blogs.txt", "r")
# blogs <- readLines(con); close(con)
# con <- file("data/final/en_US/en_US.news.txt", "r")
# news <- readLines(con); close(con)
# con <- file("data/final/en_US/en_US.twitter.txt", "r")
# twitter <- readLines(con); close(con)

#---------- save to .RDS ---------- 
# saveRDS(blogs,file="data/final/en_US/blogs_data.RDS")
# saveRDS(news,file="data/final/en_US/news_data.RDS")
# saveRDS(twitter,file="data/final/en_US/twitter_data.RDS")

# ----------------------------------- 4. Summary on the files -----------------------------------

#---------- no. of lines, words, characters ---------- 
system("wc data/blogs.RDS")
system("wc data/news.RDS")
system("wc data/twitter.RDS")

#----------------------------------- 5. Data Sampling -----------------------------------
#---------- load data ---------- 
blog <- readRDS("data/blogs.RDS")
news <- readRDS("data/news.RDS")
twitter <- readRDS("data/twitter.RDS")
corpus <- c(blog,news,twitter)
rm(list=c('blog','news','twitter'))

#---------- sample corpus ---------- 
set.seed(123)
n <- length(corpus)
sample_size <- 0.001 # 1% sample
corpus <- sample(corpus, n*sample_size, replace = FALSE, prob = NULL)

#----------------------------------- 5. Data cleaning and parsing -----------------------------------
source('code/parse.R')

word_count <- function(string) length(strsplit(unlist(string),' ')[[1]])

timer_all <- Sys.time()
corpus <- parse(corpus)
corpus <- corpus[unlist(lapply(corpus, function(x) word_count(x)>=5))]
cat("\n***Process completed in",round(difftime(Sys.time(), timer_all, tz = "", units = "mins"),2),"min!***")

#----------------------------------- 6. Split to n-grams fragments -----------------------------------

timer_all <- Sys.time()
#---------- convert to ngrams ---------- 
unigram <- ngram(corpus, 1)
bigram <- ngram(corpus, 2)
trigram <- ngram(corpus, 3)
fourgram <- ngram(corpus, 4)
fivegram <- ngram(corpus, 5)
#---------- convert to data.table ---------- 
unigram <- data.table(get.phrasetable(unigram))
bigram <- data.table(get.phrasetable(bigram))
trigram <- data.table(get.phrasetable(trigram))
fourgram <- data.table(get.phrasetable(fourgram))
fivegram <- data.table(get.phrasetable(fivegram))
setDT(unigram)[,prop:=NULL]
setDT(bigram)[,prop:=NULL]
setDT(trigram)[,prop:=NULL]
setDT(fourgram)[,prop:=NULL]
setDT(fivegram)[,prop:=NULL]

#unigram
setDT(unigram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""))]
setnames(unigram, c("uni","n1"))

#bigrams
setDT(bigram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                    uni = word(ngrams, 1,1),
                    word =  word(ngrams, 2,2))]
setDT(bigram)[,`:=`(ngrams = NULL)]
setcolorder(bigram, c("uni","word","freq"))
setnames(bigram, c("uni","word","n2"))

#trigrams
setDT(trigram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                    bi = word(ngrams, 1,2),
                    word =  word(ngrams, 3,3))]
setDT(trigram)[,`:=`(ngrams = NULL)]
setcolorder(trigram, c("bi","word","freq"))
setnames(trigram, c("bi","word","n3"))

#fourgrams
setDT(fourgram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                     tri = word(ngrams, 1,3),
                     word =  word(ngrams, 4,4))]
setDT(fourgram)[,`:=`(ngrams = NULL)]
setcolorder(fourgram, c("tri","word","freq"))
setnames(fourgram, c("tri","word","n4"))

#fivegrams
setDT(fivegram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                      four = word(ngrams, 1,4),
                      word =  word(ngrams, 5,5))]
setDT(fivegram)[,`:=`(ngrams = NULL)]
setcolorder(fivegram, c("four","word","freq"))
setnames(fivegram, c("four","word","n5"))


cat("\n***Process completed in",round(difftime(Sys.time(), timer_all, tz = "", units = "mins"),2),"min!***")

#----------------------------------- 7. Plots -----------------------------------

#---------- top 20 n-grams ---------- 
plot_ngrams <- function(ngrams, n, title){
ggplot(ngrams[1:n,], aes(x = reorder(ngrams, freq), y = freq) ) +
    geom_bar(stat="identity") + 
    coord_flip() +
    labs(title = title ,y = "Frequency", x = "N-Grams")
}

plot_ngrams(unigram, 20, "Unigrams")
plot_ngrams(bigram, 20, "Bigrams")
plot_ngrams(trigram, 20, "Trigrams")
plot_ngrams(fourgram, 20, "Fourgrams")
plot_ngrams(fivegram, 20, "Fivegrams")


#---------- Zipf's law: n-grams frequency ---------- 
par(mfrow=c(2,2))
plot(1:length(cGram1$Word),log(cGram1$Freq),type="l", xlab="Row (1-gram)", ylab="log(Freq)")+abline(h=3, col="blue")+abline(v=18360, col="red")+text(1,3, "18k 1-grams (9.2%) with freq >= 20", col = 2, adj = c(0,-0.2))
plot(1:length(cGram2$Word),log(cGram2$Freq),type="l", xlab="Row (2-gram)", ylab="log(Freq)")+abline(h=1.098, col="blue")+abline(v=333424, col="red")+text(1,3, "333k 2-grams (12.3%) with freq >= 3", col = 2, adj = c(0,-0.2))
plot(1:length(cGram3$Word),log(cGram3$Freq),type="l", xlab="Row (3-gram)", ylab="log(Freq)")+abline(h=0.69, col="blue")+abline(v=442701, col="red")+text(1,3, "442k 3-grams (8.1%) with freq >= 2", col = 2, adj = c(0,-0.2))
plot(1:length(cGram4$Word),log(cGram4$Freq),type="l", xlab="Row (4-gram)", ylab="log(Freq)")+abline(h=0.69, col="blue")+abline(v=148185, col="red")+text(1,3, "148k 4-grams (2.4%) with freq >= 2", col = 2, adj = c(0,-0.2))
