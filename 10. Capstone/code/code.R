#----------------------------------- Amazon EC2 config ---------------------------------- 

#----------------------------------- Total execution time -------------------------------

#----------------------------------- Folder Structure ----------------------------------- 

# Capstone
#   |_ code
#       |_ code.R
#       |_ parse.R
#       |_ ngram.R
#       |_ predict.R
#   |_ data
#       |_ blogs.RDS
#       |_ news.RDS
#       |_ twitter.RDS
#       |_ fragment
#           |_ <frag1.RDS>....<fragn.RDS>
#       |_ ngram
#           |_ unigram.RDS
#           |_ bigram.RDS
#           |_ trigram.RDS
#           |_ fourgram.RDS
#           |_ fivegram.RDS
#           |_ unigram
#               |_ <unigram_1.RDS>....<unigram_n.RDS>
#           |_ bigram
#               |_ <bigram_1.RDS>....<bigram_n.RDS>
#           |_ trigram
#               |_ <trigram_1.RDS>....<trigram_n.RDS>
#           |_ fourgram
#               |_ <fourgram_1.RDS>....<fourgram_n.RDS>
#           |_ fivegram
#               |_ <fivegram_1.RDS>....<fivegram_n.RDS>

#----------------------------------- 1. Set folder path & options -----------------------------------
setwd("~/Dropbox/Capstone")
options("scipen"=7) #fixed notation over exponential notation for significant digits upto a maximum difference of 7 digits

#----------------------------------- 2. Initialize libraries -----------------------------------
library(data.table) # enhanced data.frame for fast subset, grouping and update to store the ngrams
library(stringi) # string processing package for iconv, stri_trans_general, stri_replace_all
library(magrittr) # %>% operator to improve the code by avoiding local variables and nested function calls
library(foreach) # facilitate parallel loop execution with %dopar% operator
library(doSNOW) # parallel backend for the foreach's %dopar% function using SNOW (Simple Network of Workstations) package
library(ngram)
library(stringr)
#----------------------------------- 3. Create clusters -----------------------------------
cores <- parallel::detectCores()
cl <- makeSOCKcluster(cores) # start a socket cluster for the numbers of cores available to enable those many parallel R processes
registerDoSNOW(cl) # register the SNOW parallel backend with the foreach package

#----------------------------------- 4. Data fragmentation -----------------------------------
blog <- readRDS("data/blogs.RDS")
news <- readRDS("data/news.RDS")
twitter <- readRDS("data/twitter.RDS")
corpus <- c(blog,news,twitter)
rm(list=c('blog','news','twitter'))

#test corpus
set.seed(123)
sample_size <- 0.01
n <- length(corpus)
corpus <- sample(corpus, n*sample_size, replace = FALSE, prob = NULL)

#Parameters
n <- length(corpus)
frag_parts <- 6000
frag_size <- ceiling(n/frag_parts)
start <-1
end <- frag_size
path="data/fragment/frag"

#Split
timer_all <- Sys.time()
cat("\n----------Creating Fragments----------\n")
pb <- txtProgressBar(max=frag_parts, style = 3)
for(i in 1:frag_parts){
  assign(paste0("frag",i),corpus[start:end])
  saveRDS(get(paste0("frag",i)),file = paste0(path,i,".RDS"),compress=TRUE)
  rm(list=Filter(exists, paste0("frag", i)))
  start <- end+1
  end <- start+frag_size-1
  if(end>n) end <- n
  setTxtProgressBar(pb, i)
}
close(pb)
rm(corpus)
cat("\n***Process completed in",round(difftime(Sys.time(), timer_all, tz = "", units = "mins"),2),"min!***")

#----------------------------------- 5. Data cleaning and parsing -----------------------------------
source('code/parse.R')

timer_all <- Sys.time()
cat("\n----------Cleaning Fragments----------\n")
pb <- txtProgressBar(max=frag_parts-1, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress=progress)
null <- foreach(i = 1:(frag_parts-1),
                .packages=c('dplyr','stringi'),
                .options.snow=opts) %dopar% {
                  x <- readRDS(paste0(path,i,".RDS"))
                  x <- parse(x)
                  saveRDS(x,file = paste0(path,i,".RDS"),compress=TRUE)
                }    
close(pb)
cat("\n***Process completed in",round(difftime(Sys.time(), timer_all, tz = "", units = "mins"),2),"min!***")

