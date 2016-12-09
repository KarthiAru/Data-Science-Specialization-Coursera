setwd("/Users/Karthik/Dropbox/Capstone")

source('~/Documents/MOOC/Coursera/DSS/10. Capstone/shinyapp/clean.R')
source('~/Documents/MOOC/Coursera/DSS/10. Capstone/shinyapp/parse.R')
source('~/Documents/MOOC/Coursera/DSS/10. Capstone/shinyapp/predict.R')

unigram <- readRDS("data/ngram/unigram.Rds")
bigram <- readRDS("data/ngram/bigram.Rds")
trigram <- readRDS("data/ngram/trigram.Rds")
fourgram <- readRDS("data/ngram/fourgram.Rds")
fivegram <- readRDS("data/ngram/fivegram.Rds")