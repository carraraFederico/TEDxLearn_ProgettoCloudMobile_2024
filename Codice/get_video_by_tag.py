#Caricamento dati su MongoDB

import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, array_join, array_distinct, struct, expr


from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job


#Lettura parametri
tag_path = "s3://tedx-mieidati/tags.csv"
args = getResolvedOptions(sys.argv, ['JOB_NAME'])


#Inizializzazione Spark Context e Job
sc = SparkContext()

glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)


#Lettura dati tag((id,slug,internalId,tag))
dati_tag = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(tag_path)


#Lettura dati video (id,slug,speakers,title,url)
video_path = "s3://tedx-mieidati/final_list.csv"
dati_video = spark.read.option("header","true").csv(video_path)


#Lettura dettagli video (id,slug,interalId,description,duration,socialDescription,presenterDisplayName,publishedAt)
dettagli_path = "s3://tedx-mieidati/details.csv"
dati_dettagli = spark.read.option("header","true").csv(dettagli_path) 

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
    .select(col("id").alias("_id"), col("*")) \
    
tedx_dataset_main.printSchema()


video_by_tag = dati_tag.join(tedx_dataset_main, dati_tag.id == tedx_dataset_main._id, "left") \
    .select(dati_tag["tag"], tedx_dataset_main["_id"].alias("video_id"), tedx_dataset_main["title"].alias("video_title"), col("*")) \
    .drop(dati_tag["slug"])

# Raggruppa per tag e crea una struttura dati all'interno di ciascun tag
video_by_tag = video_by_tag.groupBy("tag") \
    .agg(collect_list(struct(col("video_id"), col("video_title"), col("slug"), col("speakers"),col("url"), col("description"),col("duration"), col("url_img"), col("tags"))).alias("videos_list")).select(col("tag").alias("_id"), col("*")).drop("tag")
    
video_by_tag = video_by_tag.withColumn("videos_list", array_distinct(expr("transform(array_distinct(transform(videos_list, x -> x.video_id)), video_id -> filter(videos_list, x -> x.video_id == video_id)[0])")))

video_by_tag.printSchema()
video_by_tag.show()


write_mongo_options = {
    "connectionName": "TEDx2024",
    "database": "unibg_tedx_2024",
    "collection": "video_da_tag",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(video_by_tag, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)