#----------------------------------- 6. Split to n-grams fragments -----------------------------------
source('code/ngram.R')

frag_parts = 8

timer_all <- Sys.time()
pb <- txtProgressBar(max=frag_parts, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress=progress)
null <- foreach(i = seq,
                .packages=c('data.table','ngram','stringr','stringi'),
                .options.snow=opts) %dopar% {
                  x <- readRDS(paste0(path,i,".RDS"))
                  saveRDS(gram1(x),file = paste0("data/ngram/unigram/unigram_",i,".RDS"),compress=TRUE)
                  saveRDS(gram2(x),file = paste0("data/ngram/bigram/bigram_",i,".RDS"),compress=TRUE)
                  saveRDS(gram3(x),file = paste0("data/ngram/trigram/trigram_",i,".RDS"),compress=TRUE)
                  saveRDS(gram4(x),file = paste0("data/ngram/fourgram/fourgram_",i,".RDS"),compress=TRUE)
                  saveRDS(gram5(x),file = paste0("data/ngram/fivegram/fivegram_",i,".RDS"),compress=TRUE)
                  rm(x)
                }
close(pb)
cat("\n***Process completed in",round(difftime(Sys.time(), timer_all, tz = "", units = "mins"),2),"min!***")

#----------------------------------- Validation of fragments -----------------------------------

seq <- c( 1742,  1744,  1751,  1755,  1757,  1758,  1767,  1768)

for(i in 1:5999) tryCatch(a <- readRDS(paste0("data/ngram/bigram/bigram_",i,".RDS")), error=function(e) cat("\n",i))
for(i in 1:5999) if (!file.exists(paste0("data/ngram/fivegram/fivegram_",i,".RDS"))) cat("\n",i)

#----------------------------------- 8. Join n-grams fragments -----------------------------------

join_grams(50,120,'unigram','uni','n1','data/ngram/unigram/unigram_','data/ngram/unigram1.RDS')
join_grams(50,120,'bigram','uni','n2','data/ngram/bigram/bigram_','data/ngram/bigram1.RDS')
join_grams(50,120,'trigram','bi','n3','data/ngram/trigram/trigram_','data/ngram/trigram1.RDS')
join_grams(50,120,'fourgram','tri','n4','data/ngram/fourgram/fourgram_','data/ngram/fourgram1.RDS')
join_grams(50,120,'fivegram','four','n5','data/ngram/fivegram/fivegram_','data/ngram/fivegram1.RDS')

#----------------------------------- 9. Compute Prob, Merge and Save n-grams -----------------------------------

#unigrams
unigram <- readRDS("data/ngram/unigram1.RDS")

#bigrams
bigram <- readRDS("data/ngram/bigram1.RDS")
setDT(bigram)[,`:=`(bi = paste(uni,word))]
bigram <- bigram[unigram, on="uni"]
setDT(bigram)[,`:=`(p = n2/n1)]

#trigrams
trigram <- readRDS("data/ngram/trigram1.RDS")
setDT(trigram)[,`:=`(tri = paste(bi,word))]
trigram <- trigram[bigram[, .SD, .SDcols = c('bi','n2')], on="bi"]
setDT(trigram)[,`:=`(p = n3/n2)]

#fourgrams
fourgram <- readRDS("data/ngram/fourgram1.RDS")
setDT(fourgram)[,`:=`(four = paste(tri,word))]
fourgram <- fourgram[trigram[, .SD, .SDcols = c('tri','n3')], on="tri"]
setDT(fourgram)[,`:=`(p = n4/n3)]

#fivegrams
fivegram <- readRDS("data/ngram/fivegram1.RDS")
setDT(fivegram)[,`:=`(five = paste(four,word))]
fivegram <- fivegram[fourgram[, .SD, .SDcols = c('four','n4')], on="four"]
setDT(fivegram)[,`:=`(p = n5/n4)]

#---------- Save files ----------
#unigrams
setnames(unigram, c("word","n") )
saveRDS(unigram,file = paste0("data/ngram/unigram.RDS"),compress=TRUE)

#bigrams
setDT(bigram)[,`:=`(bi = NULL, n1 = NULL)]
setnames(bigram, c("prefix","word","n","p") )
setkey(bigram,'prefix')
saveRDS(bigram,file = paste0("data/ngram/bigram.RDS"),compress=TRUE)

