import psycopg2 as pg # python library for postgres
import json
import dropbox

# directory where sql scripts are stored
homedir = '/home/anna/Dropbox/thesis/aws/'
pydir = homedir + 'load_scripts'
sqldir = homedir+'sql_scripts/'
tempDir = homedir+'temp/'

# Access token obtained by making an account on the Dropbox developer website:
access_token = open(homedir+"dropbox_token.txt").read()
client = dropbox.client.DropboxClient(access_token)

act = client.account_info()
#print('Connected to '+act['team']['name']+' team dropbox')
print("Dropbox connection:")
print(act)
     
dropboxPath = '/Apps/vm-cygnus/'
fileName = 'dc.osm'

# connect to the database
dbpass = open(homedir+"dbpass.txt").read()
host = open(homedir+"host.txt").read()
db = open(homedir+"db.txt").read()
user = open(homedir+"user.txt").read()
conn = pg.connect("dbname="+db+" user="+user+" password = "+dbpass+" host="+host)
# code based on: http://initd.org/psycopg/docs/usage.html

# open a cursor to perform database operations
cur = conn.cursor()
 
print('dropping osm_raw and recreating')
create_sql = open(sqldir+'osm_raw_create.sql','r').read().split(';')
[cur.execute(sql) for sql in create_sql if len(sql)>5]
conn.commit()

print('copying from raw osm file ('+dropboxPath+fileName+')')
f = client.get_file(dropboxPath + fileName )
#f = open(datadir+'DC_-77.10720062,38.85722116_-76.9600868,38.9894359.osm','r')
cur.copy_from(f,'osm_raw',sep='\v',null='\\N',columns=('xml_str',)) # there is actually no column seperator (sep), so use "vertical tab" \v because its never present in the file)
conn.commit()

print('flagging node and way rows')
update_sql = open(sqldir+'osm_raw_update.sql','r').read().split(';')
[cur.execute(sql) for sql in update_sql if len(sql)>5]
conn.commit()

#### finish
# close cursor and connection
cur.close()
conn.close()
