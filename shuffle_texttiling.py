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
        add episodeId int, add inEpisodeId int'
    cur.execute(query)

    pass


# main
if __name__ == '__main__':
