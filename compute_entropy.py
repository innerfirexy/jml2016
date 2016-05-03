# Use the `model` module in nltk_legacy folder to compute the entropy
# Yang Xu
# 5/2/2016

from nltk_legacy import ngram
import MySQLdb
import sys
import pickle

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

#


# main
if __name__ == '__main__':
    # data = read_data()
    # pickle.dump(data, open('swbd_sents100.dat', 'wb'))