#trigrams
setDT(trigram)[,`:=`(tri = NULL, n2 = NULL)]
setnames(trigram, c("prefix","word","n","p") )
setkey(trigram,'prefix')
saveRDS(trigram,file = paste0("data/ngram/trigram.RDS"),compress=TRUE)

#fourgrams
setDT(fourgram)[,`:=`(four = NULL, n3 = NULL)]
setnames(fourgram, c("prefix","word","n","p") )
setkey(fourgram,'prefix')
saveRDS(fourgram,file = paste0("data/ngram/fourgram.RDS"),compress=TRUE)

#fivegrams
setDT(fivegram)[,`:=`(five = NULL, n4 = NULL)]
setnames(fivegram, c("prefix","word","n","p") )
setkey(fivegram,'prefix')
saveRDS(fivegram,file = paste0("data/ngram/fivegram.RDS"),compress=TRUE)

#----------------------------------- 7. Smoothing -----------------------------------

#lambda parameters
l4 = 0.4
l3 = 0.3
l2 = 0.2
l1 = 0.1

setDT(bigram)[,`:=`(p = p/l1)]
setDT(trigram)[,`:=`(p = p/l2)]
setDT(fourgram)[,`:=`(p = p/l3)]
setDT(fivegram)[,`:=`(p = p/l4)]

#
unigram <- readRDS("data/ngram/unigram.RDS")
bigram <- readRDS("data/ngram/bigram.RDS")
trigram <- readRDS("data/ngram/trigram.RDS")
fourgram <- readRDS("data/ngram/fourgram.RDS")
fivegram <- readRDS("data/ngram/fivegram.RDS")

setkey(fivegram,n);fivegram <- fivegram[.(c(10:1e7)), nomatch=0L];setkey(fivegram,NULL);setkey(fivegram,prefix)
setkey(fourgram,n);fourgram <- fourgram[.(c(10:1e7)), nomatch=0L];setkey(fourgram,NULL);setkey(fourgram,prefix)
setkey(trigram,n);trigram <- trigram[.(c(15:1e7)), nomatch=0L];setkey(trigram,NULL);setkey(trigram,prefix)
setkey(bigram,n);bigram <- bigram[.(c(15:1e7)), nomatch=0L];setkey(bigram,NULL);setkey(bigram,prefix)
setkey(unigram,n);unigram <- unigram[.(c(5:1e7)), nomatch=0L];setkey(unigram,NULL);setkey(unigram,word)

paste(object.size(unigram)/10^6,object.size(bigram)/10^6,object.size(trigram)/10^6,object.size(fourgram)/10^6,object.size(fivegram)/10^6)
object.size(unigram)/10^6+object.size(bigram)/10^6+object.size(trigram)/10^6+object.size(fourgram)/10^6+object.size(fivegram)/10^6

# prune 2: "22.645552 159.31692 551.699136 892.438048 868.012432"
# prune 3: "22.645552 91.212728 179.980984 159.447336 89.013224"
# prune 4: "22.645552 68.072128 121.519208 96.257152 47.65408"
# prune 5: "22.645552 55.113776 91.676808 67.335128 30.8334"
# prune 6: "22.645552 46.680368 73.560168 51.114792 30.8334"
# prune 7: "22.645552 40.701088 61.373216 51.114792 30.8334"

saveRDS(fivegram,file = paste0("data/ngram/fivegram.RDS"),compress=TRUE)
saveRDS(fourgram,file = paste0("data/ngram/fourgram.RDS"),compress=TRUE)
saveRDS(trigram,file = paste0("data/ngram/trigram.RDS"),compress=TRUE)
saveRDS(bigram,file = paste0("data/ngram/bigram.RDS"),compress=TRUE)
saveRDS(unigram,file = paste0("data/ngram/unigram.RDS"),compress=TRUE)

# file size in MB: 1.9 7.1 10.3 7.1 3.7
# file size total in MB: 30.1

#----------------------------------- 7. Terminate the clusters -----------------------------------
stopCluster(cl)

#----------------------------------- 10. Word Prediction -----------------------------------
source('code/predict.R')
source('code/clean.R')

#---------- Quiz 1 ----------

