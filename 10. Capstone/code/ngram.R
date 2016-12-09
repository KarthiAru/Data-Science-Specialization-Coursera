# function to generate 1, 2, 3, 4 and 5 grams

gram1 <- function(frag_clean){
  unigram <- ngram(frag_clean, 1)
  unigram <- data.table(get.phrasetable(unigram))
  setDT(unigram)[,prop:=NULL]
  setDT(unigram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""))]
  setnames(unigram, c("uni","n1"))
  return(unigram)
}

gram2 <- function(frag_clean){
  bigram <- ngram(frag_clean, 2)
  bigram <- data.table(get.phrasetable(bigram))
  setDT(bigram)[,prop:=NULL]
  setDT(bigram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                      uni = word(ngrams, 1,1),
                      word =  word(ngrams, 2,2))]
  setDT(bigram)[,`:=`(ngrams = NULL)]
  setcolorder(bigram, c("uni","word","freq"))
  setnames(bigram, c("uni","word","n2"))
  return(bigram)
}

gram3 <- function(frag_clean){
  trigram <- ngram(frag_clean, 3)
  trigram <- data.table(get.phrasetable(trigram))
  setDT(trigram)[,prop:=NULL]
  setDT(trigram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                       bi = word(ngrams, 1,2),
                       word =  word(ngrams, 3,3))]
  setDT(trigram)[,`:=`(ngrams = NULL)]
  setcolorder(trigram, c("bi","word","freq"))
  setnames(trigram, c("bi","word","n3"))
  return(trigram)
}

gram4 <- function(frag_clean){
  fourgram <- ngram(frag_clean, 4)
  fourgram <- data.table(get.phrasetable(fourgram))
  setDT(fourgram)[,prop:=NULL]
  setDT(fourgram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                        tri = word(ngrams, 1,3),
                        word =  word(ngrams, 4,4))]
  setDT(fourgram)[,`:=`(ngrams = NULL)]
  setcolorder(fourgram, c("tri","word","freq"))
  setnames(fourgram, c("tri","word","n4"))
  return(fourgram)
}

gram5 <- function(frag_clean){
  fivegram <- ngram(frag_clean, 5)
  fivegram <- data.table(get.phrasetable(fivegram))
  setDT(fivegram)[,prop:=NULL]
  setDT(fivegram)[,`:=`(ngrams = stri_replace_all(ngrams, regex = "^ +|(?<= ) +| +$", replacement = ""),
                        four = word(ngrams, 1,4),
                        word =  word(ngrams, 5,5))]
  setDT(fivegram)[,`:=`(ngrams = NULL)]
  setcolorder(fivegram, c("four","word","freq"))
  setnames(fivegram, c("four","word","n5"))
  return(fivegram)
}

#fivegram

join_grams <- function(inc,max_iter,gram,prefix,ncol,frag_path,save_path){
  
  timer_all <- Sys.time()
  
  #Initialize empty data table
  if (gram == 'bigram') x <-data.table(uni = character(0), word = character(0), n2 = numeric(0))
  else if (gram == 'trigram') x <-data.table(bi = character(0), word = character(0), n3 = numeric(0))
  else if (gram == 'fourgram') x <-data.table(tri = character(0), word = character(0), n4 = numeric(0))
  else if (gram == 'fivegram') x <-data.table(four = character(0), word = character(0), n5 = numeric(0))
  else x <-data.table(uni = character(0), n1 = numeric(0))
  
  start <- 1; end <- inc
  pb <- txtProgressBar(max=max_iter, style = 3)
  
  if(gram == 'unigram'){
    for(j in 1:max_iter){
      x_frag <- foreach(i=start:end,
                        .combine=function(x,y)rbindlist(list(x,y))) %dopar% readRDS(paste0(frag_path,i,".RDS"))
      x_frag <- x_frag[, lapply(.SD, sum), by=c(prefix), .SDcols=c(ncol)]
      x <- rbindlist(list(x,x_frag))
      x <- x[, lapply(.SD, sum), by=c(prefix), .SDcols=c(ncol)]
      start <- start+inc; end <- end+inc
      if(end == 6000) end <- 5999
      setTxtProgressBar(pb, j)
    }
  }
  else{
    for(j in 1:max_iter){
      x_frag <- foreach(i=start:end,
                        .combine=function(x,y)rbindlist(list(x,y))) %dopar% readRDS(paste0(frag_path,i,".RDS"))
      x_frag <- x_frag[, lapply(.SD, sum), by=c(prefix,'word'), .SDcols=c(ncol)]
      x <- rbindlist(list(x,x_frag))
      x <- x[, lapply(.SD, sum), by=c(prefix,'word'), .SDcols=c(ncol)]
      start <- start+inc; end <- end+inc
      if(end == 6000) end <- 5999
      setTxtProgressBar(pb, j)
    }
  }
  close(pb)
  difftime(Sys.time(), timer_all, tz = "", units = "mins")
  x <- x[complete.cases(x)]
  setkeyv(x,ncol)
  x <- x[.(c(2:1e7)), nomatch=0L]
  setkey(x,NULL)
  saveRDS(x,file = save_path,compress=TRUE)
}