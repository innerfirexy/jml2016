# Use the `model` module in nltk_legacy folder to compute the entropy
# Yang Xu
# 5/2/2016

from nltk_legacy.ngram import NgramModel
import MySQLdb
import sys
import pickle
import random

# get db connection
def db_conn(db_name):
    # db init: ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
    conn = MySQLdb.connect(host = "127.0.0.1",
                    user = "yang",
                    port = 1234,
                    passwd = "05012014",
                    db = db_name)
    return conn

# read data from db
def read_data():
    """
    read sentences from db
    return: a dict instance, whose keys are convIds and values are dict instances
        the keys of those values are 1~100, and values are sentences (list of str)
    """
    conn = db_conn('swbd')
    cur = conn.cursor()
    # select convIds
    query = 'select distinct convID from entropy'
    cur.execute(query)
    conv_ids = [t[0] for t in cur.fetchall()]
    # initialize the data to be returned
    data = {cid : {} for cid in conv_ids}
    # for each cid in conv_ids, read the sentences from 1 to 100 and store to data
    print('reading data')
    for i, cid in enumerate(conv_ids):
        query = 'select globalID, rawWord from entropy where convID = %s and globalID <= 100'
        cur.execute(query, [cid])
        res = cur.fetchall()
        for r in res:
            gid, stext = r
            data[cid][gid] = stext.strip().split()
        sys.stdout.write('\r{}/{} data read'.format(i+1, len(conv_ids)))
        sys.stdout.flush()
    print('\nall data read')
    return data

# read data from disk
def read_data_disk(datafilename):
    data = pickle.load(open(datafilename, 'rb'))
    return data

# get train sentences from data
def get_train_sents(data, train_ids, sent_id):
    """
    train_ids: a list of convIds
    sent_id: sentence id, from 1 to 100
    return: a list of lists of strings
    """
    sents = []
    for cid in train_ids:
        sent = data[cid][sent_id]
        if len(sent) > 0:
            sents.append(sent)
    return sents


# process Switchboard
def proc_swbd():
    data = read_data_disk('swbd_sents100.dat')
    conn = db_conn('swbd')
    cur = conn.cursor()
    # select all convIds
    query = 'select distinct convID from entropy'
    cur.execute(query)
    conv_ids = [t[0] for t in cur.fetchall()]
    # shuffle and make folds
    random.shuffle(conv_ids)
    fold_num = 10
    fold_size = int(len(conv_ids)/fold_num)
    conv_ids_folds = []
    for i in range(0, fold_num):
        if i < fold_num-1:
            conv_ids_folds.append(conv_ids[i*fold_size : (i+1)*fold_size])
        else:
            conv_ids_folds.append(conv_ids[i*fold_size:])
    # cross validation
    results = []
    for i in range(0, fold_num):
        print('fold {} begins'.format(i))
        test_ids = conv_ids_folds[i]
        train_ids = []
        for j in range(0, fold_num):
            if j != i:
                train_ids += conv_ids_folds[j]
        # from sentence position 1 to 100
        for sid in range(1, 101):
            train_sents = get_train_sents(data, train_ids, sid)
            lm = NgramModel(3, train_sents)
            for cid in test_ids:
                sent = data[cid][sid]
                if len(sent) > 0:
                    ent = lm.entropy(sent)
                    results.append((cid, sid, ent))
            sys.stdout.write('\r{}/{} done'.format(sid, 100))
            sys.stdout.flush()
        print('fold {} done'.format(i))
    # write results to file
    with open('swbd_sent100_res.dat', 'w') as fw:
        for item in results:
            row = ', '.join(map(str, item)) + '\n'
            fw.write(row)



# main
if __name__ == '__main__':
    # data = read_data()
    # pickle.dump(data, open('swbd_sents100.dat', 'wb'))
    proc_swbd()
