# quick test per-word entropy vs sentence entropy
# Yang Xu
# 4/20/2016

library(data.table)
library(ggplot2)
library(lme4)
library(lmerTest)

# load data
df.bnc = readRDS('bnc_df_c.rds')
dt.bnc = data.table(df.bnc)

df.swbd = readRDS('swbd_df_c.rds')
dt.swbd = data.table(df.swbd)


# ent ~ globalID
summary(lmer(ent ~ globalID + (1|convID), dt.bnc)) # *** ~
# by reviewing the code in ngram.py, the entropy function returns the per-word entropy of a sentence

# get per-word entropy
dt.bnc[, ent_per := ent / wordNum]
summary(lmer(ent_per ~ globalID + (1|convID), dt.bnc)) # ***


# distr of ent
plot(density(dt.bnc$ent))
plot(density(dt.swbd$ent))

qqnorm(log(dt.bnc$ent))
qqnorm(log(dt.swbd$ent))
