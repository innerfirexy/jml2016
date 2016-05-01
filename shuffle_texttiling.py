# carry shuffled texttiling experiments for Switchboard and BNC
# Yang Xu
# 4/22/2016

import MySQLdb
import sys
import re
import random

from nltk.tokenize.texttiling import TextTilingTokenizer


# get db connection
def db_conn(db_name):
    # db init: ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
    conn = MySQLdb.connect(host = "127.0.0.1",
                    user = "yang",
                    port = 3306,
                    passwd = "05012014",
                    db = db_name)
    return conn

# process BNC
def proc_BNC():
    # check how different the `convIDStr` column in entropy,
    # is different from the `xmlID` column in entropy_DEM100 of BNC db
    conn = db_conn('bnc')
    cur = conn.cursor()

    query = 'select distinct(convIDStr) from entropy'
    cur.execute(query)
    convIDStr = [t[0] for t in cur.fetchall()]

    query = 'select distinct(xmlID) from entropy_DEM100'
    cur.execute(query)
    xmlID = [t[0] for t in cur.fetchall()]

    pattern = re.compile('(?<=\/)[A-Z0-9]+(?=\.)') # lookahead and lookbehind
    xmlID_trim = [(pattern.search(xml).group(0), xml) for xml in xmlID]

    # new table in BNC table, from the select statement that selects from the DEM_2spkr table
    # where the `xmlID` column is from entropy_DEM100
    # note, entropy_DEM100 only contains the first 100 sentences, and the new table, entropy_DEM_full,
    # contains all the sentences from each conversation
    query = 'create table if not exists entropy_DEM_full \
        (xmlID varchar(30), divIndex int, speakerOriginal varchar(30), \
        globalID int, turnID int, localID int, strLower longtext, parsedC5 longtext, \
        turnLen int, wordNum int, primary key(xmlID, divIndex, globalID)) \
        select xmlID, divIndex, speakerOriginal, globalID, turnID, localID, strLower, parsedC5, \
        turnLen, wordNum from DEM_2spkr where xmlID in (%s)'
    in_cond = ', '.join(list(map(lambda x: '%s', xmlID)))
    query = query % in_cond
    cur.execute(query, xmlID)

    # modify `*ID` to `*Id` in column names
    query = 'alter table entropy_DEM_full \
        change xmlID xmlId varchar(30), change globalID globalId int, \
        change turnID turnId int, change localID localId int'
    cur.execute(query)

    # add episodeId and inEpisodeId columns
    query = 'alter table entropy_DEM_full \
        add episodeId int, add inEpisodeId int, add convId int after divIndex'
    cur.execute(query)

    # select the distinct `convID` from entropy_DEM100, and update it to entropy_DEM_full
    query = 'select distinct xmlID, divIndex, convID from entropy_DEM100'
    cur.execute(query)
    data = cur.fetchall()
    for d in data:
        (xml_id, div_idx, conv_id) = d
        query = 'update entropy_DEM_full set convId = %s where xmlId = %s and divIndex = %s'
        cur.execute(query, (conv_id, xml_id, div_idx))
    conn.commit()



# carry out the shuffle experiment on BNC
def shuffle_BNC():
    conn = db_conn('bnc')
    cur = conn.cursor()
    # create the table to store the shuffled sentences
    query = 'create table if not exists entropy_DEM_full_shuffle \
        (convId int, originalGlobalId int, sentenceId int, tokens longtext, \
        episodeId int, inEpisodeId int, primary key(convId, sentenceId))'
    cur.execute(query)

    # select all convId from the original entropy_DEM_full table
    query = 'select distinct(convId) from entropy_DEM_full'
    cur.execute(query)
    conv_ids = [t[0] for t in cur.fetchall()]

    # for each convId, shuffle the selected (globalId, strLower) sequence,
    # and insert the shuffled sequence to entropy_DEM_full_shuffle table
    for i, cid in enumerate(conv_ids):
        query = 'select globalId, strLower from entropy_DEM_full where convId = %s'
        cur.execute(query, [cid])
        sequence = [(t[0], t[1]) for t in cur.fetchall()]
        random.shuffle(sequence)
        # insert
        for j, item in enumerate(sequence):
            (original_gid, sent) = item
            query = 'insert into entropy_DEM_full_shuffle values(%s, %s, %s, %s, %s, %s)'
            cur.execute(query, (cid, original_gid, j+1, sent, None, None))
        # print progress
        sys.stdout.write('\r{}/{} convId shuffled.'.format(i+1, len(conv_ids)))
        sys.stdout.flush()
    conn.commit()

    # add old ent column from entropy_DEM100 table to entropy_DEM_full_shuffle table
    # first add the column, and then a inner join query
    query = 'alter table entropy_DEM_full_shuffle add ent_old float after inEpisodeId'
    cur.execute(query)
    query = 'update entropy_DEM_full_shuffle t1 inner join entropy_DEM100 t2 \
        on t1.convId = t2.convID and t1.originalGlobalId = t2.globalID \
        set t1.ent_old = t2.ent'
    cur.execute(query)
    conn.commit()



