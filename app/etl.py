import logging
import os
from extractor import extract_csv_in_batches
from transformer import transform_to_json
from loader import load_to_sql
from db_connection import get_connection

os.makedirs("logs", exist_ok=True)

logging.basicConfig(
    filename="logs/etl.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

def run_etl(file_path: str):
    conn = None
    try:
        conn = get_connection()
        logging.info("Conexión a PostgreSQL establecida correctamente")

        for i, chunk in enumerate(extract_csv_in_batches(file_path)):
            try:
                json_data = transform_to_json(chunk)
                load_to_sql(conn, json_data)
            except Exception as e:
                logging.error(f"Error en el lote {i+1}: {e}", exc_info=True)

        logging.info("ETL finalizado")

    except Exception as e:
        logging.critical(f"Error crítico en la conexión o proceso ETL: {e}", exc_info=True)
    finally:
        if conn:
            conn.close()
            logging.info("Conexión a PostgreSQL cerrada")

if __name__ == "__main__":
    run_etl("csv/Resultados.csv")

