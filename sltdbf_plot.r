# plot sentence length, tree depth, branching factor against within-episode position
# grouped by corpus and speaker roles
# Yang Xu
# 4/13/2016

library(data.table)
library(ggplot2)

# load
dt.bnc = readRDS('bnc.leader.tdbf.rds')
dt.swbd = readRDS('swbd.leader.new.rds')

# add group column
dt.bnc.tmp = dt.bnc[, .(wordNum, td, bf, inTopicID, byLeader)]
dt.bnc.tmp[, group := 'BNC: initiator']
dt.bnc.tmp[byLeader == F, group := 'BNC: responder']

dt.swbd.tmp = dt.swbd[, .(wordNum, td, bf, inTopicID, byLeader)]
dt.swbd.tmp[, group := 'Switchboard: initiator']
dt.swbd.tmp[byLeader == F, group := 'Switchboard: responder']

dt.all = rbindlist(list(dt.bnc.tmp, dt.swbd.tmp))


# get ggplot default colors
gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
my_colors = gg_color_hue(2)

# plot
p.sl = ggplot(subset(dt.all, inTopicID <= 10), aes(x = inTopicID, y = wordNum)) +
    stat_summary(fun.data = mean_cl_boot, geom = 'ribbon', alpha = .5, aes(fill = group)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = group)) +
    stat_summary(fun.y = mean, geom = 'point', aes(shape = group)) +
    scale_x_continuous(breaks = 1:10) +
    theme(legend.position = c(.8, .15)) +
    xlab('within-topic position of sentence') + ylab('sentence length (number of words)') +
    guides(fill = guide_legend(title = 'group'),
        lty = guide_legend(title = 'group'),
        shape = guide_legend(title = 'group')) +
    scale_fill_manual(values = c('BNC: initiator' = my_colors[2], 'BNC: responder' = my_colors[2],
        'Switchboard: initiator' = my_colors[1], 'Switchboard: responder' = my_colors[1])) +
    scale_linetype_manual(values = c('BNC: initiator' = 1, 'BNC: responder' = 3, 'Switchboard: initiator' = 1, 'Switchboard: responder' = 3)) +
    scale_shape_manual(values = c('BNC: initiator' = 1, 'BNC: responder' = 1, 'Switchboard: initiator' = 4, 'Switchboard: responder' = 4))
plot(p.sl)

p.td = ggplot(subset(dt.all, inTopicID <= 10), aes(x = inTopicID, y = td)) +
    stat_summary(fun.data = mean_cl_boot, geom = 'ribbon', alpha = .5, aes(fill = group)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = group)) +
    stat_summary(fun.y = mean, geom = 'point', aes(shape = group)) +
    scale_x_continuous(breaks = 1:10) +
    theme(legend.position = c(.8, .15)) +
    xlab('within-topic position of sentence') + ylab('tree depth') +
    guides(fill = guide_legend(title = 'group'),
        lty = guide_legend(title = 'group'),
        shape = guide_legend(title = 'group')) +
    scale_fill_manual(values = c('BNC: initiator' = my_colors[2], 'BNC: responder' = my_colors[2],
        'Switchboard: initiator' = my_colors[1], 'Switchboard: responder' = my_colors[1])) +
    scale_linetype_manual(values = c('BNC: initiator' = 1, 'BNC: responder' = 3, 'Switchboard: initiator' = 1, 'Switchboard: responder' = 3)) +
    scale_shape_manual(values = c('BNC: initiator' = 1, 'BNC: responder' = 1, 'Switchboard: initiator' = 4, 'Switchboard: responder' = 4))

p.bf = ggplot(subset(dt.all, inTopicID <= 10), aes(x = inTopicID, y = bf)) +
    stat_summary(fun.data = mean_cl_boot, geom = 'ribbon', alpha = .5, aes(fill = group)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = group)) +
    stat_summary(fun.y = mean, geom = 'point', aes(shape = group)) +
    scale_x_continuous(breaks = 1:10) +
    theme(legend.position = c(.8, .15)) +
    xlab('within-topic position of sentence') + ylab('branching factor') +
    guides(fill = guide_legend(title = 'group'),
        lty = guide_legend(title = 'group'),
        shape = guide_legend(title = 'group')) +
    scale_fill_manual(values = c('BNC: initiator' = my_colors[2], 'BNC: responder' = my_colors[2],
        'Switchboard: initiator' = my_colors[1], 'Switchboard: responder' = my_colors[1])) +
    scale_linetype_manual(values = c('BNC: initiator' = 1, 'BNC: responder' = 3, 'Switchboard: initiator' = 1, 'Switchboard: responder' = 3)) +
    scale_shape_manual(values = c('BNC: initiator' = 1, 'BNC: responder' = 1, 'Switchboard: initiator' = 4, 'Switchboard: responder' = 4))


library(gridExtra)

# the function that gets the legend of a plot (for multiple plotting that shares one legend)
g_legend = function(p) {
    tmp = ggplotGrob(p)
    leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend = tmp$grobs[[leg]]
    legend
}

p.sl = p.sl + theme(legend.position = 'bottom') #plot.title = element_text(size = 12)
lgd = g_legend(p.sl)

pdf('sltdbf.pdf', 10, 4)
grid.arrange(arrangeGrob(p.sl + theme(legend.position = 'none'),
                        p.td + theme(legend.position = 'none'),
                        p.bf + theme(legend.position = 'none'), ncol = 3),
            lgd, nrow = 2, heights = c(9, 1))
dev.off()
