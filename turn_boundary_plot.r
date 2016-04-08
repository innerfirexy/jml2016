# Generate the plot of entropy vs. relative sentence position within speaking turns
# Yang Xu
# 4/7/2016

library(data.table)
library(ggplot2)
library(gridExtra)

# the function that gets the legend of a plot (for multiple plotting that shares one legend)
g_legend = function(p) {
    tmp = ggplotGrob(p)
    leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend = tmp$grobs[[leg]]
    legend
}

# load data
df.bnc = readRDS('bnc_df_c.rds')
df.swbd = readRDS('swbd_df_c.rds')

dt.bnc = data.table(df.bnc)
dt.swbd = data.table(df.swbd)


# set keys
setkey(dt.bnc, convID, turnID)
setkey(dt.swbd, convID, turnID)

## turn length == 2
# create the dt for plot
dt.bnc.tmp2 = dt.bnc[turnLen == 2 & turnID > 1, {
        if (.N == 2) {
            sentence1 = entc[1]
            sentence2 = entc[2]
            pre_row = .I[1] - 1
            preceding = dt.bnc[pre_row, entc]
            fol_row = .I[2] + 1
            following = ifelse(dt.bnc[fol_row, convID] == convID[1], dt.bnc[fol_row, entc], NaN)
            .(preceding = preceding, sentence1 = sentence1, sentence2 = sentence2, following = following)
        }
    }, by = .(convID, turnID)]
dt.bnc.p2 = melt(dt.bnc.tmp2, id.vars = c('convID', 'turnID'),
    measure.vars = c('preceding', 'sentence1', 'sentence2', 'following'),
    variable.name = 'relPos', value.name = 'entc')

dt.swbd.tmp2 = dt.swbd[turnLen == 2 & turnID > 1, {
        if (.N == 2) {
            sentence1 = entc[1]
            sentence2 = entc[2]
            pre_row = .I[1] - 1
            preceding = dt.swbd[pre_row, entc]
            fol_row = .I[2] + 1
            following = ifelse(dt.swbd[fol_row, convID] == convID[1], dt.swbd[fol_row, entc], NaN)
            .(preceding = preceding, sentence1 = sentence1, sentence2 = sentence2, following = following)
        }
    }, by = .(convID, turnID)]
dt.swbd.p2 = melt(dt.swbd.tmp2, id.vars = c('convID', 'turnID'),
    measure.vars = c('preceding', 'sentence1', 'sentence2', 'following'),
    variable.name = 'relPos', value.name = 'entc')

# rbind
dt.bnc.p2$corpus = 'BNC'
dt.swbd.p2$corpus = 'Switchboard'
dt.p2 = rbindlist(list(dt.bnc.p2, dt.swbd.p2))

# plot
p2 = ggplot(dt.p2, aes(x = relPos, y = entc, group = corpus)) +
    stat_summary(fun.y = mean, geom = 'line', aes(color = corpus, lty = corpus)) + #
    stat_summary(fun.y = mean, geom = 'point', aes(color = corpus, shape = corpus), size = 2) +
    stat_summary(fun.data = mean_cl_normal, geom = 'errorbar', aes(color = corpus, lty = corpus),
        width = .2) +
    xlab('relative sentence position') + ylab('normalized entropy') +
    theme(legend.position = c(.85, .9))
pdf('ne_vs_relPos_tl2.pdf', 5, 5)
plot(p2)
dev.off()


## turn length == 3
# create the dt for plot
dt.bnc.tmp3 = dt.bnc[turnLen == 3 & turnID > 1, {
        if (.N == 3) {
            sentence1 = entc[1]
            sentence2 = entc[2]
            sentence3 = entc[3]
            pre_row = .I[1] - 1
            preceding = dt.bnc[pre_row, entc]
            fol_row = .I[3] + 1
            following = ifelse(dt.bnc[fol_row, convID] == convID[1], dt.bnc[fol_row, entc], NaN)
            .(preceding = preceding, sentence1 = sentence1, sentence2 = sentence2,
                sentence3 = sentence3, following = following)
        }
    }, by = .(convID, turnID)]
dt.bnc.p3 = melt(dt.bnc.tmp3, id.vars = c('convID', 'turnID'),
    measure.vars = c('preceding', 'sentence1', 'sentence2', 'sentence3', 'following'),
    variable.name = 'relPos', value.name = 'entc')

dt.swbd.tmp3 = dt.swbd[turnLen == 3 & turnID > 1, {
        if (.N == 3) {
            sentence1 = entc[1]
            sentence2 = entc[2]
            sentence3 = entc[3]
            pre_row = .I[1] - 1
            preceding = dt.swbd[pre_row, entc]
            fol_row = .I[3] + 1
            following = ifelse(dt.swbd[fol_row, convID] == convID[1], dt.swbd[fol_row, entc], NaN)
            .(preceding = preceding, sentence1 = sentence1, sentence2 = sentence2,
                sentence3 = sentence3, following = following)
        }
    }, by = .(convID, turnID)]
dt.swbd.p3 = melt(dt.swbd.tmp3, id.vars = c('convID', 'turnID'),
    measure.vars = c('preceding', 'sentence1', 'sentence2', 'sentence3', 'following'),
    variable.name = 'relPos', value.name = 'entc')

# rbind
dt.bnc.p3$corpus = 'BNC'
dt.swbd.p3$corpus = 'Switchboard'
dt.p3 = rbindlist(list(dt.bnc.p3, dt.swbd.p3))

# plot
p3 = ggplot(dt.p3, aes(x = relPos, y = entc, group = corpus)) +
    stat_summary(fun.y = mean, geom = 'line', aes(color = corpus, lty = corpus)) + #
    stat_summary(fun.y = mean, geom = 'point', aes(color = corpus, shape = corpus), size = 2) +
    stat_summary(fun.data = mean_cl_normal, geom = 'errorbar', aes(color = corpus, lty = corpus),
        width = .2) +
    xlab('relative sentence position') + ylab('normalized entropy') +
    theme(legend.position = c(.85, .9))
pdf('ne_vs_relPos_tl3.pdf', 5, 5)
plot(p3)
dev.off()
