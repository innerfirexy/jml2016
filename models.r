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


# fixed effect of relative sentence position in turns
# for turns of 2 sentences and 3 sentences only

# turn length 2
summary(lmer(entc ~ localID + (1|convID) + (1|turnID), dt.bnc[turnLen == 2,])) # beta = 7.940e-02, p<0.001
summary(lmer(entc ~ localID + (1|convID) + (1|turnID), dt.swbd[turnLen == 2,])) # beta = 3.375e-02, p<0.001

# turn length 3
summary(lmer(entc ~ localID + (1|convID) + (1|turnID), dt.bnc[turnLen == 3,])) # beta = 5.531e-02, p<0.001
summary(lmer(entc ~ localID + (1|convID) + (1|turnID), dt.swbd[turnLen == 3,])) # beta = 3.457e-02, p<0.001
