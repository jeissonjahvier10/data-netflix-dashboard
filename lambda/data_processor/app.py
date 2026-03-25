import json
import os
import csv
import boto3
from io import StringIO
from collections import defaultdict

# Cliente para conectarse a S3
s3 = boto3.client("s3")

# Variables de entorno que vienen desde Terraform
DATA_BUCKET = os.environ["DATA_BUCKET"]
CSV_KEY = os.environ["CSV_KEY"]

# Archivos JSON que vamos a crear en S3
KPIS_KEY = "processed/kpis.json"
CHARTS_KEY = "processed/charts.json"
FILTERS_KEY = "processed/filters.json"


def safe_float(value):
    """
    Convierte un valor a número decimal.
    Si falla, devuelve 0.
    """
    try:
        return float(value)
    except:
        return 0


def read_csv_from_s3():
    """
    Lee el archivo CSV desde S3 y lo convierte en una lista de filas.
    Cada fila queda como un diccionario.
    """
    response = s3.get_object(Bucket=DATA_BUCKET, Key=CSV_KEY)
    content = response["Body"].read().decode("utf-8")
    reader = csv.DictReader(StringIO(content))
    return list(reader)


def process_data(rows):
    """
    Procesa las filas del CSV y construye:
    - kpis
    - charts
    - filters

    Columnas reales usadas:
    - user_id
    - favorite_genre
    - avg_watch_time_minutes
    - primary_device
    """

    total_watch_time = 0
    watch_time_by_user = defaultdict(float)
    watch_time_by_genre = defaultdict(float)
    users_by_device = defaultdict(int)

    for row in rows:
        user_id = row.get("user_id", "unknown")
        genre = row.get("favorite_genre", "unknown")
        watch_time = safe_float(row.get("avg_watch_time_minutes", 0))
        device = row.get("primary_device", "unknown")

        total_watch_time += watch_time
        watch_time_by_user[user_id] += watch_time
        watch_time_by_genre[genre] += watch_time
        users_by_device[(genre, device)] += 1

    if len(watch_time_by_user) > 0:
        avg_watch_time_per_user = total_watch_time / len(watch_time_by_user)
    else:
        avg_watch_time_per_user = 0

    top_5_genres = sorted(
        [{"genre": genre, "value": value} for genre, value in watch_time_by_genre.items()],
        key=lambda item: item["value"],
        reverse=True
    )[:5]

    kpis = {
        "total_watch_time": round(total_watch_time, 2),
        "avg_watch_time_per_user": round(avg_watch_time_per_user, 2),
        "top_5_genres": top_5_genres
    }

    charts = {
        "genre_distribution": sorted(
            [{"genre": genre, "value": value} for genre, value in watch_time_by_genre.items()],
            key=lambda item: item["value"],
            reverse=True
        ),
        "device_distribution": sorted(
            [
                {"genre": genre, "device": device, "value": value}
                for (genre, device), value in users_by_device.items()
            ],
            key=lambda item: item["value"],
            reverse=True
        )
    }

    filters = {
        "genres": sorted(list(watch_time_by_genre.keys()))
    }

    return kpis, charts, filters


def upload_json_to_s3(key, data):
    """
    Sube un archivo JSON a S3.
    """
    s3.put_object(
        Bucket=DATA_BUCKET,
        Key=key,
        Body=json.dumps(data),
        ContentType="application/json"
    )


def main_handler(event, context):
    """
    Función principal de la Lambda.
    """
    try:
        # 1. Leer el CSV
        rows = read_csv_from_s3()

        print("Cantidad de filas procesadas:", len(rows))
        if rows:
            print("Columnas detectadas:", list(rows[0].keys()))

        # 2. Procesar datos
        kpis, charts, filters = process_data(rows)

        # 3. Guardar archivos JSON en S3
        upload_json_to_s3(KPIS_KEY, kpis)
        upload_json_to_s3(CHARTS_KEY, charts)
        upload_json_to_s3(FILTERS_KEY, filters)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Procesamiento completado correctamente",
                "rows_processed": len(rows)
            })
        }

    except Exception as e:
        print("Error en data_processor:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Error procesando el CSV",
                "error": str(e)
            })
        }