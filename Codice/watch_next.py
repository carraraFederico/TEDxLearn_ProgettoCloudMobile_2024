#Caricamento dati su MongoDB

import sys
import json
import pyspark
from pyspark.sql.functions import *
from pyspark.sql.types import ArrayType, StructType, StructField, StringType, LongType



from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job


#Lettura parametri
video_path = "s3://tedxlearn-dati/final_list.csv"
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
    

#Eliminazione video con id nullo
tot_video = dati_video.count()
video_not_null = dati_video.filter("id is not null").count()

print(f"Number of items from RAW DATA {tot_video}")
print(f"Number of items from RAW DATA with NOT NULL KEY {video_not_null}")


#Lettura dettagli video (id,slug,interalId,description,duration,socialDescription,presenterDisplayName,publishedAt)
dettagli_path = "s3://tedxlearn-dati/details.csv"
dati_dettagli = spark.read.option("header","true").csv(dettagli_path) 

dati_dettagli = dati_dettagli.select(col("id").alias("id_ref"),
                                         col("description"),
                                         col("duration"),
                                         col("publishedAt"))

# AND JOIN WITH THE MAIN TABLE
tedx_dataset_main = dati_video.join(dati_dettagli, dati_video.id == dati_dettagli.id_ref, "left") \
    .drop("id_ref") \



#Lettura immagini (id,slug,url)
img_path = "s3://tedxlearn-dati/images.csv"
dati_img = spark.read.option("header","true").csv(img_path)
dati_img = dati_img.select(col("id").alias("id_ref"),
                            col("url").alias("url_img"))

tedx_dataset_main = tedx_dataset_main.join(dati_img, tedx_dataset_main.id == dati_img.id_ref, "left") \
    .drop("id_ref") \

# Aggiunta viewedCount
watch_next_path = "s3://tedxlearn-dati/related_videos.csv"
dati_view = spark.read.option("header", "true").csv(watch_next_path)

dati_view = dati_view.select(col("id").alias("id_v"), col("viewedCount").cast("long"))

dati_view = dati_view.orderBy(col("id_v"), col("viewedCount").desc()).dropDuplicates(["id_v"])

tedx_dataset_main = tedx_dataset_main.join(dati_view, tedx_dataset_main.id == dati_view.id_v, "left") \
    .drop("id_v")


#Lettura tag (id,slug,internalId,tag)
tags_path = "s3://tedxlearn-dati/tags.csv"
dati_tag = spark.read.option("header","true").csv(tags_path)

dati_tag_format = dati_tag.groupBy(col("id").alias("id_ref")).agg(collect_list("tag").alias("tags"))
tedx_dataset_main = tedx_dataset_main.join(dati_tag_format, tedx_dataset_main.id == dati_tag_format.id_ref, "left") \
    .drop("id_ref") \


#Lettura watch_next (id, internalId, related_id, slug, title, duration, viewedCount, presenterDisplayName)
dati_watch_next = spark.read.option("header", "true").csv(watch_next_path)

dati_watch_next = dati_watch_next.select(col("id").alias("id_v"), col("related_id"), col("slug"))

related_videos = dati_watch_next.join(tedx_dataset_main, dati_watch_next.slug == tedx_dataset_main.slug, "left") \
    .select("id_v", "related_id", col("speakers").alias("speakers_rel"), col("title").alias("title_rel"), col("url").alias("url_rel"),
            col("description").alias("description_rel"), col("duration").alias("duration_rel"), col("url_img").alias("url_img_rel"),
            col("tags").alias("tags_rel"))

# Rimuove i duplicati dopo l'unione
related_videos = related_videos.dropDuplicates(["id_v", "related_id", "speakers_rel", "title_rel", "url_rel",
                                                "description_rel", "duration_rel", "url_img_rel", "tags_rel"])

related_videos1 = related_videos.select([col for col in related_videos.columns if col != "id_v"])

video_struct = struct(*related_videos1.columns)

dati_watch_next_format = related_videos.groupBy("id_v").agg(collect_list(video_struct).alias("related_videos"))

# Definisci lo schema per la struttura dei related videos
related_video_schema = StructType([
    StructField("related_id", StringType(), True),
    StructField("speakers_rel", StringType(), True),
    StructField("title_rel", StringType(), True),
    StructField("url_rel", StringType(), True),
    StructField("description_rel", StringType(), True),
    StructField("duration_rel", StringType(), True),
    StructField("url_img_rel", StringType(), True),
    StructField("tags_rel", ArrayType(StringType()), True)
])

# Definisci una UDF per rimuovere duplicati nei related_videos
def remove_duplicates(related_videos):
    seen = set()
    unique_videos = []
    for video in related_videos:
        if video.related_id not in seen:
            unique_videos.append(video)
            seen.add(video.related_id)
    return unique_videos

remove_duplicates_udf = udf(remove_duplicates, ArrayType(related_video_schema))

# Rimuove eventuali duplicati nei campi array
dati_watch_next_format = dati_watch_next_format.withColumn("related_videos", remove_duplicates_udf("related_videos"))

tedx_dataset_main = tedx_dataset_main.join(dati_watch_next_format, tedx_dataset_main.id == dati_watch_next_format.id_v, "left") \
    .select(col("id").alias("_id"),col("*")).drop("id", "id_v", "slug")


write_mongo_options = {
    "connectionName": "TEDxLearn",
    "database": "unibg_tedx_2024",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_main, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)