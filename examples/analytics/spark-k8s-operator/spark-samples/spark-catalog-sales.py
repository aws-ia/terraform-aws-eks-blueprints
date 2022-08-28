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

AppName = "CatalogSalesSparkApp"


def main(args):
    """
    Main Spark ETL definition
    :param args:
    :return:
    """
    raw_input_folder = args[1]
    transform_output_folder = args[2]

    # Create Spark Session
    spark = SparkSession \
        .builder \
        .appName(AppName + "_" + str(dt_string)) \
        .getOrCreate()

    spark.sparkContext.setLogLevel("INFO")
    logger.info("Starting spark application")

    # do something here
    logger.info("Reading parquet file from S3")
    df_catalog_sales = spark.read.parquet(raw_input_folder)

    # Add additional columns to the DF
    df_catalog_sales_date = df_catalog_sales.withColumn("current_date", f.lit(datetime.now()))

    logger.info("Previewing Catalog Sales data sample")
    df_catalog_sales_date.show(20, truncate=False)

    logger.info("Write Catalog Sales data to S3 transform table")
    df_catalog_sales_date.repartition(4).write.mode("overwrite").parquet(transform_output_folder)
    # .partitionBy("app_country", "source_file_dt", "source_file_ts")

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
