# Plot normalized entropy against global position, grouped by turn-starting vs. non-turn-starting
# Yang Xu
# 4/8/2016

library(data.table)
library(ggplot2)

# load data
df.bnc = readRDS('bnc_df_c.rds')
df.swbd = readRDS('swbd_df_c.rds')

dt.bnc = data.table(df.bnc)
dt.swbd = data.table(df.swbd)

# filter and add group column
dt.bnc.plot = dt.bnc[turnLen > 1,]
dt.bnc.plot[, group := 'non-turn-starting']
dt.bnc.plot[localID == 1, group := 'turn-starting']

dt.swbd.plot = dt.swbd[turnLen > 1,]
dt.swbd.plot[, group := 'non-turn-starting']
dt.swbd.plot[localID == 1, group := 'turn-starting']


# plot
p1 = ggplot(dt.bnc.plot, aes(x = globalID, y = entc)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = group)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon', aes(fill = group), alpha = .5) +
    xlab('global position') + ylab('normalized entropy') +
    theme(legend.position = c(.8, .9)) +
    guides(lty = guide_legend(title = 'sentence type'),
        fill = guide_legend(title = 'sentence type'))
pdf('ne_vs_glbPos_turnStart_bnc.pdf', 5, 5)
plot(p1)
dev.off()

p2 = ggplot(dt.swbd.plot, aes(x = globalID, y = entc)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = group)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon', aes(fill = group), alpha = .5) +
    xlab('global position') + ylab('normalized entropy') +
    theme(legend.position = c(.8, .15)) +
    guides(lty = guide_legend(title = 'sentence type'),
        fill = guide_legend(title = 'sentence type'))
pdf('ne_vs_glbPos_turnStart_swbd.pdf', 5, 5)
plot(p2)
dev.off()
