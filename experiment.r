# assign pseudo episode boundaries to the dialogues in Switchboard and BNC
# and observe whether entropy convergence exists in these pseudo episodes
# Yang Xu
# 4/11/2015

library(data.table)

# load
df.bnc = readRDS('bnc_df_c.rds')

# to DT
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


# find the byPepLeader column
