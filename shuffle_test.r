# test the results of shuffled texttiling
# Yang Xu
# 4/26/2016

library(RMySQL)
library(ggplot2)
library(data.table)
library(lme4)
library(lmerTest)

# ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
conn = dbConnect(MySQL(), host = '127.0.0.1', user = 'yang', port = 1234, password = "05012014", dbname = 'bnc')
sql = 'SELECT convId, sentenceId, episodeId, inEpisodeId, ent_old from entropy_DEM_full_shuffle where ent_old is not null'
df.bnc = dbGetQuery(conn, sql)

dt.bnc = data.table(df.bnc)

# models
summary(lmer(ent_old ~ inEpisodeId + (1|convId) + (1|episodeId), dt.bnc)) # insig, t = -0.488
summary(lmer(ent_old ~ sentenceId + (1|convId), dt.bnc)) # insig, t = 1.305

# plots
p1 = ggplot(dt.bnc[episodeId <= 6 & inEpisodeId <= 10], aes(x = inEpisodeId, y = ent_old)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon') +
    stat_summary(fun.y = mean, geom = 'line') +
    # facet_wrap(~episodeId, nrow = 1) +
    scale_x_continuous(breaks = 1:10)
plot(p1)
