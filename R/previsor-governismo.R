setwd('/var/www//html/twitter-protesto/')

library(RMongo)

## Conectar no banco

db <- mongoDbConnect('twitter', host='192.168.0.10')


print(dbShowCollections(db))


## Baixar um banco aleatório
result = dbGetQuery(db, "dilma_16_ago", "{}", 0, 1000)

result = select(result, text)


write.csv(result, 'textos_twitter.csv', row.names=FALSE)

## Dividir em teste e treino

## Criar o classificador

exemplo_grid

teste <- mongo.find.all(db, "twitter.dilma_16_ago", list('timestamp_ms' = list('$lte' = '1439240400000')))
