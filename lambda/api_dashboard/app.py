import json
import os
import boto3

s3 = boto3.client("s3")

DATA_BUCKET = os.environ["DATA_BUCKET"]

KPIS_KEY = "processed/kpis.json"
CHARTS_KEY = "processed/charts.json"
FILTERS_KEY = "processed/filters.json"


def build_response(status_code, body):
    """
    Construye una respuesta HTTP en formato JSON.
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }


def read_json_from_s3(key):

    response = s3.get_object(Bucket=DATA_BUCKET, Key=key)
    content = response["Body"].read().decode("utf-8")
    return json.loads(content)


def main_handler(event, context):
    
    try:
        path = event.get("rawPath", "/")

        print("Ruta solicitada:", path)

        if path == "/health":
            return build_response(200, {
                "status": "ok",
                "message": "API funcionando correctamente"
            })

        if path == "/kpis":
            data = read_json_from_s3(KPIS_KEY)
            return build_response(200, data)

        if path == "/charts":
            data = read_json_from_s3(CHARTS_KEY)
            return build_response(200, data)

        if path == "/filters":
            data = read_json_from_s3(FILTERS_KEY)
            return build_response(200, data)

        return build_response(404, {
            "error": "Ruta no encontrada"
        })

    except Exception as e:
        print("Error en api_dashboard:", str(e))
        return build_response(500, {
            "error": "Error interno del servidor",
            "details": str(e)
        })