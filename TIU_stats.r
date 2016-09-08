# calculate the mean, median and SD of TIUs according to its first original definition
# Yang Xu
# 4/12/2016

library(data.table)

# load
df.bnc = readRDS('bnc_df_c.rds')
df.swbd = readRDS('swbd_df_c.rds')

dt.bnc = data.table(df.bnc)
dt.swbd = data.table(df.swbd)

setkey(dt.bnc, convID)
setkey(dt.swbd, convID)


# BNC
boundIndex.bnc = dt.bnc[, .(rowIndex = .I[which(inTopicID == 1 & topicID > 1)])]
boundIndex.bnc.within = c()
for (i in 1:nrow(boundIndex.bnc)) {
    idx = boundIndex.bnc$rowIndex[i]
    if (dt.bnc[idx, turnID] == dt.bnc[idx-1, turnID]) {
        boundIndex.bnc.within = c(boundIndex.bnc.within, idx)
    }
}
boundIndex.bnc.between = setdiff(boundIndex.bnc$rowIndex, boundIndex.bnc.within)

mean(dt.bnc[boundIndex.bnc.within, wordNum]) # 25.34
median(dt.bnc[boundIndex.bnc.within, wordNum]) # 15

mean(dt.bnc[boundIndex.bnc.between, wordNum]) # 9.71
median(dt.bnc[boundIndex.bnc.between, wordNum]) # 5

# the stats of word length rgdl of within or btw
mean(dt.bnc[boundIndex.bnc, wordNum], na.rm = T) # 8.28
median(dt.bnc[boundIndex.bnc, wordNum], na.rm = T) # 5
# distr
plot(density(dt.bnc[boundIndex.bnc, wordNum], na.rm = T))
plot(density(dt.bnc[boundIndex.bnc, log(wordNum)], na.rm = T))


## Switchboard
boundIndex.swbd = dt.swbd[, .(rowIndex = .I[which(inTopicID == 1 & topicID > 1)])]
boundIndex.swbd.within = c()
for (i in 1:nrow(boundIndex.swbd)) {
    idx = boundIndex.swbd$rowIndex[i]
    if (dt.swbd[idx, turnID] == dt.swbd[idx-1, turnID]) {
        boundIndex.swbd.within = c(boundIndex.swbd.within, idx)
    }
}
boundIndex.swbd.between = setdiff(boundIndex.swbd$rowIndex, boundIndex.swbd.within)

# stats
mean(dt.swbd[boundIndex.swbd.within, wordNum]) # 18.3
median(dt.swbd[boundIndex.swbd.within, wordNum]) # 13

mean(dt.swbd[boundIndex.swbd.between, wordNum]) # 5.9
median(dt.swbd[boundIndex.swbd.between, wordNum]) # 1

mean(dt.swbd[boundIndex.swbd, wordNum], na.rm = T) # 9.9
median(dt.swbd[boundIndex.swbd, wordNum], na.rm = T) # 6

plot(density(dt.swbd[boundIndex.swbd, wordNum], na.rm = T))
plot(density(dt.swbd[boundIndex.swbd, log(wordNum)], na.rm = T))
