#Caricamento dati su MongoDB

import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, array_join, struct


from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job


#Lettura parametri
video_path = "s3://tedx-mieidati/final_list.csv"
args = getResolvedOptions(sys.argv, ['JOB_NAME'])


#Inizializzazione Spark Context e Job
sc = SparkContext()

glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)


#Lettura dati video (id,slug,speakers,title,url)
dati_video = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(video_path)
    
dati_video.printSchema()


#Eliminazione video con id nullo
tot_video = dati_video.count()
video_not_null = dati_video.filter("id is not null").count()

print(f"Number of items from RAW DATA {tot_video}")
print(f"Number of items from RAW DATA with NOT NULL KEY {video_not_null}")


#Lettura dettagli video (id,slug,interalId,description,duration,socialDescription,presenterDisplayName,publishedAt)
dettagli_path = "s3://tedx-mieidati/details.csv"
dati_dettagli = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(dettagli_path) 

dati_dettagli = dati_dettagli.select(col("id").alias("id_ref"),
                                         col("description"),
                                         col("duration"),
                                         col("publishedAt"))

# AND JOIN WITH THE MAIN TABLE
tedx_dataset_main = dati_video.join(dati_dettagli, dati_video.id == dati_dettagli.id_ref, "left") \
    .drop("id_ref") \

tedx_dataset_main.printSchema()


#Lettura immagini (id,slug,url)
img_path = "s3://tedx-mieidati/images.csv"
dati_img = spark.read.option("header","true").csv(img_path)
dati_img = dati_img.select(col("id").alias("id_ref"),
                            col("url").alias("url_img"))

tedx_dataset_main = tedx_dataset_main.join(dati_img, tedx_dataset_main.id == dati_img.id_ref, "left") \
    .drop("id_ref") \

tedx_dataset_main.printSchema()


#Lettura tag (id,slug,internalId,tag)
tags_path = "s3://tedx-mieidati/tags.csv"
dati_tag = spark.read.option("header","true").csv(tags_path)

dati_tag_format = dati_tag.groupBy(col("id").alias("id_ref")).agg(collect_list("tag").alias("tags"))
dati_tag_format.printSchema()
tedx_dataset_main = tedx_dataset_main.join(dati_tag_format, tedx_dataset_main.id == dati_tag_format.id_ref, "left") \
    .drop("id_ref") \

tedx_dataset_main.printSchema()


#Lettura watch_next (id,internalId,related_id,slug,title,duration,viewedCount,presenterDisplayName), array_join vuole due parametri
watch_next_path = "s3://tedx-mieidati/related_videos.csv"
dati_watch_next = spark.read.option("header","true").csv(watch_next_path)

video_struct= struct(col("related_id"),col("title"),col("duration"),col("viewedCount"),col("presenterDisplayName"))
dati_watch_next_format = dati_watch_next.groupBy(col("id").alias("id_ref")).agg(collect_list(video_struct).alias("related_videos"))

tedx_dataset_main = tedx_dataset_main.join(dati_watch_next_format, tedx_dataset_main.id == dati_watch_next_format.id_ref, "left") \
    .drop("id_ref") \
    .select(col("id").alias("_id"), col("*")) \
    .drop("id") \

tedx_dataset_main.printSchema()



write_mongo_options = {
    "connectionName": "TEDx2024",
    "database": "unibg_tedx_2024",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_main, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)