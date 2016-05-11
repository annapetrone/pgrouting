# pgrouting
How to get started with pgRouting extension for PostgreSQL using Open Street Map data


## How to install PostgreSQL on the AWS EC2 instance (or any Ubuntu machine) 
+ `sudo apt-get update`

+ install postgres: 

`sudo apt-get install postgresql libpq-dev`

+ locate `/etc/postgresql/9.3/main/pg_hba.conf`
  - and change `local all all peer ` to `local all all md5 `
  - change `local all postgres peer/md5 ` to `local all postgres trust `
  - add this line, using your IP address: `host    all         all         192.168.101.20/24    trust`

+ in `/etc/postgresql/9.3/main/postgresql.conf` 
  - change `listen_addresses = 'localhost'` to `listen_addresses = '*'`

+ restart your PostgreSQL server

`sudo /etc/init.d/postgresql restart`

+ you can now connect as any user. Connect as the superuser postgres (note, the superuser name may be different in your installation. In some systems it is called pgsql, for example.)

`psql -U postgres`

+ Reset password `ALTER USER postgres with password 'my_secure_password';`

+ use \q (no semi colon) to exit 

+ restart the server, in order to run with the safe `pg_hba.conf` file 

+ `sudo /etc/init.d/postgresql restart`

+ Install these additional packages to get the PostGIS extension
```
sudo apt-get install postgresql-contrib 

sudo apt-get install postgis postgresql-9.3-postgis-2.1
```

+ Create the extension from postgres

```
psql -d postgres -U postgres
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;
\q
```

+ Now get pgRouting by adding their launchpad repository

```
sudo apt-add-repository -y ppa:ubuntugis/ppa
sudo apt-add-repository -y ppa:georepublic/pgrouting
sudo apt-get update
```
+ Install pgRouting package (for Ubuntu 14.04)

`sudo apt-get install postgresql-9.3-pgrouting`


+ Install osm2pgrouting package (optional)

`sudo apt-get install osm2pgrouting`

+ create the extension 

```
psql -d postgres -U postgres
CREATE EXTENSION pgrouting; 

select * from pg_proc 
where proname like 'pgr%'
;
```
+ That should have returned a list of pgRouting functions (they all begin with pgr)


+ One last time `sudo apt-get update`

