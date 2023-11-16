#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --host="$DBHOST" --username="$DBROLE" --dbname="$DBNAME" --variable=dbrole=$DBROLE --variable=dbschema=$DBSCHEMA --variable=dbtable=$DBTABLE<<-EOSQL
    CREATE SCHEMA IF NOT EXISTS :dbschema AUTHORIZATION :dbrole;

    CREATE TABLE IF NOT EXISTS :dbschema.userproductsummary (
        total integer NOT NULL,
        name varchar(100) NOT NULL,
        product varchar(100) NOT NULL,
        category varchar(100) NOT NULL
    );
    ALTER TABLE :dbschema.userproductsummary OWNER TO :dbrole;

    CREATE TABLE IF NOT EXISTS :dbschema.popularity_bucket_permanent (
        customer varchar(100) NOT NULL,
        product varchar(100) NOT NULL,
        category varchar(100) NOT NULL,
        city varchar(100) NOT NULL,
        purchased integer NOT NULL,
        PRIMARY KEY (customer, product, category, city)
    );
    ALTER TABLE :dbschema.popularity_bucket_permanent OWNER TO :dbrole;    
EOSQL

