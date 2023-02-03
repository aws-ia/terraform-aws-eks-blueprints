import logging
import sys
from datetime import datetime

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as f

# Logging configuration
formatter = logging.Formatter('[%(asctime)s] %(levelname)s @ line %(lineno)d: %(message)s')
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)
handler.setFormatter(formatter)
logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(handler)

dt_string = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
AppName = "NewYorkTaxiData"


def main(args):

    raw_input_folder = args[1]
    transform_output_folder = args[2]

    # Create Spark Session
    spark = SparkSession \
        .builder \
        .appName(AppName + "_" + str(dt_string)) \
        .getOrCreate()

    spark.sparkContext.setLogLevel("INFO")
    logger.info("Starting spark application")

    logger.info("Reading Parquet file from S3")
    ny_taxi_df = spark.read.parquet(raw_input_folder)

    # Add additional columns to the DF
    final_ny_taxi_df = ny_taxi_df.withColumn("current_date", f.lit(datetime.now()))

    logger.info("NewYork Taxi data schema preview")
    final_ny_taxi_df.printSchema()

    logger.info("Previewing New York Taxi data sample")
    final_ny_taxi_df.show(20, truncate=False)

    logger.info("Total number of records: " + str(final_ny_taxi_df.count()))

    logger.info("Write New York Taxi data to S3 transform table")
    final_ny_taxi_df.repartition(2).write.mode("overwrite").parquet(transform_output_folder)

    logger.info("Ending spark application")
    # end spark code
    spark.stop()

    return None


if __name__ == "__main__":
    print(len(sys.argv))
    if len(sys.argv) != 3:
        print("Usage: spark-etl [input-folder] [output-folder]")
        sys.exit(0)

    main(sys.argv)
