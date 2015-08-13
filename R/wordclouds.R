setwd('/var/www//html/twitter-protesto/')

`%p%` <- function(e1, e2) {
  return(paste0(e1, e2))
}


library(rmongodb)
library(dplyr)
db <- mongo.create(host='192.168.0.10', db="twitter")





## Criar separação de horários

d_time <- function(x) {
  return(as.POSIXlt((x/1000), origin="1970-01-01", tz="America/Sao_Paulo"))
}
r_time <- function(x) {
  return(as.vector(x))
}

"2014-06-27 19:26:18"

## Vários grids

## Começa dia 2015-08-10 17:44:56 BRT
## Entaõ vamos começar às 18

first_time <- as.POSIXct("2015-08-10 18:00:00 BRT", origin="1970-01-01", tz="America/Sao_Paulo")

tempo <- first_time
for (i in 2:50) {
tempo[i] <- tempo[i-1] + 3600
}

grid_tempo <- data.frame(initial_time=sapply(tempo, r_time))


grid_tempo$initial_time <- grid_tempo$initial_time*1000

grid_tempo$final_time <- lead(grid_tempo$initial_time)

### Depois criar wordcloud pra cada

# Usemos só o primeiro intervalo como exemplo
exemplo_grid <- grid_tempo[1,]

busca <- '{ $and: [ { "timestamp_ms" : { $lte: ' %p% exemplo_grid$final_time %p% '}},
{"timestamp_ms" : { $gte: ' %p% exemplo_grid$initial_time %p% '} } ]}'

busca2 <- '{ "_id" : "55c90e5ec8c8af0700888479"  }'



exemplo_grid

json_qry <- 
  '{ "timestamp_ms: {
  "$and" : [ 
    {"$lte": "1439244000000" }, 
    {"$gte": "1439240400000"  } 
  ] 
} } '

library(jsonlite)

list('$gte' = '1439240400000')
list('$lt' = '1439244000000'),


teste <- mongo.find.all(db, "twitter.dilma_16_ago", 
                          list('timestamp_ms' = list('$lt' = '1439244000000'),
                               'timestamp_ms' = list('$gt' = '1339240400000')
                            
                            )
                          
              
)