# conduct texttiling for the shuffled sentences in entropy_DEM_full_shuffle table
def texttiling_BNC_shuffle():
    conn = db_conn('bnc')
    cur = conn.cursor()
    # select unique convId
    query = 'select distinct(convId) from entropy_DEM_full_shuffle'
    cur.execute(query)
    conv_ids = [t[0] for t in cur.fetchall()]

    # for each convId, do texttiling, and update the episodeId and inEpisodeId columns
    tt = TextTilingTokenizer()
    for i, cid in enumerate(conv_ids):
        query = 'select tokens from entropy_DEM_full_shuffle where convId = %s'
        cur.execute(query, [cid])
        text = '\n\n\n\t'.join([t[0] for t in cur.fetchall()])
        try:
            segmented = tt.tokenize(text)
        except Exception as e:
            exc_type, exc_obj, exc_tb = sys.exc_info()
            if str(exc_obj) == 'Input vector needs to be bigger than window size.' or \
                str(exc_obj) == 'No paragraph breaks were found(text too short perhaps?)': # it means the conversation is too short
                pass
            else:
                raise
        else:
            sentence_id = 1
            for j, seg in enumerate(segmented):
                epi_id = j + 1
                sents = [s for s in seg.split('\n\n\n\t') if s != '']
                for k, s in enumerate(sents):
                    in_epi_id = k + 1
                    # update
                    query = 'update entropy_DEM_full_shuffle set episodeId = %s, inEpisodeId = %s \
                        where convId = %s and sentenceId = %s'
                    cur.execute(query, (epi_id, in_epi_id, cid, sentence_id))
                    sentence_id += 1
            # print progress
            sys.stdout.write('\r%s/%s updated' % (i+1, len(conv_ids)))
            sys.stdout.flush()
    # commit
    conn.commit()

# carry out texttiling on entropy_DEM_full table
def texttiling_BNC():
    conn = db_conn('bnc')
    cur = conn.cursor()
    # select unique convId
    query = 'select distinct(convId) from entropy_DEM_full'
    cur.execute(query)
    conv_ids = [t[0] for t in cur.fetchall()]

    # for each convId, do texttiling, and update the episodeId and inEpisodeId columns
    tt = TextTilingTokenizer()
    for i, cid in enumerate(conv_ids):
        query = 'select strLower from entropy_DEM_full where convId = %s'
        cur.execute(query, [cid])
        text = '\n\n\n\t'.join([t[0] for t in cur.fetchall()])
        try:
            segmented = tt.tokenize(text)
        except Exception as e:
            exc_type, exc_obj, exc_tb = sys.exc_info()
            if str(exc_obj) == 'Input vector needs to be bigger than window size.' or \
                str(exc_obj) == 'No paragraph breaks were found(text too short perhaps?)': # it means the conversation is too short
                pass
            else:
                raise
        else:
            global_id = 1
            for j, seg in enumerate(segmented):
                epi_id = j + 1
                sents = [s for s in seg.split('\n\n\n\t') if s != '']
                for k, s in enumerate(sents):
                    in_epi_id = k + 1
                    # update
                    query = 'update entropy_DEM_full set episodeId = %s, inEpisodeId = %s \
                        where convId = %s and globalId = %s'
                    cur.execute(query, (epi_id, in_epi_id, cid, global_id))
                    global_id += 1
            # print progress
            sys.stdout.write('\r%s/%s updated' % (i+1, len(conv_ids)))
            sys.stdout.flush()
    # commit
    conn.commit()


# shuffle Switchboard
def shuffle_SWBD():
    conn = db_conn('swbd')
    cur = conn.cursor()
    # create the table to store the shuffled sentences,
    query = 'create table if not exists entropy_shuffle \
        (convId int, originalGlobalId int, sentenceId int, tokens longtext, \
        episodeId int, inEpisodeId int, ent_old float, primary key(convId, sentenceId))'
    cur.execute(query)

    # select all convId from the original entropy table
    query = 'select distinct(convID) from entropy'
    cur.execute(query)
    conv_ids = [t[0] for t in cur.fetchall()]

    # for each convId, shuffle the selected (globalID, rawWord) sequence,
    # and insert the shuffled sequence to entropy_shuffle table
    for i, cid in enumerate(conv_ids):
        query = 'select globalID, rawWord from entropy where convId = %s'
        cur.execute(query, [cid])
        sequence = [(t[0], t[1]) for t in cur.fetchall()]
        random.shuffle(sequence)
        # insert
        for j, item in enumerate(sequence):
            (original_gid, sent) = item
            query = 'insert into entropy_shuffle values(%s, %s, %s, %s, %s, %s, %s)'
            cur.execute(query, (cid, original_gid, j+1, sent, None, None, None))
        # print progress
        sys.stdout.write('\r{}/{} convId shuffled.'.format(i+1, len(conv_ids)))
        sys.stdout.flush()
    conn.commit()

    # copy the ent column in entropy to the ent_old column in entropy_shuffle
    query = 'update entropy_shuffle t1 inner join entropy t2 \
        on t1.convId = t2.convID and t1.originalGlobalId = t2.globalID \
        set t1.ent_old = t2.ent'
    cur.execute(query)
    conn.commit()

#


# main
if __name__ == '__main__':
    # texttiling_BNC()
    shuffle_SWBD()
