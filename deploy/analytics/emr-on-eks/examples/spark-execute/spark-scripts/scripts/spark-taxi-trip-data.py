# In the code below, Spark reads NY Taxi Trip data from Amazon S3.
# The script updates the timestamp column, prints the schema and row count and finally writes the data in parquet format to Amazon S3.
# The last section may take time depending on the EKS cluster size.

# Note that the input and output location is taken as a parameter.
# The script is already uploaded to the workshop S3 bucket and command to run the
#             Spark ETL is shown in the section below the code snippet.

import sys
from datetime import datetime

from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.functions import *

if __name__ == "__main__":

    print(len(sys.argv))
    if len(sys.argv) != 4:
        print("Usage: spark-etl-glue [input-folder] [output-folder] [dbName]")
        sys.exit(0)

    spark = (
        SparkSession.builder.appName("PySpark_Glue_Integration")
        .enableHiveSupport()
        .getOrCreate()
    )

    nyTaxi = (
        spark.read.option("inferSchema", "true")
        .option("header", "true")
        .csv(sys.argv[1])
    )

    updatedNYTaxi = nyTaxi.withColumn("current_date", lit(datetime.now()))

    # Create Glue Catalog Database if not exists
    # Please note that if you are using LakeFormation then required permissions needs to be granted to query the data from Athena
    # Role needs query access on lakeforation db and table
    spark.sql(
        "CREATE database if not exists "
        + sys.argv[3]
        + " LOCATION "
        + "'"
        + sys.argv[2]
        + "'"
    )

    # Write dataframe to S3 using spark saveAsTable option
    target_table = sys.argv[3] + ".ny_taxi_table"
    updatedNYTaxi.write.format("parquet").option("path", sys.argv[2]).mode(
        "overwrite"
    ).saveAsTable(target_table)

    updatedNYTaxi.printSchema()

    print(updatedNYTaxi.show())

    print("Total number of records: " + str(updatedNYTaxi.count()))
