# carry shuffled texttiling experiments for Switchboard and BNC
# Yang Xu
# 4/22/2016

import MySQLdb
import sys
import re

# get db connection
def db_conn(db_name):
    # db init: ssh yvx5085@brain.ist.psu.edu -i ~/.ssh/id_rsa -L 1234:localhost:3306
    conn = MySQLdb.connect(host = "127.0.0.1",
                    user = "yang",
                    port = 1234,
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

    query = 'select strLower from entropy_DEM_full'



# main
if __name__ == '__main__':
