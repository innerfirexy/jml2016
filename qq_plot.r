# quantile-quantile plot of entropy distribution
# Yang Xu
# 5/4/2016

library(data.table)
library(ggplot2)

# load data
df.bnc = readRDS('bnc_df_c.rds')
dt.bnc = data.table(df.bnc)

df.swbd = readRDS('swbd_df_c.rds')
dt.swbd = data.table(df.swbd)

# construct dt for plot
dt.swbd.tmp = dt.swbd[, .(convID, globalID, ent, entc)]
dt.swbd.tmp[, corpus := 'Switchboard']
dt.bnc.tmp = dt.bnc[, .(convID, globalID, ent, entc)]
dt.bnc.tmp[, corpus := 'BNC']
dt.all = rbindlist(list(dt.swbd.tmp, dt.bnc.tmp))
dt.all[, logEnt := log(ent)][, logEntc := log(entc)]


# the function that generate qqplot with a central abline
getqqplot <- function (vec) # argument: vector of numbers
{
  # following four lines from base R's qqline()
  y <- quantile(vec[!is.na(vec)], c(0.25, 0.75))
  x <- qnorm(c(0.25, 0.75))
  slope <- diff(y)/diff(x)
  int <- y[1L] - slope * x[1L]

  d <- data.frame(resids = vec)

  ggplot(d, aes(sample = resids)) + stat_qq() + geom_abline(slope = slope, intercept = int)
}


# entropy
p1 = ggplot(dt.all, aes(sample = ent, shape = corpus, color = corpus)) +
    stat_qq() + theme_bw() + theme(legend.position = c(.2, .8)) +
    geom_abline(slope = 4, intercept = 15, lty = 2)
pdf('ent_qq.pdf', 5, 5)
plot(p1)
dev.off()

# log entropy
p2 = ggplot(dt.all, aes(sample = logEnt, shape = corpus, color = corpus)) +
    stat_qq() + theme_bw() + theme(legend.position = c(.2, .8)) +
    geom_abline(slope = .4, intercept = 2, lty = 2)
pdf('log_ent_qq.pdf', 5, 5)
plot(p2)
dev.off()


# normalized entropy
# p5 = getqqplot(dt.swbd$entc) # not normal
p5 = ggplot(dt.all, aes(sample = entc, shape = corpus, color = corpus)) +
    stat_qq() + theme_bw() + theme(legend.position = c(.2, .8)) +
    geom_abline(slope = .8, intercept = 2, lty = 2)
pdf('ne_qq.pdf', 5, 5)
plot(p5)
dev.off()


# log normalized entropy
p6 = ggplot(dt.all, aes(sample = logEntc, shape = corpus, color = corpus)) +
    stat_qq() + theme_bw() + theme(legend.position = c(.2, .8)) +
    geom_abline(slope = .4, intercept = 0, lty = 2)
pdf('log_ne_qq.pdf', 5, 5)
plot(p6)
dev.off()




### density curves
# entropy
d1 = ggplot(dt.all, aes(x = ent, color = corpus, lty = corpus)) +
    geom_density() + theme_bw() + theme(legend.position = c(.8, .8)) +
    xlab('entropy')
pdf('ent_density.pdf', 5, 5)
plot(d1)
dev.off()

# log entropy
d2 = ggplot(dt.all, aes(x = logEnt, color = corpus, lty = corpus)) +
    geom_density() + theme_bw() + theme(legend.position = c(.2, .8)) +
    xlab('log entropy')
pdf('log_ent_density.pdf', 5, 5)
plot(d2)
dev.off()

# normalized entropy
d3 = ggplot(dt.all, aes(x = entc, color = corpus, lty = corpus)) +
    geom_density() + theme_bw() + theme(legend.position = c(.8, .8)) +
    xlab('normalized entropy')
pdf('ne_density.pdf', 5, 5)
plot(d3)
dev.off()

# log normalized entropy
d4 = ggplot(dt.all, aes(x = logEntc, color = corpus, lty = corpus)) +
    geom_density() + theme_bw() + theme(legend.position = c(.8, .8)) +
    xlab('log normalized entropy')
pdf('log_ne_density.pdf', 5, 5)
plot(d4)
dev.off()


### Shapiro-Wilk tests, size <= 5000
shapiro.test(sample(dt.swbd$ent, 5000)) # W = 0.90815***, significantly different from normal distribution
shapiro.test(sample(dt.bnc$ent, 5000)) # W = 0.90662***

shapiro.test(sample(dt.all[corpus == 'Switchboard', logEnt], 5000))
shapiro.test(sample(dt.all[corpus == 'BNC', logEnt], 5000))

shapiro.test(sample(dt.all[corpus == 'Switchboard', entc], 5000))
shapiro.test(sample(dt.all[corpus == 'BNC', entc], 5000))

shapiro.test(sample(dt.all[corpus == 'Switchboard', logEntc], 5000))
shapiro.test(sample(dt.all[corpus == 'BNC', logEntc], 5000))

# demo
# shapiro.test(rnorm(100, mean = 5, sd = 3))
# shapiro.test(runif(100, min = 2, max = 4))


# perplexity
dt.swbd[, ppl := 2^ent]
p = getqqplot(dt.swbd$ppl)
plot(p)


## density of sentence length (wordNum)
plot(density(dt.swbd$wordNum)) # one peak
plot(density(log(dt.swbd$wordNum))) # multiple peaks

plot(density(dt.bnc$wordNum)) # one peak
plot(density(log(dt.bnc$wordNum))) # multiple peaks