q1 <- "The guy in front of me just bought a pound of bacon, a bouquet, and a case of"
q2 <- "You're the reason why I smile everyday. Can you follow me please? It would mean the"
q3 <- "Hey sunshine, can you follow me and make me the"
q4 <- "Very early observations on the Bills game: Offense still struggling but the"
q5 <- "Go on a romantic date at the"
q6 <- "Well I'm pretty sure my granny has some old bagpipes in her garage I'll dust them off and be on my"
q7 <- "Ohhhhh #PointBreak is on tomorrow. Love that film and haven't seen it in quite some"
q8 <- "After the ice bucket challenge Louis will push his long wet hair out of his eyes with his little"
q9 <- "Be grateful for the good times and keep the faith during the"
q10 <- "If this isn't the cutest thing you've ever seen, then you must be"

for(i in 1:10){
  cat("\n",predict_word(get(paste0("q",i)),10))
}

#---------- Quiz 2 ----------

q1 <- "When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd"
q2 <- "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
q3 <- "I'd give anything to see arctic monkeys this"
q4 <- "Talking to your mom has the same effect as a hug and helps reduce your"
q5 <- "When you were in Holland you were like 1 inch away from me but you hadn't time to take a"
q6 <- "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"
q7 <- "I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each"
q8 <- "Every inch of you is perfect from the bottom to the"
q9 <- "I'm thankful my childhood was filled with imagination and bruises from playing"
q10 <- "I like how the same people are in almost all of Adam Sandler's"

for(i in 1:10){
  cat("\n",predict_word(get(paste0("q",i)),10))
}

# ----------------------------------- Quiz Accuracy Result -----------------------------------

#----- Final Test  ----- 
# Sample-size: 100% (prune 7)
# Algorithm: MLE
# Top 3: 9/20

#----- Test  ----- 
# Sample-size: 100% (prune 1)
# Algorithm: MLE
# Top 3: /20

#----- Test  ----- 
# Sample-size: 100% (prune 1)
# Algorithm: Stupid Backoff
# Top 3: 9/20

#----- Test 1 ----- 
# Sample-size: 1% (with _START_ & _END_ tags)
# Algorithm: MLE
# Top 3: 3/20

#----- Test 2 ----- 
# Sample-size: 10% (without _START_ & _END_ tags)
# Algorithm: MLE
# Top 3: 6/20, ~8/20

#----- Test 3 ----- 
# Sample-size: 30%
# Algorithm: MLE
# Top 3: 7/20

# beer      the a beer                  beer the a                  beer the a                  the Lena picking            the mistaken a          the mistaken a      the mistaken a        the a mistaken
# world     world difference same       world WORLD difference      world difference same       world people right          world most demolition   world most one      world most one        world loss entire
# happiest  happiest most way           happiest _NUM_ most         happiest _NUM_ most         other grace same            happiest most same      happiest most same  happiest most same    happiest most same
# defense   _NUM_ first same            _NUM_ best fact             _NUM_ first same            best _NUM_ results          _NUM_ first same        _NUM_ first same    _NUM_ way best        best _NUM_ fact
# grocery   end same time               end same time               end same time               end same time               time Power art          end same time       end same time         end same time
# way       way own mind                own way mind                own way mind                _NUM_ show bike             way mind own            way mind own        way mind own          own way mind
# time      time of people              time of people              time of people              time of people              time of tradition       time of people      time of people        time of way
# fingers   brother bit sister          brother sister girl         brother sister bit          hand personality brothers   legs brother heart      heart bit hand      heart hand brother's  brother sister bit
# bad       _NUM_ day first             _NUM_ day first             _NUM_ day first             _NUM_ day first             _NUM_ day first         _NUM_ day first     _NUM_ day first       _NUM_ day first
# insane    a the so                    a so the                    a the so                    willing touched disciplined a blind so              a so wondering      a so wondering        a able so
# die       like be love                like be love                like be love                like love leave             like be love            like be love        like be love          like be love
# marital   own first new               day new own                 day new own                 _NUM_ daughter crazy        Detroit payments vision own work first      work past life        work life own
# weekend/morning   is year week        is year week        is year week        is year week        is year week            is year week        is year week          is year week
# stress    risk own life               risk exposure stress        risk exposure stress        own favorite life           risk outgoings stress   risk own life       risk own life         risk electricity usage
# picture   look break nap              look break nap              look break nap              swing look shower           swing tropical long     look picture _NUM_  look picture _NUM_    nap break picture
# matter    case issue matter           case issue matter           case issue matter           score frivolous things      case frivolous things   case _NUM_ first    case _NUM_ first      case debt issue
# hand      of other day                of other other's            of other day                of other square             of other day            of other day        of other direction    of other other's
# top       top _NUM_ first             top _NUM_ next              top _NUM_ first             _NUM_ first same            top beginning _NUM_     top _NUM_ first     top _NUM_ public      top _NUM_ point
# outside   the in with                 the in with                 the in with                 sports with in              basketball sports with  basketball with in  basketball with in    the in basketball
# movies                                Jack character              Jack character                                          _NUM_

