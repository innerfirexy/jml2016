# plot main figures in the journal draft
# Yang Xu 8/4/2016

library(ggplot2)
library(data.table)


# The palette with grey:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


## plot normalized entropy against global position
df.swbd = readRDS('swbd_df_c.rds')
df.bnc = readRDS('bnc_df_c.rds')

p = ggplot(df.swbd, aes(x = globalID, y = entc)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'smooth', color = cbPalette[8], fill = cbPalette[8]) +
    xlab('global position') + ylab('normalized entropy')
pdf('swbd_neVsGlobal.pdf', 5, 5)
plot(p)
dev.off()

p = ggplot(df.bnc, aes(x = globalID, y = entc)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'smooth', color = cbPalette[8], fill = cbPalette[8]) +
    xlab('global position') + ylab('normalized entropy')
pdf('bnc_neVsGlobal.pdf', 5, 5)
plot(p)
dev.off()

