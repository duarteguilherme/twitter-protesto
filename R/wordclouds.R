setwd('/var/www//html/twitter-protesto/')

`%p%` <- function(e1, e2) {
  return(paste0(e1, e2))
}


library(rmongodb)
library(dplyr)
library(tm)
library(SnowballC)

library(wordcloud)

db <- mongo.create(host='192.168.0.10', db="twitter")



# Não quero numero cientifico
options("scipen"=100, "digits"=4)

## Criar separação de horários

d_time <- function(x) {
  return(as.POSIXlt((x/1000), origin="1970-01-01", tz="America/Sao_Paulo"))
}
r_time <- function(x) {
  return(as.vector(x))
}


## Vários grids

## Começa dia 2015-08-10 17:44:56 BRT
## Entaõ vamos começar às 18

first_time <- as.POSIXct("2015-08-10 18:00:00 BRT", origin="1970-01-01", tz="America/Sao_Paulo")

tempo <- first_time
for (i in 2:140) {
tempo[i] <- tempo[i-1] + 3600
}

grid_tempo <- data.frame(initial_time=sapply(tempo, r_time))


grid_tempo$initial_time <- grid_tempo$initial_time*1000

grid_tempo$final_time <- lead(grid_tempo$initial_time)

### Depois criar wordcloud pra cada

# Usemos só o primeiro intervalo como exemplo


# Define lista dos dados


dados_twitter <- list()
for (linha in 51:nrow(grid_tempo)) {
# for (linha in 1:2) {
  print(linha)
  exemplo_grid <- grid_tempo[linha,]
  twits <- mongo.find.all(db, "twitter.dilma_16_ago", 
                        list('timestamp_ms' = list('$lt' = as.character(exemplo_grid$final_time)),
                             'timestamp_ms' = list('$gt' = as.character(exemplo_grid$initial_time))                           
                        )                  
  )
  docs <- sapply(twits, function(x) {
    return(x[['text']])
  })
  rm(twits)
  ntwits <- length(docs)
  if ( ntwits == 0 ) {
    d <- data.frame(word = 0,freq=0, ntwits)
    dados_twitter[[as.character(exemplo_grid$initial_time)]] <- head(d, 100) 
    next
  }
  retira_parte_retweet <- function(x) {
    palavra_um <- strsplit(x, " ")
    if (palavra_um[[1]][1] == "RT") {
      x <- sub("@[A-Za-z0-9_]*", "", x)
      x <- sub("RT", "", x)
    }
    return(x)
  }
  
  for (i in 1:length(docs)) {
    docs[i] <- retira_parte_retweet(docs[i])
  }
  docs <- gsub("http[^[:space:]]*", "", docs)
  # Analisando texto
  docs <- VCorpus(VectorSource(docs))
  docs <- tm_map(docs, stripWhitespace)
  docs <- tm_map(docs, content_transformer(tolower))
  docs <- tm_map(docs, removePunctuation)
  docs <- tm_map(docs, removeNumbers)
  docs <- tm_map(docs, function(x) removeWords(x, stopwords("portuguese")))
  myDTM = TermDocumentMatrix(docs, control = list(minWordLength = 1))
  rm(docs)
  m <- as.matrix(myDTM)
  rm(myDTM)
  v <- sort(rowSums(m),decreasing=TRUE)
  rm(m)
  d <- data.frame(word = names(v),freq=v)
  tempo <- list()
  tempo[["d"]] <- head(d, 100)
  tempo[["ntwits"]] <- ntwits
  rm(d)
  rm(v)
  dados_twitter[[as.character(exemplo_grid$initial_time)]] <- tempo  
  rm(ntwits)
}




## 

### Vamos criar JSON


library(RJSONIO)
db_json <- toJSON(dados_twitter)
write(db_json, 'wordclouds-51-ate-.json')


#####
pal <- brewer.pal(30, "BuGn")
pal <- pal[-(1:2)]
wordcloud(d$word,d$freq, scale=c(8,.3),min.freq=2,max.words=100, random.order=T, rot.per=.15, colors=pal, vfont=c("sans serif","plain"))
## Inicar operação wordcloud