# ----------------------------------- Benchmark Result -----------------------------------

#----- Final Test  ----- 
# Sample-size: 100% (prune 7)
# Algorithm: MLE
# Benchmark sample: 100%
# Overall top-3 score:     16.52 %
# Overall top-1 precision: 12.24 %
# Overall top-3 precision: 20.22 %
# Average runtime:         48.24 msec
# Number of predictions:   28464
# Total memory used:       198.11 MB


#----- Test  ----- 
# Sample-size: 100% (prune 2 and lambda)
# Algorithm: MLE
# Benchmark sample: 100%
# Overall top-3 score:     17.22 %
# Overall top-1 precision: 12.65 %
# Overall top-3 precision: 21.16 %
# Average runtime:         58.27 msec
# Number of predictions:   28464
# Total memory used:       428.15 MB

#----- Test  ----- 
# Sample-size: 100% (prune 2)
# Algorithm: MLE
# Benchmark sample: 100%
# Overall top-3 score:     16.97 %
# Overall top-1 precision: 12.57 %
# Overall top-3 precision: 20.77 %
# Average runtime:         61.03 msec
# Number of predictions:   28464
# Total memory used:       428.15 MB

#----- Test  ----- 
# Sample-size: 100% (prune 1 and lambda)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     17.10 %
# Overall top-1 precision: 12.54 %
# Overall top-3 precision: 21.16 %
# Average runtime:         59.55 msec
# Number of predictions:   4173
# Total memory used:       2379.74 MB

#----- Test  ----- 
# Sample-size: 100% (prune 2 and lambda)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     17.11 %
# Overall top-1 precision: 12.56 %
# Overall top-3 precision: 21.14 %
# Average runtime:         57.49 msec
# Number of predictions:   4173
# Total memory used:       583.61 MB

#----- Test  ----- 
# Sample-size: 100% (prune 3 and lambda)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     16.95 %
# Overall top-1 precision: 12.42 %
# Overall top-3 precision: 20.89 %
# Average runtime:         57.42 msec
# Number of predictions:   4173
# Total memory used:       428.15 MB

#----- Test 1 ----- 
# Sample-size: 1% (with _START_ & _END_ tags)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     12.27 %
# Overall top-1 precision: 8.83 %
# Overall top-3 precision: 15.35 %
# Average runtime:         25.84 msec
# Number of predictions:   4173
# Total memory used:       240.53 MB

#----- Test 2 ----- 
# Sample-size: 10% (without _START_ & _END_ tags)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     15.04 %
# Overall top-1 precision: 11.02 %
# Overall top-3 precision: 18.88 %
# Average runtime:         42.64 msec
# Number of predictions:   4173
# Total memory used:       1719.99 MB

#----- Test 3 ----- 
# Sample-size: 10% (with pruning <1)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     15.83 %
# Overall top-1 precision: 11.95 %
# Overall top-3 precision: 19.49 %
# Average runtime:         40.52 msec
# Number of predictions:   4173
# Total memory used:       192.00 MB

#----- Test 4 ----- 
# Sample-size: 10% (with pruning <1 and lambda 0.44,0.32,0.16,0.08)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     15.89 %
# Overall top-1 precision: 11.68 %
# Overall top-3 precision: 19.50 %
# Average runtime:         32.13 msec
# Number of predictions:   4173
# Total memory used:       105.33 MB

#----- Test 5 ----- 
# Sample-size: 30% (with pruning <1 and lambda 0.44,0.32,0.16,0.08)
# Algorithm: MLE
# Benchmark sample: tweets-100, blogs-100
# Overall top-3 score:     16.58 %
# Overall top-1 precision: 11.97 %
# Overall top-3 precision: 20.46 %
# Average runtime:         44.19 msec
# Number of predictions:   4173
# Total memory used:       315.96 MB
