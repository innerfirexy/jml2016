# Count how many episodes are there in a dialogue, and how many sentences are there in an episode
# Yang Xu
# 4/28/2016

library(RMySQL)
library(data.table)

# ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
conn = dbConnect(MySQL(), host = '127.0.0.1', user = 'yang', port = 1234, password = "05012014", dbname = 'bnc')
sql = 'select convId, episodeId, inEpisodeId from entropy_DEM_full where episodeId is not null'
df.bnc = dbGetQuery(conn, sql)
dt.bnc = data.table(df.bnc)

conn = dbConnect(MySQL(), host = '127.0.0.1', user = 'yang', port = 1234, password = "05012014", dbname = 'swbd')
sql = 'select convID, tileID, inTileID from entropy where tileID is not null'
df.swbd = dbGetQuery(conn, sql)
dt.swbd = data.table(df.swbd)


# Switchboard
setkey(dt.swbd, convID, tileID)
swbd1 = dt.swbd[, length(unique(tileID)), by = convID]
mean(swbd1$V1) # 12.1
sd(swbd1$V1) # 4.3

swbd2 = dt.swbd[, .N, by = .(convID, tileID)]
mean(swbd2$N) # 11.7
sd(swbd2$N) # 10.6

# BNC
setkey(dt.bnc, convId, episodeId)
bnc1 = dt.bnc[, length(unique(episodeId)), by = convId]
mean(bnc1$V1) # 7.1
sd(bnc1$V1) # 10.8

bnc2 = dt.bnc[, .N, by = .(convId, episodeId)]
mean(bnc2$N) # 12.4
sd(bnc2$N) # 8.3
