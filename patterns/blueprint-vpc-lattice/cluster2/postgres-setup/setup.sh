#
# Run these commands from an EC2 instances which is in the same VPC as the Aurora/RDS PostgreSQL database.
# Install 'psql' tool on the instance using the following command
# 
sudo amazon-linux-extras install postgresql10 -y

#
# Export the environmane variables in the 'exports' file
# Change the value for the variables DBROLE, DBHOST, and DBPASSWORD per your environment. Keeps other variables the same.
# When setting the DBPASSWORD, set it like this:   DBPASSWORD="'foobar'"
#
source exports

#
# Now, run these scripts
# We are connecting to the remote Postgres database and running the PSQL commands against it.
# This will setup the database, schema, table etc.
#
./init-1.sh
./init-2.sh

#
# Now, import data into Postgres database
# First login into the remote Postgres instance
# Then, run the '\copy' commands from within the Postgres shell
# Modify the path names of the CSV files you are using for the import
#
psql --host=$DBHOST --user=$DBROLE --dbname=$DBNAME
\copy analytics.userproductsummary from '$ROOT_DIR/postgres-setup/postgres-data-summary-csv' WITH DELIMITER ',' CSV HEADER;
\copy analytics.popularity_bucket_permanent from '$ROOT_DIR/postgres-setup/postgres-data-popular-csv' WITH DELIMITER ',' CSV HEADER;
