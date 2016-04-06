# fit the linear mixed-effect models reported in the paper
# Yang Xu
# 4/5/2016

library(data.table)
library(lme4)
library(lmerTest)

df.bnc = readRDS('bnc_df_c.rds')
df.swbd = readRDS('swbd_df_c.rds')

dt.bnc = data.table(df.bnc)
dt.swbd = data.table(df.swbd)

# normalized entropy vs. global position
summary(lmer(entc ~ globalID + (1|convID), dt.bnc)) # beta = 1.416e-03, p < 0.001
summary(lmer(entc ~ globalID + (1|convID), dt.swbd)) # beta = 5.897e-04, p < 0.001

# normalized entropy vs. global position, Switchboard, global position >= 10
summary(lmer(entc ~ globalID + (1|convID), dt.swbd[globalID >= 10,])) # beta = 5.025e-04, p < 0.001

# entropy vs. global position

# entropy vs. global position, Switchboard, global position >= 10
summary(lmer(ent ~ globalID + (1|convID), dt.swbd[globalID >= 10,])) # beta = 3.357e-03, p < 0.001
