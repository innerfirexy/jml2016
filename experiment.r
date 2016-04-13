# assign pseudo episode boundaries to the dialogues in Switchboard and BNC
# and observe whether entropy convergence exists in these pseudo episodes
# Yang Xu
# 4/11/2015

library(data.table)
library(ggplot2)


## BNC
# load
df.bnc = readRDS('bnc_df_c.rds')
dt.bnc = data.table(df.bnc)
setkey(dt.bnc, convID)

# create the column of pseudo boundaries
bnc.pseudo = dt.bnc[, {
    n_eps = floor(.N / 10)

    if (n_eps > 0) {
        pepID = rep(1:n_eps, each = 10)
        pepID = c(pepID, rep(n_eps + 1, .N - n_eps*10))
    } else {
        pepID = rep(1, .N)
    }

    if (n_eps > 0) {
        inPepID = rep(1:10, n_eps)
        if (.N %% 10 != 0) {
            inPepID = c(inPepID, 1:(.N - n_eps*10))
        }
    } else {
        inPepID = 1:.N
    }

    .(pepID = pepID, inPepID = inPepID)
    }, by = convID]

# cbind
dt.bnc = cbind(dt.bnc, bnc.pseudo[, .(pepID, inPepID)])

# get the row indexes of pseudo episode boundaries
pepBndIdx.bnc = dt.bnc[, .(rowIndex = .I[which(inPepID == 1 & pepID > 1)])]
pepBndIdx.bnc.within = c()
for (i in 1:nrow(pepBndIdx.bnc)) {
    idx = pepBndIdx.bnc$rowIndex[i]
    if (dt.bnc[idx, turnID] == dt.bnc[idx-1, turnID]) {
        pepBndIdx.bnc.within = c(pepBndIdx.bnc.within, idx)
    }
}
pepBndIdx.bnc.between = setdiff(pepBndIdx.bnc$rowIndex, pepBndIdx.bnc.within)

# find the byPepLeader column
setkey(dt.bnc, convID, pepID)
pepLeader.bnc = dt.bnc[, {
    if (.I[1] %in% pepBndIdx.bnc.within) {
        leader = speaker[1]
    } else if (.I[1] %in% pepBndIdx.bnc.between) {
        idx = which(wordNum > 5)
        if (length(idx) > 0) {
            idx = idx[1]
            leader = speaker[idx]
        } else {
            leader = ifelse(runif(1, 0, 1) > 0.5, 'A', 'B')
        }
    } else {
        leader = ifelse(runif(1, 0, 1) > 0.5, 'A', 'B')
    }
    .(pepLeader = leader)
    }, by = .(convID, pepID)]

# join pepLeader.bnc to dt.bnc
dt.bnc = dt.bnc[pepLeader.bnc]

# add byPepLeader column
dt.bnc[, byPepLeader := (pepLeader == speaker)]

# plot
p.bnc = ggplot(dt.bnc, aes(x = inPepID, y = ent)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = byPepLeader)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon', aes(fill = byPepLeader), alpha = .5)
plot(p.bnc)



## Switchboard
df.swbd = readRDS('swbd_df_c.rds')
dt.swbd = data.table(df.swbd)
setkey(dt.swbd, convID)

swbd.pseudo = dt.swbd[, {
    n_eps = floor(.N / 10)

    if (n_eps > 0) {
        pepID = rep(1:n_eps, each = 10)
        pepID = c(pepID, rep(n_eps + 1, .N - n_eps*10))
    } else {
        pepID = rep(1, .N)
    }

    if (n_eps > 0) {
        inPepID = rep(1:10, n_eps)
        if (.N %% 10 != 0) {
            inPepID = c(inPepID, 1:(.N - n_eps*10))
        }
    } else {
        inPepID = 1:.N
    }

    .(pepID = pepID, inPepID = inPepID)
    }, by = convID]

dt.swbd = cbind(dt.swbd, swbd.pseudo[, .(pepID, inPepID)])

pepBndIdx.swbd = dt.swbd[, .(rowIndex = .I[which(inPepID == 1 & pepID > 1)])]
pepBndIdx.swbd.within = c()
for (i in 1:nrow(pepBndIdx.swbd)) {
    idx = pepBndIdx.swbd$rowIndex[i]
    if (dt.swbd[idx, turnID] == dt.swbd[idx-1, turnID]) {
        pepBndIdx.swbd.within = c(pepBndIdx.swbd.within, idx)
    }
}
pepBndIdx.swbd.between = setdiff(pepBndIdx.swbd$rowIndex, pepBndIdx.swbd.within)

setkey(dt.swbd, convID, pepID)
pepLeader.swbd = dt.swbd[, {
    if (.I[1] %in% pepBndIdx.swbd.within) {
        leader = speaker[1]
    } else if (.I[1] %in% pepBndIdx.swbd.between) {
        idx = which(wordNum > 5)
        if (length(idx) > 0) {
            idx = idx[1]
            leader = speaker[idx]
        } else {
            leader = ifelse(runif(1, 0, 1) > 0.5, 'A', 'B')
        }
    } else {
        leader = ifelse(runif(1, 0, 1) > 0.5, 'A', 'B')
    }
    .(pepLeader = leader)
    }, by = .(convID, pepID)]

dt.swbd = dt.swbd[pepLeader.swbd]
dt.swbd[, byPepLeader := (pepLeader == speaker)]

p.swbd = ggplot(dt.swbd, aes(x = inPepID, y = ent)) +
    stat_summary(fun.y = mean, geom = 'line', aes(lty = byPepLeader)) +
    stat_summary(fun.data = mean_cl_normal, geom = 'ribbon', aes(fill = byPepLeader), alpha = .5)
plot(p.swbd)
