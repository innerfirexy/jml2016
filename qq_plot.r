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
p1 = getqqplot(dt.swbd$ent)
plot(p1)

p2 = getqqplot(dt.bnc$ent)
plot(p2)


# log entropy
p3 = getqqplot(log(dt.swbd$ent))
plot(p3)

p4 = getqqplot(log(dt.bnc$ent))
plot(p4)


# normalized entropy
p5 = getqqplot(dt.swbd$entc) # not normal
plot(p5)

p6 = getqqplot(dt.bnc$entc) # not normal
plot(p6)


# log normalized entropy
p7 = getqqplot(log(dt.swbd$entc)) # near normal
plot(p7)

p8 = getqqplot(log(dt.bnc$entc)) # near normal
plot(p8)
