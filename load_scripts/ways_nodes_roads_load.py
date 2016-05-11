import psycopg2 as pg # python library for postgres
import json

# directory where sql scripts are stored
homedir = '/home/ubuntu/routing/'
datadir = homedir + 'data/'
sqldir = homedir + 'sql_scripts/'

# connect to the database
dbpass = open(homedir+"dbpass.txt").read()
host = open(homedir+"host.txt").read()
user = open(homedir+"user.txt").read()
db = open(homedir+"db.txt").read()
conn = pg.connect("dbname="+db+" user="+user+" password = "+dbpass+" host="+host)
# code based on: http://initd.org/psycopg/docs/usage.html

# open a cursor to perform database operations
cur = conn.cursor()

tables = ['nodes','ways','road_ways']

for t in tables:
    print('creating '+t+' table') 
    create_sql = open(sqldir+t+'_create.sql','r').read().split(';')
    [cur.execute(sql) for sql in create_sql if len(sql)>5]
    conn.commit()

#### finish
# close cursor and connection
cur.close()
conn.close()
