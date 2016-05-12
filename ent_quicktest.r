# quick test per-word entropy vs sentence entropy
# Yang Xu
# 4/20/2016

library(data.table)
library(ggplot2)
library(lme4)
library(lmerTest)
library(car) # Anova for Wald test of model
library(MASS) # glmmPQL

# load data
df.bnc = readRDS('bnc_df_c.rds')
dt.bnc = data.table(df.bnc)

df.swbd = readRDS('swbd_df_c.rds')
dt.swbd = data.table(df.swbd)


# ent ~ globalID
summary(lmer(ent ~ globalID + (1|convID), dt.bnc)) # *** ~
# by reviewing the code in ngram.py, the entropy function returns the per-word entropy of a sentence


# log ent ~ globalID
m3 = lmer(log(ent) ~ globalID + (1|convID), dt.swbd) # beta = 3.947e-04 ***
Anova(m3) # Type II Wald chisquare tests
summary(m3) # t = 6.638

m3_pql = glmmPQL(ent ~ globalID, ~1|convID, data = dt.swbd, family = gaussian(link = 'log')) # if logit, out of scope
summary(m3_pql) # t = 8.7385***, beta = 4.86e-04

m4 = lmer(log(ent) ~ globalID + (1|convID), dt.bnc) # beta = 1.424e-03 ***

m4_pql = glmmPQL(ent ~ globalID, ~1|convID, data = dt.bnc, family = gaussian(link = 'log'))
summary(m4_pql) # beta = 1.4041e10-3, t = 17.1686***


m = glmer(ent ~ globalID + (1|convID), dt.swbd, family = binomial)




#######
# test new data
dt.swbd.new = fread('swbd_sent100_res.dat')
colnames(dt.swbd.new) = c('convId', 'sentenceId', 'ent')
summary(lmer(ent ~ sentenceId + (1|convId), dt.swbd.new)) # t = 8.83
