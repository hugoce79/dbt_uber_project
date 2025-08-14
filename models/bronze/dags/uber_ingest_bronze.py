from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.transfers.gcs_to_local import GCSToLocalFilesystemOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
import pendulum

with DAG(
    dag_id="uber_ingest_bronze_overwrite",
    start_date=days_ago(1),
    schedule_interval="@daily",
    catchup=False,
    default_args={"owner": "airflow"},
    description="Bronze ingest: descarga, crea/rehace tabla, PUT OVERWRITE y COPY INTO",
    tags=["bronze", "ingest", "overwrite"],
) as dag:

    # 1. Descargar CSV desde GCS
    download = GCSToLocalFilesystemOperator(
        task_id="download_from_gcs",
        bucket="uber_ingest_test",
        object_name="uber_data.csv",
        filename="/tmp/uber_data.csv",
        gcp_conn_id="google_cloud_default",
    )

    # 2. (Re)Crear tabla Bronze — así te aseguras que está vacía
    recreate_table = SQLExecuteQueryOperator(
        task_id="recreate_bronze_table",
        conn_id="snowflake_default",
        sql="""
            CREATE OR REPLACE TABLE BRONZE.UBER_RAW (
                vendor_id INTEGER,
                tpep_pickup_datetime TIMESTAMP,
                tpep_dropoff_datetime TIMESTAMP,
                passenger_count INTEGER,
                trip_distance FLOAT,
                pickup_longitude FLOAT,
                pickup_latitude FLOAT,
                RatecodeID INTEGER,
                store_and_fwd_flag STRING,
                dropoff_longitude FLOAT,
                dropoff_latitude FLOAT,
                payment_type INTEGER,
                fare_amount FLOAT,
                extra FLOAT,
                mta_tax FLOAT,
                tip_amount FLOAT,
                tolls_amount FLOAT,
                improvement_surcharge FLOAT,
                total_amount FLOAT
            );
        """,
    )

    # 3. Subir el archivo al stage, sobreescribiendo el anterior
    put_file = SQLExecuteQueryOperator(
        task_id="put_to_stage_overwrite",
        conn_id="snowflake_default",
        sql="PUT file:///tmp/uber_data.csv @%UBER_RAW AUTO_COMPRESS=TRUE OVERWRITE=TRUE;",
    )

    # 4. Cargar el CSV (nuevo) en la tabla vacía
    copy_into = SQLExecuteQueryOperator(
        task_id="copy_into_bronze",
        conn_id="snowflake_default",
        sql="""
            COPY INTO BRONZE.UBER_RAW
            FROM @%UBER_RAW/uber_data.csv.gz
            FILE_FORMAT = (TYPE = 'CSV', FIELD_DELIMITER = ',', SKIP_HEADER = 1)
            ON_ERROR = 'CONTINUE';
        """,
    )

    download >> recreate_table >> put_file >> copy_into
