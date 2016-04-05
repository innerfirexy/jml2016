# compute the correlation between sentence length and global position
# and the correlation between sentence length and sentence entropy
# Yang Xu
# 4/5/2016

library(data.table)

df.bnc = readRDS('bnc_df_c.rds')
df.swbd = readRDS('swbd_df_c.rds')

#
cor.test(df.bnc$wordNum, df.bnc$globalID) # r = 0.038
cor.test(df.swbd$wordNum, df.swbd$globalID) # r = -0.035

#
cor.test(df.bnc$wordNum, df.bnc$ent) # r = 0.091
cor.test(df.swbd$wordNum, df.swbd$ent) # r = 0.258
