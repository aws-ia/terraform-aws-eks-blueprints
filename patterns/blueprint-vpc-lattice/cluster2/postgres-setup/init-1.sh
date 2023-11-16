#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --host="$DBHOST" --port="$DBPORT" --username="$DBMASTERUSER" --variable=dbname=$DBNAME --variable=dbrole=$DBROLE --variable=dbpassword=$DBPASSWORD --variable=dbschema=$DBSCHEMA<<-EOSQL
	DROP USER IF EXISTS :dbrole;
	CREATE USER :dbrole WITH LOGIN PASSWORD :dbpassword;
	CREATE DATABASE :dbname;
	GRANT ALL ON DATABASE :dbname TO :dbrole;
EOSQL