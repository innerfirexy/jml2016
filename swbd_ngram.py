#!/usr/local/bin/python3
# Train a ngram language model on a certain corpora, and compute the per-word entropy for
# each sentence in Switchboard
# Yang Xu
# 1/21/2016

import nltk
from nltk.model.ngram import NgramModel
from nltk.probability import LidstoneProbDist

# db connect
def db_conn(db_name):
    # db init: ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
    conn = MySQLdb.connect(host = "127.0.0.1",
                    user = "yang",
                    port = 3306,
                    passwd = "05012014",
                    db = "swbd")
    cur = conn.cursor()

#
