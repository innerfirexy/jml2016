# plot entropy (and normalized) against within-episode position, aggregating all episode indexes
# (excluding episode indexes == 1)
# Yang Xu
# 4/8/2016

library(data.table)
library(ggplot2)

# load data
df.bnc = readRDS('bnc_df_c.rds')
df.swbd = readRDS('swbd_df_c.rds')

dt.bnc = data.table(df.bnc)
dt.swbd = data.table(df.swbd)

# exclude topicID == 1, and filter and add columns
dt.bnc.plot = dt.bnc[topicID > 1, .(ent, entc, topicID, inTopicID)]
dt.bnc.plot[, corpus := 'BNC']
dt.swbd.plot = dt.swbd[topicID > 1, .(ent, entc, topicID, inTopicID)]
dt.swbd.plot[, corpus := 'Switchboard']

# merge
dt.plot = rbindlist(list(dt.bnc.plot, dt.swbd.plot))

# plot
p1 = ggplot(dt.plot[inTopicID <= 15 & topicID <= 6,], aes(x = inTopicID, y = ent)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = corpus)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon', aes(fill = corpus), alpha = .5) +
    xlab('within-episode position') + ylab('entropy') +
    theme(legend.position = c(.2, .9))
pdf('e_vs_inPos_agg.pdf', 5, 5)
plot(p1)
dev.off()

p2 = ggplot(dt.plot[inTopicID <= 15 & topicID <= 6,], aes(x = inTopicID, y = entc)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = corpus)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon', aes(fill = corpus), alpha = .5) +
    xlab('within-episode position') + ylab('normalized entropy') +
    theme(legend.position = c(.2, .9))
pdf('ne_vs_inPos_agg.pdf', 5, 5)
plot(p2)
dev.off()
