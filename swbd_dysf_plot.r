# plot ent vs globalID using entropy_disf table in swbd db
# Yang Xu
# 1/24/2016

library(ggplot2)
library(RMySQL)
library(lme4)

# db init
# ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
conn = dbConnect(MySQL(), host = '127.0.0.1', user = 'yang', port = 1234, password = "05012014", dbname = 'swbd')
sql = 'SELECT convID, globalID, localID, ent FROM entropy_disf WHERE ent IS NOT NULL'
df = dbGetQuery(conn, sql)

# plot
df.plot = subset(df, globalID <= 100)
df.plot$turnStarting = FALSE
df.plot[df.plot$localID == 1,]$turnStarting = TRUE

p = ggplot(df.plot, aes(x = globalID, y = ent, color = turnStarting, lty = turnStarting)) +
    stat_summary(fun.data = mean_cl_boot, geom = 'smooth')
plot(p)


# model
m = lmer(ent ~ globalID + (1|convID), df)
summary(m)
# ! 
# t = -6.1???, entropy drop?